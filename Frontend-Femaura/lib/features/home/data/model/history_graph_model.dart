class HistoryGraphModel {
  HistoryGraphModel({
    this.labels,
    this.cycleLength,
    this.periodLength,
    this.averageCycle,
    this.averagePeriod,
    this.chartType,
    this.chartTitle,
    this.cycleUnit,
    this.lastUpdated,
  });

  final List<String>? labels;
  final List<int>? cycleLength;
  final List<int>? periodLength;
  final double? averageCycle;
  final double? averagePeriod;
  final String? chartType;
  final String? chartTitle;
  final String? cycleUnit;
  final String? lastUpdated;

  factory HistoryGraphModel.fromMap(Map<String, dynamic> map) {
    return HistoryGraphModel(
      labels: List<String>.from(map['labels'] as List<dynamic>? ?? []),
      cycleLength: List<int>.from(map['cycle_lengths'] as List<dynamic>? ?? []),
      periodLength: List<int>.from(
        map['period_lengths'] as List<dynamic>? ?? [],
      ),
      averageCycle: map['average_cycle'] as double?,
      averagePeriod: map['average_period'] as double?,
      chartType: map['chart_type'] as String?,
      chartTitle: map['chart_title'] as String?,
      cycleUnit: map['cycle_unit'] as String?,
      lastUpdated: map['last_updated'] as String?,
    );
  }
}
