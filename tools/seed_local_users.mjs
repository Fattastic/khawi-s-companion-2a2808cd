import { createClient } from "@supabase/supabase-js";

const SUPABASE_URL = process.env.SUPABASE_URL;
const SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SERVICE_ROLE_KEY) {
    console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY");
    process.exit(1);
}

const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

const users = [
    { email: "p1@khawi.local", password: "Passw0rd!123", full_name: "Passenger One", role: "passenger", gender: "male", neighborhood_id: "n1", is_verified: false },
    { email: "p2@khawi.local", password: "Passw0rd!123", full_name: "Passenger Two", role: "passenger", gender: "female", neighborhood_id: "n1", is_verified: false },
    { email: "d1@khawi.local", password: "Passw0rd!123", full_name: "Driver One", role: "driver", gender: "male", neighborhood_id: "n1", is_verified: true },
    { email: "d2@khawi.local", password: "Passw0rd!123", full_name: "Driver Two", role: "driver", gender: "female", neighborhood_id: "n2", is_verified: true },
];

for (const u of users) {
    // Create auth user (id auto)
    const { data, error } = await admin.auth.admin.createUser({
        email: u.email,
        password: u.password,
        email_confirm: true,
    });

    if (error) {
        console.error("createUser failed:", u.email, error.message);
        continue;
    }

    const userId = data.user.id;

    // Upsert profile to match your schema
    const { error: pErr } = await admin.from("profiles").upsert({
        id: userId,
        full_name: u.full_name,
        role: u.role,
        gender: u.gender,
        neighborhood_id: u.neighborhood_id,
        is_verified: u.is_verified,
        is_premium: false,
        total_xp: 0,
        redeemable_xp: 0,
        xp_throttle: false,
        xp_throttle_until: null,
    });

    if (pErr) console.error("profile upsert failed:", u.email, pErr.message);
    else console.log("Seeded:", u.email, userId);
}
