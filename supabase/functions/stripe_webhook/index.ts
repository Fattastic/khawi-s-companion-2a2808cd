import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import Stripe from "https://esm.sh/stripe@14.12.0?target=deno";

serve(async (req) => {
    const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY') ?? '', {
        httpClient: Stripe.createFetchHttpClient(),
    });
    const signature = req.headers.get('Stripe-Signature');

    try {
        const body = await req.text();
        const event = stripe.webhooks.constructEvent(
            body,
            signature ?? '',
            Deno.env.get('STRIPE_WEBHOOK_SECRET') ?? ''
        );

        const supabaseAdmin = createClient(
            Deno.env.get('SUPABASE_URL') ?? '',
            Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
        );

        switch (event.type) {
            case 'checkout.session.completed': {
                const session = event.data.object;
                const customerId = session.customer as string;
                const subscriptionId = session.subscription as string;

                await supabaseAdmin
                    .from('profiles')
                    .update({
                        subscription_status: 'active',
                        is_premium: true
                    })
                    .eq('stripe_customer_id', customerId);
                break;
            }
            case 'customer.subscription.deleted': {
                const subscription = event.data.object;
                const customerId = subscription.customer as string;

                await supabaseAdmin
                    .from('profiles')
                    .update({
                        subscription_status: 'inactive',
                        is_premium: false
                    })
                    .eq('stripe_customer_id', customerId);
                break;
            }
        }

        return new Response(JSON.stringify({ received: true }), {
            headers: { 'Content-Type': 'application/json' },
            status: 200,
        });
    } catch (error) {
        return new Response(JSON.stringify({ error: (error as Error).message }), {
            headers: { 'Content-Type': 'application/json' },
            status: 400,
        });
    }
});
