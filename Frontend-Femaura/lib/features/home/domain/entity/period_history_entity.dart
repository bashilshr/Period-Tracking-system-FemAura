// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:femaura/core/enums.dart';
import 'package:femaura/core/utils/entity.dart';

class HistoryEntity extends Entity {
  const HistoryEntity({
    this.avgCycleLength = 0.0,
    this.totalCycles = 0,
    this.periodHistory = const [],
    this.loadingState = LoadingState.initial,
    this.commonMoods = const [],
    this.commonSymptoms = const [],
    this.cycleVariability = 0,
    this.healthRecommendations = const [],
    this.irregularityLevel = '',
    this.isIrregular = false,
  });

  final double avgCycleLength;
  final int totalCycles;
  final List<PeriodHistoryEntity> periodHistory;
  final int cycleVariability;
  final List<String> commonSymptoms;
  final List<String> commonMoods;
  final List<String> healthRecommendations;
  final LoadingState loadingState;
  final String irregularityLevel;
  final bool isIrregular;

  @override
  HistoryEntity copyWith({
    double? avgCycleLength,
    int? totalCycles,
    List<PeriodHistoryEntity>? periodHistory,
    LoadingState? loadingState,
    List<String>? commonMoods,
    List<String>? commonSymptoms,
    int? cycleVariability,
    List<String>? healthRecommendations,
    String? irregularityLevel,
    bool? isIrregular,
  }) {
    return HistoryEntity(
      avgCycleLength: avgCycleLength ?? this.avgCycleLength,
      totalCycles: totalCycles ?? this.totalCycles,
      periodHistory: periodHistory ?? this.periodHistory,
      loadingState: loadingState ?? this.loadingState,
      commonMoods: commonMoods ?? this.commonMoods,
      commonSymptoms: commonSymptoms ?? this.commonSymptoms,
      cycleVariability: cycleVariability ?? this.cycleVariability,
      healthRecommendations:
          healthRecommendations ?? this.healthRecommendations,
      irregularityLevel: irregularityLevel ?? this.irregularityLevel,
      isIrregular: isIrregular ?? this.isIrregular,
    );
  }

  @override
  List<Object> get props => [
    avgCycleLength,
    totalCycles,
    periodHistory,
    loadingState,
    commonMoods,
    commonSymptoms,
    cycleVariability,
    healthRecommendations,
    irregularityLevel,
    isIrregular,
  ];
}

class PeriodHistoryEntity extends Entity {
  const PeriodHistoryEntity({
    this.startDate = '',
    this.endDate = '',
    this.cycleLength = 0,
    this.days = 0,
    this.symptoms = const [],
    this.isIrregular = false,
  });

  @override
  List<Object> get props => [
    startDate,
    endDate,
    cycleLength,
    days,
    symptoms,
    isIrregular,
  ];

  final String startDate;
  final String endDate;
  final int cycleLength;
  final List<String> symptoms;
  final bool isIrregular;
  final int days;

  @override
  PeriodHistoryEntity copyWith({
    String? startDate,
    String? endDate,
    int? cycleLength,
    List<String>? symptoms,
    bool? isIrregular,
    int? days,
  }) {
    return PeriodHistoryEntity(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cycleLength: cycleLength ?? this.cycleLength,
      symptoms: symptoms ?? this.symptoms,
      isIrregular: isIrregular ?? this.isIrregular,
      days: days ?? this.days,
    );
  }
}
