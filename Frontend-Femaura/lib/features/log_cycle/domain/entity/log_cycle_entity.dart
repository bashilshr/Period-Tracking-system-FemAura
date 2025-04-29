import 'package:femaura/core/enums.dart';
import 'package:femaura/core/utils/entity.dart';

class LogCycleEntity extends Entity {
  const LogCycleEntity({
    this.date = '',
    this.description = '',
    this.moods = const [],
    this.symptoms = const [],
    this.formSubmitState = LoadingState.initial,
  });

  final String date;
  final String description;
  final List<String> moods;
  final List<String> symptoms;

  final LoadingState formSubmitState;

  @override
  List<Object> get props => [
    date,
    description,
    moods,
    symptoms,
    formSubmitState,
  ];

  @override
  LogCycleEntity copyWith({
    String? date,
    String? description,
    List<String>? moods,
    List<String>? symptoms,
    LoadingState? formSubmitState,
  }) {
    return LogCycleEntity(
      date: date ?? this.date,
      description: description ?? this.description,
      moods: moods ?? this.moods,
      symptoms: symptoms ?? this.symptoms,
      formSubmitState: formSubmitState ?? this.formSubmitState,
    );
  }
}
