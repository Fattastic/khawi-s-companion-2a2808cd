import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { corsHeaders } from "../_shared/cors.ts"

function parseWordList(envKey: string): string[] {
    const raw = Deno.env.get(envKey);
    if (!raw) return [];
    return raw
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .filter((s) => s.length >= 2);
}

// Optional configurable word lists.
// Set env vars like BAD_WORDS_EN="word1,word2" and BAD_WORDS_AR="...".
const BAD_WORDS_AR = parseWordList('BAD_WORDS_AR');
const BAD_WORDS_EN = parseWordList('BAD_WORDS_EN');

function hasSuspiciousLink(text: string): boolean {
    return /(https?:\/\/|www\.|t\.me\/|wa\.me\/|bit\.ly\/|tinyurl\.com\/)/i.test(text);
}

function looksLikeSpam(text: string): boolean {
    // Very simple heuristics: repeated chars, repeated tokens, excessive length.
    if (text.length > 5000) return true;
    if (/(.)\1{8,}/.test(text)) return true;
    const tokens = text.split(/\s+/).filter(Boolean);
    if (tokens.length >= 20) {
        const uniq = new Set(tokens);
        if (uniq.size / tokens.length < 0.3) return true;
    }
    return false;
}

serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        // Service Role needed to write moderation status if called via webhook
        // Use Authorization header if called from client (not recommended for this)
        const supabaseClient = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
        )

        const payload = await req.json()
        // Support both direct call and Database Webhook payload
        const record = payload.record ?? payload;

        if (!record.body || !record.id) {
            throw new Error("Invalid payload");
        }

        const text = String(record.body).toLowerCase();

        // 1) Lightweight heuristic moderation (configurable)
        let status: 'approved' | 'flagged' | 'blocked' = 'approved';
        let reason: string | null = null;
        let severity: 'low' | 'medium' | 'high' | null = null;

        if (BAD_WORDS_EN.some(w => w && text.includes(w)) || BAD_WORDS_AR.some(w => w && text.includes(w))) {
            status = 'blocked';
            reason = 'profanity';
            severity = 'high';
        } else if (hasSuspiciousLink(text)) {
            status = 'flagged';
            reason = 'spam';
            severity = 'medium';
        } else if (looksLikeSpam(text)) {
            status = 'flagged';
            reason = 'spam';
            severity = 'low';
        }

        // 2. (Optional) Call External LLM for nuance check

        // 3) Write Result
        await supabaseClient
            .from('trip_messages')
            .update({ moderation_status: status, flagged_reason: reason })
            .eq('id', record.id)

        if (status !== 'approved') {
            await supabaseClient
                .from('moderation_events')
                .insert({
                    message_id: record.id,
                    status,
                    reason_code: reason,
                    severity,
                    model_version: 'v1.1-heuristics'
                })
        }

        return new Response(
            JSON.stringify({ status, reason }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
    } catch (error) {
        return new Response(
            JSON.stringify({ error: (error as Error).message }),
            { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
        )
    }
})
