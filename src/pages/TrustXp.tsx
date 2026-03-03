import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Shield, Star } from "lucide-react";
import { StatCard } from "@/components/dashboard/StatCard";

interface TrustProfile {
  user_id: string;
  trust_score: number;
  trust_badge: string | null;
  junior_trusted: boolean;
}

export default function TrustXp() {
  const [profiles, setProfiles] = useState<TrustProfile[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase
      .from("trust_profiles")
      .select("user_id, trust_score, trust_badge, junior_trusted")
      .order("trust_score", { ascending: false })
      .limit(50)
      .then(({ data }) => {
        setProfiles(data ?? []);
        setLoading(false);
      });
  }, []);

  const avgScore = profiles.length
    ? (profiles.reduce((a, b) => a + b.trust_score, 0) / profiles.length).toFixed(1)
    : "—";

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold tracking-tight">Trust & XP</h1>
        <p className="text-sm text-muted-foreground">Trust scores and gamification overview</p>
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        <StatCard title="Trust Profiles" value={loading ? "…" : profiles.length} icon={Shield} />
        <StatCard title="Avg Trust Score" value={loading ? "…" : avgScore} icon={Star} />
        <StatCard
          title="Junior Trusted"
          value={loading ? "…" : profiles.filter((p) => p.junior_trusted).length}
          icon={Shield}
        />
      </div>

      <div className="rounded-xl border bg-card shadow-sm overflow-auto">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>User ID</TableHead>
              <TableHead>Score</TableHead>
              <TableHead>Badge</TableHead>
              <TableHead>Junior Trusted</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {loading ? (
              <TableRow>
                <TableCell colSpan={4} className="text-center py-8 text-muted-foreground">Loading…</TableCell>
              </TableRow>
            ) : profiles.length === 0 ? (
              <TableRow>
                <TableCell colSpan={4} className="text-center py-8 text-muted-foreground">No trust profiles</TableCell>
              </TableRow>
            ) : (
              profiles.map((p) => (
                <TableRow key={p.user_id}>
                  <TableCell className="text-xs font-mono text-muted-foreground">{p.user_id.slice(0, 8)}…</TableCell>
                  <TableCell className="text-sm font-semibold">{p.trust_score.toFixed(1)}</TableCell>
                  <TableCell>
                    {p.trust_badge ? (
                      <Badge variant="secondary" className="text-xs capitalize">{p.trust_badge}</Badge>
                    ) : (
                      <span className="text-xs text-muted-foreground">—</span>
                    )}
                  </TableCell>
                  <TableCell>
                    {p.junior_trusted ? (
                      <Badge className="bg-success/10 text-success border-0 text-xs">Yes</Badge>
                    ) : (
                      <span className="text-xs text-muted-foreground">No</span>
                    )}
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}
