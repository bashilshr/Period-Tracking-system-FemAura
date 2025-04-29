import 'package:femaura/core/api/endpoint.dart';
import 'package:femaura/core/api/repository.dart';
import 'package:femaura/features/log_cycle/data/model/log_full_cycle_model.dart';

class LogCycleRepository extends Repository {
  LogCycleRepository(super.ref);

  Future<void> addDailyFullLog(LogFullCycleModel model) async {
    await api.post(Endpoint.logDailyCycle, data: model.toMap());
  }

  Future<void> addDailyStatus(LogFullCycleModel model) async {
    await api.post(Endpoint.logDailyStatus, data: model.toMap());
  }
}

final logCycleRepositoryProvider = RepositoryProvider<LogCycleRepository>(
  LogCycleRepository.new,
);
