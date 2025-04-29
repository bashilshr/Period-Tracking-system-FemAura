import 'package:femaura/core/api/usecase.dart';
import 'package:femaura/features/log_cycle/data/log_cycle_repository.dart';
import 'package:femaura/features/log_cycle/data/model/log_full_cycle_model.dart';
import 'package:femaura/features/log_cycle/domain/entity/log_cycle_entity.dart';

class LogCycleUsecase extends UseCase {
  LogCycleUsecase(super.ref);

  LogCycleRepository get repo => ref.read(logCycleRepositoryProvider);

  Future<void> logDailyCase(LogCycleEntity data) async {
    final model = LogFullCycleModel(
      date: data.date,
      experience: data.description,
      moods: data.moods,
      symptoms: data.symptoms,
    );

    await repo.addDailyFullLog(model);
  }

  Future<void> logDailyStatus(LogCycleEntity data) async {
    final model = LogFullCycleModel(
      date: data.date,
      moods: data.moods,
      symptoms: data.symptoms,
    );

    await repo.addDailyStatus(model);
  }
}

final logCycleUsecaseProvider = UseCaseProvider<LogCycleUsecase>(
  LogCycleUsecase.new,
);
