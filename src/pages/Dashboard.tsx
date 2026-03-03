import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { StatCard } from "@/components/dashboard/StatCard";
import { Car, Users, AlertTriangle, Star, Flag, Shield } from "lucide-react";

interface Stats {
  trips: number;
  users: number;
  sosOpen: number;
  reports: number;
}

export default function Dashboard() {
  const [stats, setStats] = useState<Stats>({ trips: 0, users: 0, sosOpen: 0, reports: 0 });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function load() {
      const [tripsRes, usersRes, sosRes, reportsRes] = await Promise.all([
        supabase.from("trips").select("id", { count: "exact", head: true }),
        supabase.from("profiles").select("id", { count: "exact", head: true }),
        supabase.from("sos_events").select("id", { count: "exact", head: true }).eq("status", "open"),
        supabase.from("reports").select("id", { count: "exact", head: true }).eq("status", "open"),
      ]);
      setStats({
        trips: tripsRes.count ?? 0,
        users: usersRes.count ?? 0,
        sosOpen: sosRes.count ?? 0,
        reports: reportsRes.count ?? 0,
      });
      setLoading(false);
    }
    load();
  }, []);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold tracking-tight">Dashboard</h1>
        <p className="text-sm text-muted-foreground">Overview of your Khawi platform</p>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard
          title="Total Trips"
          value={loading ? "…" : stats.trips}
          icon={Car}
          subtitle="All time"
        />
        <StatCard
          title="Registered Users"
          value={loading ? "…" : stats.users}
          icon={Users}
          subtitle="All profiles"
        />
        <StatCard
          title="Open SOS"
          value={loading ? "…" : stats.sosOpen}
          icon={AlertTriangle}
          subtitle="Needs attention"
          className={stats.sosOpen > 0 ? "border-destructive/40" : ""}
        />
        <StatCard
          title="Open Reports"
          value={loading ? "…" : stats.reports}
          icon={Flag}
          subtitle="Pending review"
        />
      </div>

      <div className="rounded-xl border bg-card p-6 shadow-sm">
        <h3 className="text-sm font-semibold text-muted-foreground uppercase tracking-wider mb-4">Quick Info</h3>
        <p className="text-sm text-muted-foreground">
          Welcome to Khawi Companion. Use the sidebar to manage trips, users, SOS events, reports, and trust scores.
          Data is pulled live from your Supabase backend.
        </p>
      </div>
    </div>
  );
}
