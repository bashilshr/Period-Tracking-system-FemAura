import 'package:femaura/core/utils/spacer.dart';
import 'package:femaura/features/home/domain/entity/history_graph_entity.dart';
import 'package:femaura/features/home/presentation/history/history_view_presenter.dart';
import 'package:femaura/features/home/presentation/main_page/card_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryView extends ConsumerWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entity = ref.watch(historyViewPresenterProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(Dimen.x2),
      child: Column(
        spacing: Dimen.x1,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'History',
                style: theme.textTheme.titleLarge!.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              Text('View your Cycle History'),
              Divider(),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: DataCardWidget(
                  title: 'Average Cycle Length',
                  value: entity.history.avgCycleLength.toString(),
                ),
              ),
              Expanded(
                child: DataCardWidget(
                  title: 'Total Cycles',
                  value: entity.history.totalCycles.toString(),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: DataCardWidget(
                  title: 'Cycle Variability',
                  value: entity.history.cycleVariability.toString(),
                ),
              ),
              Expanded(
                child: DataCardWidget(
                  title: 'Irregularity Level',
                  value: Padding(
                    padding: const EdgeInsets.only(top: Dimen.x1_5),
                    child: Chip(
                      backgroundColor:
                          entity.history.isIrregular
                              ? theme.colorScheme.errorContainer
                              : null,
                      label: Text(
                        entity.history.isIrregular ? 'Irregular' : 'Regular',
                        style:
                            entity.history.isIrregular
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
          HistoryGraphWidget(historyGraph: entity.graph),
          const Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Dimen.x1,
            children: [
              Text('Common Symptoms', style: theme.textTheme.titleMedium),
              Wrap(
                spacing: Dimen.x1,
                runSpacing: Dimen.x1,
                children: [
                  for (final symptom in entity.history.commonSymptoms)
                    Chip(label: Text(symptom)),
                ],
              ),
            ],
          ),
          const Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Dimen.x1,
            children: [
              Text('Common Moods', style: theme.textTheme.titleMedium),
              Wrap(
                spacing: Dimen.x1,
                runSpacing: Dimen.x1,
                children: [
                  for (final mood in entity.history.commonMoods)
                    Chip(label: Text(mood)),
                ],
              ),
            ],
          ),
          const Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Dimen.x1,
            children: [
              Text(
                'Health Recommendations',
                style: theme.textTheme.titleMedium,
              ),
              Wrap(
                spacing: Dimen.x1,
                runSpacing: Dimen.x1,
                children: [
                  for (final recommendation
                      in entity.history.healthRecommendations)
                    Chip(label: Text(recommendation)),
                ],
              ),
            ],
          ),
          const Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Dimen.x1,
            children: [
              Text('Period History', style: theme.textTheme.titleMedium),
              for (final period in entity.history.periodHistory)
                Card(
                  elevation: 5,
                  child: Container(
                    padding: EdgeInsets.all(Dimen.x1),
                    child: Column(
                      spacing: Dimen.x1,
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Start: ${period.startDate}'),
                                Text('End: ${period.endDate}'),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              spacing: Dimen.x1,
                              children: [
                                Text(
                                  'Cycle Length: ${period.days}',
                                  style: theme.textTheme.labelMedium,
                                ),
                                if (period.isIrregular)
                                  Chip(
                                    label: Text(
                                      'Irregular',
                                      style: theme.textTheme.labelMedium,
                                    ),
                                    color: WidgetStatePropertyAll(
                                      theme.colorScheme.errorContainer,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        if (period.symptoms.isNotEmpty)
                          Column(
                            children: [
                              Text(
                                'Symptoms',
                                style: theme.textTheme.labelMedium,
                              ),
                              Divider(),
                              Wrap(
                                spacing: Dimen.x1,
                                runSpacing: Dimen.x1,
                                children: [
                                  for (final symptom in period.symptoms)
                                    Chip(label: Text(symptom)),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class HistoryGraphWidget extends StatelessWidget {
  const HistoryGraphWidget({
    super.key,
    this.historyGraph = const HistoryGraphEntity(),
  });
  final HistoryGraphEntity historyGraph;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: BarChart(
        BarChartData(
          maxY:
              historyGraph.cycleLength.isEmpty
                  ? null
                  : historyGraph.cycleLength
                      .reduce((a, b) => a > b ? a : b)
                      .toDouble(),

          barGroups:
              historyGraph.cycleLength.indexed
                  .map(
                    (length) => BarChartGroupData(
                      x: length.$1,
                      barRods: [BarChartRodData(toY: length.$2.toDouble())],
                    ),
                  )
                  .toList(),

          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles()),
            rightTitles: AxisTitles(sideTitles: SideTitles()),
            leftTitles: AxisTitles(
              axisNameWidget: Text('Cycle Length'),
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget:
                    (value, meta) => SideTitleWidget(
                      meta: meta,
                      space: 2,
                      child: Text(value.toInt().toString()),
                    ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget:
                    (value, meta) => SideTitleWidget(
                      meta: meta,
                      space: 2,
                      child: Text(_getTitle(value.toInt())),
                    ),
              ),
            ),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem:
                  (groupData, x, rodData, y) => BarTooltipItem(
                    '${_getLabel(x.toInt())}\n${groupData.barRods.first.toY.toInt()} days',
                    const TextStyle(),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTitle(int value) {
    final label = historyGraph.labels.elementAt(value.toInt());
    final parts = label.split(' ');
    return parts.sublist(0, 2).join(' ');
  }

  String _getLabel(int value) {
    final label = historyGraph.labels.elementAt(value.toInt());
    final parts = label.split(' ');
    return parts.sublist(2, 4).join(' ');
  }
}
