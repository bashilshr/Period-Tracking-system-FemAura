import 'package:femaura/core/utils/entity.dart';
import 'package:femaura/features/home/domain/entity/phase_prediction_entity.dart';

class MainPageEntity extends Entity {
  const MainPageEntity({this.phasePrediction = const PhasePredictionEntity()});

  final PhasePredictionEntity phasePrediction;

  @override
  MainPageEntity copyWith({PhasePredictionEntity? phasePrediction}) {
    return MainPageEntity(
      phasePrediction: phasePrediction ?? this.phasePrediction,
    );
  }

  @override
  List<Object> get props => [phasePrediction];
}
