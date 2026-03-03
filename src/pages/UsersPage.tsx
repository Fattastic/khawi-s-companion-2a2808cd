import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { format } from "date-fns";

interface Profile {
  id: string;
  full_name: string;
  role: string;
  is_verified: boolean;
  is_premium: boolean;
  total_xp: number;
  created_at: string;
  gender: string | null;
}

export default function UsersPage() {
  const [users, setUsers] = useState<Profile[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase
      .from("profiles")
      .select("id, full_name, role, is_verified, is_premium, total_xp, created_at, gender")
      .order("created_at", { ascending: false })
      .limit(50)
      .then(({ data }) => {
        setUsers(data ?? []);
        setLoading(false);
      });
  }, []);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold tracking-tight">Users</h1>
        <p className="text-sm text-muted-foreground">Registered profiles on the platform</p>
      </div>

      <div className="rounded-xl border bg-card shadow-sm overflow-auto">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Name</TableHead>
              <TableHead>Role</TableHead>
              <TableHead>XP</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Joined</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {loading ? (
              <TableRow>
                <TableCell colSpan={5} className="text-center py-8 text-muted-foreground">Loading…</TableCell>
              </TableRow>
            ) : users.length === 0 ? (
              <TableRow>
                <TableCell colSpan={5} className="text-center py-8 text-muted-foreground">No users found</TableCell>
              </TableRow>
            ) : (
              users.map((u) => (
                <TableRow key={u.id}>
                  <TableCell className="font-medium text-sm">{u.full_name || "—"}</TableCell>
                  <TableCell>
                    <Badge variant="secondary" className="text-xs capitalize">{u.role}</Badge>
                  </TableCell>
                  <TableCell className="text-sm font-mono">{u.total_xp}</TableCell>
                  <TableCell className="space-x-1">
                    {u.is_verified && <Badge className="bg-success/10 text-success text-xs border-0">Verified</Badge>}
                    {u.is_premium && <Badge className="bg-accent/10 text-accent text-xs border-0">Premium</Badge>}
                  </TableCell>
                  <TableCell className="text-sm text-muted-foreground">
                    {format(new Date(u.created_at), "MMM d, yyyy")}
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
