import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { StatCard } from "@/components/dashboard/StatCard";
import { Car, Users, Star, BarChart3 } from "lucide-react";

export default function Analytics() {
  const [xpEvents, setXpEvents] = useState(0);
  const [featureFlags, setFeatureFlags] = useState(0);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      supabase.from("xp_events").select("id", { count: "exact", head: true }),
      supabase.from("feature_flags").select("name", { count: "exact", head: true }),
    ]).then(([xpRes, ffRes]) => {
      setXpEvents(xpRes.count ?? 0);
      setFeatureFlags(ffRes.count ?? 0);
      setLoading(false);
    });
  }, []);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold tracking-tight">Analytics</h1>
        <p className="text-sm text-muted-foreground">Platform metrics and insights</p>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <StatCard title="XP Events" value={loading ? "…" : xpEvents} icon={Star} subtitle="Total XP transactions" />
        <StatCard title="Feature Flags" value={loading ? "…" : featureFlags} icon={BarChart3} subtitle="Configured flags" />
      </div>

      <div className="rounded-xl border bg-card p-6 shadow-sm">
        <h3 className="text-sm font-semibold text-muted-foreground uppercase tracking-wider mb-3">Coming Soon</h3>
        <p className="text-sm text-muted-foreground">
          Charts for trip volume over time, user growth, XP distribution, and conversion funnels will be added here.
        </p>
      </div>
    </div>
  );
}
