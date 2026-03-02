import 'package:flutter/material.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/junior.dart';

class DependentStatusCard extends StatelessWidget {
  final Kid kid;
  final JuniorRun? activeRun;

  const DependentStatusCard({
    super.key,
    required this.kid,
    this.activeRun,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveRun = activeRun != null;
    final statusColor = _getStatusColor(activeRun?.status);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    kid.avatarUrl != null ? NetworkImage(kid.avatarUrl!) : null,
                child: kid.avatarUrl == null ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kid.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      kid.schoolName ?? 'No school assigned',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (hasActiveRun)
                _buildStatusBadge(context, activeRun!.status, statusColor),
            ],
          ),
          if (hasActiveRun) ...[
            const Divider(height: 24),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'En Route to ${kid.schoolName}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('TRACK LIVE'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'in_transit':
        return Colors.blue;
      case 'arrived':
        return Colors.green;
      case 'delayed':
        return Colors.red;
      case 'planned':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
