import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:khawi_flutter/features/requests/presentation/controllers/requests_center_controller.dart';
import 'package:khawi_flutter/features/requests/domain/trip_request.dart';

enum RequestsMode { sent, received }

class RequestsCenterScreen extends ConsumerWidget {
  final RequestsMode mode;

  const RequestsCenterScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      initialIndex: mode == RequestsMode.received ? 0 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Requests Center'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Received'),
              Tab(text: 'Sent'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _RequestsList(mode: RequestsMode.received),
            _RequestsList(mode: RequestsMode.sent),
          ],
        ),
      ),
    );
  }
}

class _RequestsList extends ConsumerWidget {
  final RequestsMode mode;
  const _RequestsList({required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(requestsCenterControllerProvider(mode));
    final controller = ref.read(
      requestsCenterControllerProvider(mode).notifier,
    );
    final theme = Theme.of(context);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}'));
    }

    if (state.requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              mode == RequestsMode.received
                  ? 'No incoming requests.'
                  : 'No sent requests.',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.requests.length,
      itemBuilder: (context, index) {
        final req = state.requests[index];
        return _RequestCard(
          key: ValueKey(req.id),
          req: req,
          mode: mode,
          controller: controller,
          theme: theme,
        );
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  final TripRequest req;
  final RequestsMode mode;
  final RequestsCenterController controller;
  final ThemeData theme;

  const _RequestCard({
    super.key,
    required this.req,
    required this.mode,
    required this.controller,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isSent = mode == RequestsMode.sent;
    final dateStr = DateFormat('MMM d, h:mm a').format(req.createdAt);

    Color statusColor = Colors.grey;
    if (req.status == RequestStatus.accepted) statusColor = Colors.green;
    if (req.status == RequestStatus.declined) statusColor = Colors.red;
    if (req.status == RequestStatus.pending) statusColor = Colors.orange;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.primaryColor.withValues(
                            alpha: 0.1,
                          ),
                          child: Icon(
                            isSent
                                ? Icons.outbox_outlined
                                : Icons.move_to_inbox_outlined,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSent ? 'To Driver' : 'From Passenger',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              dateStr,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _StatusBadge(status: req.status, color: statusColor),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.trip_origin,
                      size: 16,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Trip ${req.tripId.length > 8 ? req.tripId.substring(0, 8) : req.tripId}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (req.status == RequestStatus.pending)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isSent)
                    TextButton.icon(
                      onPressed: () => controller.cancel(req.id),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Cancel'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  if (!isSent) ...[
                    TextButton(
                      onPressed: () => controller.decline(req.id),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                      child: const Text('Decline'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => controller.accept(req.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Accept'),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final RequestStatus status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
