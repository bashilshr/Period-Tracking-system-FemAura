class PhasePredictionModel {
  PhasePredictionModel({
    this.currentPhase,
    this.currentDay,
    this.nextPhase,
    this.daysUntilNextPhase,
    this.commonSymptoms,
    this.commonMoods,
    this.message,
    this.loggedToday,
    this.cycleLength,
    this.isIrregular,
  });

  final String? currentPhase;
  final int? currentDay;
  final String? nextPhase;
  final int? daysUntilNextPhase;
  final List<String>? commonSymptoms;
  final List<String>? commonMoods;
  final String? message;
  final bool? loggedToday;
  final int? cycleLength;
  final bool? isIrregular;

  factory PhasePredictionModel.fromMap(Map<String, dynamic> map) {
    return PhasePredictionModel(
      currentPhase: map['current_phase'] as String?,
      currentDay: map['current_day'] as int?,
      nextPhase: map['next_phase'] as String?,
      daysUntilNextPhase: map['days_until_next_phase'] as int?,
      commonSymptoms:
          (map['common_symptoms'] as List?)?.map((e) => e as String).toList(),
      commonMoods:
          (map['common_moods'] as List?)?.map((e) => e as String).toList(),
      message: map['message'] as String?,
      loggedToday: map['logged_today'] as bool?,
      cycleLength: map['cycle_length'] as int?,
      isIrregular: map['is_irregular'] as bool?,
    );
  }
}
