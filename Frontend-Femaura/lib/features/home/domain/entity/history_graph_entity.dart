// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:femaura/core/utils/entity.dart';

class HistoryGraphEntity extends Entity {
  const HistoryGraphEntity({
    this.labels = const [],
    this.cycleLength = const [],
    this.periodLength = const [],
    this.averageCycle = 0.0,
    this.averagePeriod = 0.0,
    this.chartType = '',
    this.chartTitle = '',
    this.cycleUnit = '',
    this.lastUpdated = '',
  });

  final List<String> labels;
  final List<int> cycleLength;
  final List<int> periodLength;
  final double averageCycle;
  final double averagePeriod;
  final String chartType;
  final String chartTitle;
  final String cycleUnit;
  final String lastUpdated;

  @override
  HistoryGraphEntity copyWith({
    List<String>? labels,
    List<int>? cycleLength,
    List<int>? periodLength,
    double? averageCycle,
    double? averagePeriod,
    String? chartType,
    String? chartTitle,
    String? cycleUnit,
    String? lastUpdated,
  }) {
    return HistoryGraphEntity(
      labels: labels ?? this.labels,
      cycleLength: cycleLength ?? this.cycleLength,
      periodLength: periodLength ?? this.periodLength,
      averageCycle: averageCycle ?? this.averageCycle,
      averagePeriod: averagePeriod ?? this.averagePeriod,
      chartType: chartType ?? this.chartType,
      chartTitle: chartTitle ?? this.chartTitle,
      cycleUnit: cycleUnit ?? this.cycleUnit,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object> get props => [
    labels,
    cycleLength,
    periodLength,
    averageCycle,
    averagePeriod,
    chartType,
    chartTitle,
    cycleUnit,
    lastUpdated,
  ];
}
