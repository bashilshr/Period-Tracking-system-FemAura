import 'package:femaura/core/utils/spacer.dart';
import 'package:femaura/features/home/presentation/main_page/card_view.dart';
import 'package:femaura/features/home/presentation/main_page/main_page_presenter.dart';
import 'package:femaura/routing/femaura_router.dart';
import 'package:femaura/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MainPageView extends ConsumerWidget {
  const MainPageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(Dimen.x2),
      child: Column(
        spacing: Dimen.x1,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM d, yyyy').format(DateTime.now()),
                style: theme.textTheme.titleLarge,
              ),
              IconButton(
                onPressed: () => ref.read(routerProvider).go(Routes.settings),
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          Divider(),
          Center(child: DayCountWidget()),
          DailyInsightWidget(),
        ],
      ),
    );
  }
}

class DayCountWidget extends ConsumerWidget {
  const DayCountWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entity = ref.watch(mainPagePresenterProvider);

    final hasActiveCycle =
        entity.phasePrediction.message?.toLowerCase().contains(
          'no active cycle',
        ) ??
        false;

    return Column(
      spacing: Dimen.x2,
      children: [
        if (!hasActiveCycle)
          Text(
            'Current Phase: ${entity.phasePrediction.currentPhase}',
            style: theme.textTheme.labelLarge,
          ),
        if (!hasActiveCycle)
          Text(
            'Next Phase: ${entity.phasePrediction.nextPhase}',
            style: theme.textTheme.labelLarge,
          ),
        hasActiveCycle
            ? Text(
              'No Active Cycle Found. Please add your previous cycle or Start a new cycle',
            )
            : Card(
              child: Padding(
                padding: EdgeInsets.all(Dimen.x2),
                child: Column(
                  spacing: Dimen.x2,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Day', style: theme.textTheme.titleLarge),
                    Text(
                      '${entity.phasePrediction.currentDay}',
                      style: theme.textTheme.displayLarge,
                    ),
                    Text('Day for: Period', style: theme.textTheme.labelLarge),
                    ElevatedButton(
                      onPressed:
                          () => ref.read(routerProvider).go(Routes.logCycle),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: Dimen.x2_5,
                          horizontal: Dimen.x6,
                        ),
                        backgroundColor: theme.colorScheme.onPrimary,
                        textStyle: theme.textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      child: const Text('Log Period'),
                    ),
                    if (!entity.phasePrediction.loggedToday)
                      ElevatedButton(
                        onPressed:
                            () => ref.read(routerProvider).go(Routes.logCycle),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: Dimen.x2_5,
                            horizontal: Dimen.x6,
                          ),
                          backgroundColor: theme.colorScheme.onPrimary,
                          textStyle: theme.textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        child: const Text('Log your Mood today'),
                      ),
                  ],
                ),
              ),
            ),
        if (hasActiveCycle)
          Row(
            spacing: Dimen.x2,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => ref.read(routerProvider).go(Routes.logCycle),
                child: Text('Log New Period'),
              ),
              ElevatedButton(
                onPressed:
                    () => ref.read(routerProvider).go(Routes.previousLogCycle),
                child: Text('Add Previous Cycle'),
              ),
            ],
          ),
      ],
    );
  }
}

class DailyInsightWidget extends ConsumerWidget {
  const DailyInsightWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entity = ref.watch(mainPagePresenterProvider);

    return Column(
      spacing: Dimen.x1,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Daily Insights', style: theme.textTheme.titleLarge),
        Divider(),
        Row(
          children: [
            Expanded(
              child: DataCardWidget(
                title: 'Days Until Next Phase',
                value: entity.phasePrediction.daysUntilNextPhase.toString(),
              ),
            ),
            Expanded(
              child: DataCardWidget(
                title: 'Next Phase',
                value: entity.phasePrediction.nextPhase,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: DataCardWidget(
                title: 'Cycle Length',
                value: '${entity.phasePrediction.cycleLength} days',
              ),
            ),
            Expanded(
              child: DataCardWidget(
                title: 'Mensural Cycle',
                value: Padding(
                  padding: const EdgeInsets.only(top: Dimen.x1_5),
                  child: Chip(
                    backgroundColor:
                        entity.phasePrediction.isIrregular
                            ? theme.colorScheme.errorContainer
                            : null,
                    label: Text(
                      entity.phasePrediction.isIrregular
                          ? 'Irregular'
                          : 'Regular',
                      style:
                          entity.phasePrediction.isIrregular
                              ? theme.textTheme.bodyLarge!.copyWith(
                                color: theme.colorScheme.onError,
                              )
                              : null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Dimen.x1,
          children: [
            Text('Common Moods'),
            Wrap(
              spacing: Dimen.x1,
              runSpacing: Dimen.x1,
              children: [
                for (final mood in entity.phasePrediction.commonMoods)
                  Chip(label: Text(mood)),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Dimen.x1,
          children: [
            Text('Common Symptoms'),
            Wrap(
              spacing: Dimen.x1,
              runSpacing: Dimen.x1,
              children: [
                for (final symptom in entity.phasePrediction.commonSymptoms)
                  Chip(label: Text(symptom)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
