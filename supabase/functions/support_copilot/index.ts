import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

function json(data: Record<string, unknown>, status = 200) {
    return new Response(JSON.stringify(data), { status, headers: { "content-type": "application/json" } });
}

function classify(subject: string, body: string) {
    const t = `${subject} ${body}`.toLowerCase();

    const hasPay = ["mada", "stc", "apple pay", "payment", "refund", "charge", "مدى", "stc", "ابل باي", "استرجاع", "دفع"];
    const hasSafety = ["harass", "unsafe", "threat", "sos", "تحرش", "غير آمن", "تهديد", "بلاغ"];
    const hasCancel = ["cancel", "no show", "late", "decline", "الغاء", "تأخر", "رفض"];
    const hasTech = ["bug", "crash", "otp", "login", "map", "doesn't work", "تعطل", "رمز", "تسجيل", "خريطة"];

    const hits = (arr: string[]) => arr.some(w => t.includes(w));

    let classification = "general";
    if (hits(hasSafety)) classification = "safety";
    else if (hits(hasPay)) classification = "payments";
    else if (hits(hasCancel)) classification = "cancellation";
    else if (hits(hasTech)) classification = "technical";

    let sentiment = "neutral";
    if (t.includes("angry") || t.includes("upset") || t.includes("سيء") || t.includes("زعلان") || t.includes("غاضب")) sentiment = "upset";
    if (t.includes("urgent") || t.includes("asap") || t.includes("حالاً") || t.includes("مستعجل")) sentiment = "urgent";

    const summary = body.length > 280 ? body.slice(0, 280) + "…" : body;

    const suggestedReply =
        classification === "safety"
            ? "نأسف للتجربة. سلامتك أولاً. تم استلام البلاغ وسيتواصل فريقنا. إذا كان هناك خطر فوري، استخدم زر SOS أو تواصل مع الجهات المختصة."
            : classification === "payments"
                ? "تم استلام طلبك بخصوص الدفع. نحتاج رقم العملية/آخر 4 أرقام من البطاقة (إن وجدت) وتاريخ العملية لإكمال المراجعة."
                : classification === "technical"
                    ? "نأسف للإزعاج. فضلاً شارك نوع الجهاز وإصدار التطبيق ولقطة شاشة إن أمكن. سنراجع المشكلة بأولوية."
                    : "تم استلام تذكرتك. سنراجع التفاصيل ونعود لك قريباً.";

    const action_tags: string[] = [];
    if (classification === "safety") action_tags.push("escalate_human", "review_logs");
    if (classification === "payments") action_tags.push("request_transaction_details");
    if (sentiment === "urgent") action_tags.push("priority_up");

    return { classification, sentiment, summary, suggestedReply, action_tags };
}

serve(async (req) => {
    try {
        if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

        const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
        const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
        const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

        // Internal-only guard
        const supportSecret = Deno.env.get("SUPPORT_SECRET");
        const got = req.headers.get("x-support-secret");
        if (supportSecret && got !== supportSecret) {
            return json({ error: "forbidden" }, 403);
        }

        const body = await req.json().catch(() => ({}));
        const ticketId = String(body?.ticket_id ?? "");
        if (!ticketId) return json({ error: "invalid_ticket_id" }, 400);

        // Feature flag gate
        const { data: flag } = await admin
            .from("feature_flags")
            .select("enabled,rollout_percentage")
            .eq("name", "ai.support_copilot")
            .single();
        if (!flag?.enabled) {
            return json({ ok: true, skipped: true, reason: "flag_disabled" });
        }

        const { data: ticket, error: tErr } = await admin
            .from("support_tickets")
            .select("id, subject, body, created_by, trip_id, booking_id, created_at")
            .eq("id", ticketId)
            .single();
        if (tErr || !ticket) return json({ error: "ticket_not_found" }, 404);

        const out = classify(String(ticket.subject ?? ""), String(ticket.body ?? ""));

        const { error: oErr } = await admin.from("support_ai_outputs").insert({
            ticket_id: ticketId,
            model_version: "heuristic_v1",
            classification: out.classification,
            sentiment: out.sentiment,
            summary: out.summary,
            suggested_reply: out.suggestedReply,
            action_tags: out.action_tags,
            meta: { mode: "rules", safe: true },
        });
        if (oErr) return json({ error: "support_ai_insert_failed", details: oErr.message }, 500);

        await admin.from("event_log").insert({
            actor_id: null,
            event_type: "support_copilot_ran",
            entity_type: "support_ticket",
            entity_id: ticketId,
            payload: { model: "heuristic_v1", classification: out.classification },
        });

        return json({ ok: true, ticket_id: ticketId, ...out, model_version: "heuristic_v1" });
    } catch (e) {
        return json({ error: (e as Error).message }, 500);
    }
});
