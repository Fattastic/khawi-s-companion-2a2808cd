import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_section_header.dart';
import 'widgets/dependent_status_card.dart';
import '../domain/junior.dart';

class GuardianHubScreen extends ConsumerWidget {
  const GuardianHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock data for now
    final dependents = [
      const Kid(
          id: 'k1',
          parentId: 'u1',
          name: 'Omar',
          schoolName: 'Al-Rowad School',),
      const Kid(
          id: 'k2',
          parentId: 'u1',
          name: 'Sara',
          schoolName: 'King Saud University',),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardian Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          children: [
            const AppSectionHeader(title: 'Active Commutes'),
            const SizedBox(height: 12),
            DependentStatusCard(
              kid: dependents[0],
              activeRun: JuniorRun(
                id: 'r1',
                kidId: 'k1',
                parentId: 'u1',
                status: 'in_transit',
                pickupLat: 0,
                pickupLng: 0,
                dropoffLat: 0,
                dropoffLng: 0,
                pickupTime: DateTime.now(),
              ),
            ),
            const SizedBox(height: 24),
            const AppSectionHeader(title: 'All Dependents'),
            const SizedBox(height: 12),
            ...dependents.map((kid) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DependentStatusCard(kid: kid),
                ),),
          ],
        ),
      ),
    );
  }
}
