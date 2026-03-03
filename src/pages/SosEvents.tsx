import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { format } from "date-fns";
import { AlertTriangle } from "lucide-react";

interface SosEvent {
  id: string;
  kind: string;
  status: string;
  severity: number;
  message: string | null;
  lat: number;
  lng: number;
  created_at: string;
}

export default function SosEvents() {
  const [events, setEvents] = useState<SosEvent[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase
      .from("sos_events")
      .select("id, kind, status, severity, message, lat, lng, created_at")
      .order("created_at", { ascending: false })
      .limit(50)
      .then(({ data }) => {
        setEvents(data ?? []);
        setLoading(false);
      });
  }, []);

  const severityLabel = (s: number) => {
    if (s >= 4) return { text: "Critical", cls: "bg-destructive/10 text-destructive" };
    if (s >= 3) return { text: "High", cls: "bg-warning/10 text-warning" };
    return { text: "Medium", cls: "bg-muted text-muted-foreground" };
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3">
        <AlertTriangle className="h-6 w-6 text-destructive" />
        <div>
          <h1 className="text-2xl font-bold tracking-tight">SOS Events</h1>
          <p className="text-sm text-muted-foreground">Emergency and safety alerts</p>
        </div>
      </div>

      <div className="rounded-xl border bg-card shadow-sm overflow-auto">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Type</TableHead>
              <TableHead>Severity</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Message</TableHead>
              <TableHead>Location</TableHead>
              <TableHead>Time</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {loading ? (
              <TableRow>
                <TableCell colSpan={6} className="text-center py-8 text-muted-foreground">Loading…</TableCell>
              </TableRow>
            ) : events.length === 0 ? (
              <TableRow>
                <TableCell colSpan={6} className="text-center py-8 text-muted-foreground">No SOS events</TableCell>
              </TableRow>
            ) : (
              events.map((e) => {
                const sev = severityLabel(e.severity);
                return (
                  <TableRow key={e.id}>
                    <TableCell className="text-sm font-medium capitalize">{e.kind}</TableCell>
                    <TableCell>
                      <span className={`inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium ${sev.cls}`}>
                        {sev.text}
                      </span>
                    </TableCell>
                    <TableCell>
                      <Badge variant={e.status === "open" ? "destructive" : "secondary"} className="text-xs">
                        {e.status}
                      </Badge>
                    </TableCell>
                    <TableCell className="max-w-[200px] truncate text-sm">{e.message ?? "—"}</TableCell>
                    <TableCell className="text-xs font-mono text-muted-foreground">
                      {e.lat.toFixed(4)}, {e.lng.toFixed(4)}
                    </TableCell>
                    <TableCell className="text-sm text-muted-foreground">
                      {format(new Date(e.created_at), "MMM d, HH:mm")}
                    </TableCell>
                  </TableRow>
                );
              })
            )}
          </TableBody>
        </Table>
      </div>
    </div>
  );
}
