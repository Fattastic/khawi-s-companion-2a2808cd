import { useEffect, useState } from "react";
import { supabase } from "@/integrations/supabase/client";
import { Badge } from "@/components/ui/badge";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { format } from "date-fns";

interface Trip {
  id: string;
  origin_label: string | null;
  dest_label: string | null;
  departure_time: string;
  status: string;
  seats_total: number;
  seats_available: number;
  women_only: boolean;
  is_kids_ride: boolean;
}

const statusColor: Record<string, string> = {
  planned: "bg-primary/10 text-primary",
  active: "bg-success/10 text-success",
  completed: "bg-muted text-muted-foreground",
  cancelled: "bg-destructive/10 text-destructive",
};

export default function Trips() {
  const [trips, setTrips] = useState<Trip[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase
      .from("trips")
      .select("id, origin_label, dest_label, departure_time, status, seats_total, seats_available, women_only, is_kids_ride")
      .order("departure_time", { ascending: false })
      .limit(50)
      .then(({ data }) => {
        setTrips(data ?? []);
        setLoading(false);
      });
  }, []);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold tracking-tight">Trips</h1>
        <p className="text-sm text-muted-foreground">Recent trips across the platform</p>
      </div>

      <div className="rounded-xl border bg-card shadow-sm overflow-auto">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Route</TableHead>
              <TableHead>Departure</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Seats</TableHead>
              <TableHead>Tags</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {loading ? (
              <TableRow>
                <TableCell colSpan={5} className="text-center py-8 text-muted-foreground">Loading…</TableCell>
              </TableRow>
            ) : trips.length === 0 ? (
              <TableRow>
                <TableCell colSpan={5} className="text-center py-8 text-muted-foreground">No trips found</TableCell>
              </TableRow>
            ) : (
              trips.map((trip) => (
                <TableRow key={trip.id}>
                  <TableCell className="max-w-[200px]">
                    <p className="truncate font-medium text-sm">{trip.origin_label ?? "—"}</p>
                    <p className="truncate text-xs text-muted-foreground">→ {trip.dest_label ?? "—"}</p>
                  </TableCell>
                  <TableCell className="text-sm">
                    {format(new Date(trip.departure_time), "MMM d, HH:mm")}
                  </TableCell>
                  <TableCell>
                    <span className={`inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium ${statusColor[trip.status] ?? ""}`}>
                      {trip.status}
                    </span>
                  </TableCell>
                  <TableCell className="text-sm">
                    {trip.seats_available}/{trip.seats_total}
                  </TableCell>
                  <TableCell className="space-x-1">
                    {trip.women_only && <Badge variant="outline" className="text-xs">Women</Badge>}
                    {trip.is_kids_ride && <Badge variant="outline" className="text-xs">Kids</Badge>}
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
