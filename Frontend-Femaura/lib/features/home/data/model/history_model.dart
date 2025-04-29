class HistoryModel {
  const HistoryModel({
    this.avgCycleLength,
    this.totalCycles,
    this.periodHistory,
    this.cycleVariability,
    this.irregularityLevel,
    this.commonSymptoms,
    this.commonMoods,
    this.healthRecommendations,
    this.isIrregular,
  });

  final double? avgCycleLength;
  final int? totalCycles;
  final List<PeriodHistoryModel>? periodHistory;
  final int? cycleVariability;
  final String? irregularityLevel;
  final List<String>? commonSymptoms;
  final List<String>? commonMoods;
  final List<String>? healthRecommendations;
  final bool? isIrregular;

  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      avgCycleLength: map['avg_cycle_length'] as double?,
      totalCycles: map['total_cycles'] as int?,
      periodHistory:
          map['period_history'] != null
              ? (map['period_history'] as List<dynamic>?)
                  ?.map((e) => PeriodHistoryModel.fromJson(e))
                  .toList()
              : null,
      cycleVariability: map['cycle_variability'] as int?,
      irregularityLevel: map['irregularity_level'] as String?,
      commonSymptoms:
          map['common_symptoms'] != null
              ? (map['common_symptoms'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList()
              : null,
      commonMoods:
          map['common_moods'] != null
              ? (map['common_moods'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList()
              : null,
      healthRecommendations:
          map['recommendations'] != null
              ? (map['recommendations'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList()
              : null,
      isIrregular: map['is_irregular'] as bool?,
    );
  }
}

class PeriodHistoryModel {
  const PeriodHistoryModel({
    this.startDate,
    this.endDate,
    this.cycleLength,
    this.days,
    this.symptoms,
    this.isIrregular,
  });

  final String? startDate;
  final String? endDate;
  final int? cycleLength;
  final int? days;
  final List<String>? symptoms;
  final bool? isIrregular;

  factory PeriodHistoryModel.fromJson(Map<String, dynamic> json) {
    return PeriodHistoryModel(
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      cycleLength: json['cycle_length'] as int?,
      days: json['days'] as int?,
      symptoms:
          json['symptoms'] != null
              ? (json['symptoms'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList()
              : null,
      isIrregular: json['is_irregular'] as bool?,
    );
  }
}
