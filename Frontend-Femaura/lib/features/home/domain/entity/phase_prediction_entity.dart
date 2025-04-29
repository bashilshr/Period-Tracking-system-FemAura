import 'package:femaura/core/utils/entity.dart';

class PhasePredictionEntity extends Entity {
  const PhasePredictionEntity({
    this.currentPhase = '',
    this.currentDay = 0,
    this.nextPhase = '',
    this.daysUntilNextPhase = 0,
    this.commonSymptoms = const [],
    this.commonMoods = const [],
    this.message = '',
    this.loggedToday = false,
    this.cycleLength = 0,
    this.isIrregular = false,
  });

  final String currentPhase;
  final int currentDay;
  final String nextPhase;
  final int daysUntilNextPhase;
  final List<String> commonSymptoms;
  final List<String> commonMoods;
  final String? message;
  final bool loggedToday;
  final int cycleLength;
  final bool isIrregular;

  @override
  PhasePredictionEntity copyWith({
    String? currentPhase,
    int? currentDay,
    String? nextPhase,
    int? daysUntilNextPhase,
    List<String>? commonSymptoms,
    List<String>? commonMoods,
    bool? loggedToday,
    int? cycleLength,
    bool? isIrregular,
  }) {
    return PhasePredictionEntity(
      currentPhase: currentPhase ?? this.currentPhase,
      currentDay: currentDay ?? this.currentDay,
      nextPhase: nextPhase ?? this.nextPhase,
      daysUntilNextPhase: daysUntilNextPhase ?? this.daysUntilNextPhase,
      commonSymptoms: commonSymptoms ?? this.commonSymptoms,
      commonMoods: commonMoods ?? this.commonMoods,
      loggedToday: loggedToday ?? this.loggedToday,
      cycleLength: cycleLength ?? this.cycleLength,
      isIrregular: isIrregular ?? this.isIrregular,
    );
  }

  @override
  List<Object> get props => [
    currentPhase,
    currentDay,
    nextPhase,
    daysUntilNextPhase,
    commonSymptoms,
    commonMoods,
    loggedToday,
    cycleLength,
    isIrregular,
  ];
}
