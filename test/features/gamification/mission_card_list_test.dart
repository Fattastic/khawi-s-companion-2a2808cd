import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khawi_flutter/features/gamification/presentation/mission_card_list.dart';
import 'package:khawi_flutter/features/challenges/data/challenges_repository.dart';
import 'package:khawi_flutter/core/widgets/app_empty_state.dart';
import 'package:khawi_flutter/core/widgets/app_skeleton_loader.dart';
import 'package:khawi_flutter/core/widgets/app_card.dart';
import 'package:khawi_flutter/core/localization/app_localizations.dart';

void main() {
  Widget buildTestWidget(AsyncValue<List<Challenge>> overrideValue) {
    return ProviderScope(
      overrides: [
        weeklyChallengesProvider
            .overrideWith((ref) async => overrideValue.value ?? []),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: MissionCardList()),
      ),
    );
  }

  testWidgets('shows AppSkeletonLoader when loading', (tester) async {
    await tester.pumpWidget(buildTestWidget(const AsyncValue.loading()));
    expect(find.byType(AppSkeletonLoader), findsWidgets);
  });

  testWidgets('shows AppEmptyState when no challenges', (tester) async {
    await tester.pumpWidget(buildTestWidget(const AsyncValue.data([])));
    await tester.pumpAndSettle();
    expect(find.byType(AppEmptyState), findsOneWidget);
  });

  testWidgets('renders AppCard mission list when challenges exist',
      (tester) async {
    final challenges = [
      const Challenge(
          id: '1', type: ChallengeType.riyadhExplorer, progress: 0.5,),
      const Challenge(id: '2', type: ChallengeType.ecoPioneer, progress: 0.1),
    ];
    await tester.pumpWidget(buildTestWidget(AsyncValue.data(challenges)));
    await tester.pumpAndSettle();

    expect(find.byType(AppCard), findsNWidgets(2));
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('10%'), findsOneWidget);
  });
}
