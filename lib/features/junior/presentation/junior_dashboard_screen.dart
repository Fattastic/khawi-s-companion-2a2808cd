import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'controllers/junior_dashboard_controller.dart';
import 'package:khawi_flutter/features/junior/domain/junior.dart';
import 'package:khawi_flutter/core/widgets/khawi_button.dart';
import 'package:khawi_flutter/core/motion/khawi_motion.dart';
import 'package:khawi_flutter/core/theme/app_theme.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';

class JuniorDashboardScreen extends ConsumerWidget {
  const JuniorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(juniorDashboardControllerProvider);
    final controller = ref.read(juniorDashboardControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.juniorDashboardTitle ?? 'Khawi Junior')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddKidDialog(context, controller),
        child: const Icon(Icons.add),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                KhawiMotion.fadeIn(
                  Text(
                    l10n?.juniorMyKids ?? "My Kids",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (state.kids.isEmpty)
                  KhawiMotion.fadeIn(
                    Text(l10n?.juniorNoKids ?? "No kids added yet."),
                    duration: const Duration(milliseconds: 400),
                  )
                else
                  ...state.kids.asMap().entries.map((entry) {
                    final index = entry.key;
                    final kid = entry.value;
                    return KhawiMotion.fadeIn(
                      _buildKidCard(context, kid),
                      duration: Duration(milliseconds: 400 + (index * 100)),
                    );
                  }),
                const SizedBox(height: 24),
                KhawiMotion.fadeIn(
                  Text(
                    l10n?.juniorActiveRuns ?? "Active Runs",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  duration: const Duration(milliseconds: 600),
                ),
                const SizedBox(height: 8),
                KhawiMotion.fadeIn(
                  Center(
                    child: Text(
                      l10n?.juniorFeatureInProgress ??
                          "Feature In Progress... use 'Offer Ride' for now.",
                    ),
                  ),
                  duration: const Duration(milliseconds: 700),
                ),
              ],
            ),
    );
  }

  Widget _buildKidCard(BuildContext context, Kid kid) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.face)),
        title: Text(kid.name),
        subtitle: Text('${kid.age} years old'),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            // Edit kid
          },
        ),
      ),
    );
  }

  Future<void> _showAddKidDialog(
    BuildContext context,
    JuniorDashboardController controller,
  ) async {
    final l10n = AppLocalizations.of(context);
    final nameCtl = TextEditingController();
    final ageCtl = TextEditingController();
    try {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n?.juniorAddKid ?? "Add Kid"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtl,
                decoration: InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ageCtl,
                decoration: InputDecoration(
                  labelText: "Age",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            KhawiButton(
              onPressed: () => Navigator.pop(ctx),
              text: "Cancel",
              type: AppButtonType.text,
            ),
            KhawiButton(
              onPressed: () {
                final age = int.tryParse(ageCtl.text);
                if (nameCtl.text.isNotEmpty && age != null) {
                  controller.addKid(nameCtl.text, age);
                  Navigator.pop(ctx);
                }
              },
              text: "Add",
            ),
          ],
        ),
      );
    } finally {
      nameCtl.dispose();
      ageCtl.dispose();
    }
  }
}
