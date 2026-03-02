/// Persona Panel - Simulate different user roles and states.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/features/profile/domain/profile.dart'; // Verify this import path
import 'package:khawi_flutter/state/providers.dart';

class PersonaPanel extends ConsumerWidget {
  const PersonaPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentOverride = ref.watch(debugProfileOverrideProvider);
    final activeProfile = ref.watch(myProfileProvider).valueOrNull;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatusCard(activeProfile, currentOverride != null),
        const SizedBox(height: 16),
        const Text(
          'Simulate Logic',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PersonaChip(
              label: 'Real User',
              icon: Icons.person_off,
              isSelected: currentOverride == null,
              onTap: () =>
                  ref.read(debugProfileOverrideProvider.notifier).state = null,
            ),
            _PersonaChip(
              label: 'Passenger (Standard)',
              icon: Icons.person,
              isSelected: currentOverride?.role == UserRole.passenger &&
                  !currentOverride!.isPremium,
              onTap: () =>
                  _setPersona(ref, UserRole.passenger, isPremium: false),
            ),
            _PersonaChip(
              label: 'Passenger (Premium)',
              icon: Icons.diamond,
              isSelected: currentOverride?.role == UserRole.passenger &&
                  currentOverride!.isPremium,
              onTap: () =>
                  _setPersona(ref, UserRole.passenger, isPremium: true),
            ),
            _PersonaChip(
              label: 'Driver (Verified)',
              icon: Icons.drive_eta,
              isSelected: currentOverride?.role == UserRole.driver &&
                  currentOverride!.isVerified,
              onTap: () => _setPersona(ref, UserRole.driver, isVerified: true),
            ),
            _PersonaChip(
              label: 'Driver (Unverified)',
              icon: Icons.drive_eta_outlined,
              isSelected: currentOverride?.role == UserRole.driver &&
                  !currentOverride!.isVerified,
              onTap: () => _setPersona(ref, UserRole.driver, isVerified: false),
            ),
            /*_PersonaChip(
              label: 'Junior Parent',
              icon: Icons.family_restroom,
              isSelected: currentOverride?.role == UserRole.parent,
              onTap: () => _setPersona(ref, UserRole.parent),
            ),*/
            _PersonaChip(
              label: 'Junior',
              icon: Icons.child_care,
              isSelected: currentOverride?.role == UserRole.junior,
              onTap: () => _setPersona(ref, UserRole.junior),
            ),
          ],
        ),
      ],
    );
  }

  void _setPersona(
    WidgetRef ref,
    UserRole role, {
    bool isPremium = false,
    bool isVerified = true,
  }) {
    final mockId =
        'simulated_${role.name}_${DateTime.now().millisecondsSinceEpoch}';
    final profile = Profile(
      id: mockId,
      fullName: 'Simulated ${role.name.toUpperCase()}',
      role: role,
      isPremium: isPremium,
      isVerified: isVerified,
      redeemableXp: 1000,
      totalXp: 2500,
      avatarUrl: null,
    );
    ref.read(debugProfileOverrideProvider.notifier).state = profile;
  }

  Widget _buildStatusCard(Profile? profile, bool isSimulated) {
    if (profile == null) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.error_outline, color: Colors.orange),
          title: Text('No Active Profile'),
        ),
      );
    }

    return Card(
      color: isSimulated ? Colors.amber.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  isSimulated ? Icons.smart_toy : Icons.person,
                  color: isSimulated ? Colors.deepOrange : Colors.blue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'ID: ${profile.id.substring(0, 8)}...',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (isSimulated)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'SIMULATED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatusItem('Role', profile.role?.name ?? 'None'),
                _StatusItem(
                  'Premium',
                  profile.isPremium ? 'YES' : 'NO',
                  isAffirmative: profile.isPremium,
                ),
                _StatusItem(
                  'Verified',
                  profile.isVerified ? 'YES' : 'NO',
                  isAffirmative: profile.isVerified,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String label;
  final String value;
  final bool? isAffirmative;

  const _StatusItem(this.label, this.value, {this.isAffirmative});

  @override
  Widget build(BuildContext context) {
    Color? color;
    if (isAffirmative != null) {
      color = isAffirmative! ? Colors.green.shade700 : Colors.grey;
    }

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

class _PersonaChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PersonaChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: isSelected,
      showCheckmark: false,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : null),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      onSelected: (_) => onTap(),
    );
  }
}
