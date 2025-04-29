import 'package:femaura/core/api/usecase.dart';
import 'package:femaura/features/home/data/home_repository.dart';
import 'package:femaura/features/home/data/model/history_model.dart';
import 'package:femaura/features/home/data/model/recommendation_model.dart';
import 'package:femaura/features/home/domain/entity/history_graph_entity.dart';
import 'package:femaura/features/home/domain/entity/period_history_entity.dart';
import 'package:femaura/features/home/domain/entity/phase_prediction_entity.dart';
import 'package:femaura/features/home/domain/entity/recommendation_entity.dart';

class HomeUsecase extends UseCase {
  HomeUsecase(super.ref);

  HomeRepository get _repo => ref.read(homeRepositoryProvider);

  Future<RecommendationEntity> getRecommendations() async {
    final response = await _repo.getRecommendations();
    return RecommendationEntity(
      phase: response.phase ?? '',
      isIrregular: response.isIrregular ?? false,
      recommendations: [
        for (final recommendation
            in response.recommendations ?? <RecommendationDataModel>[])
          RecommendationDataEntity(
            title: recommendation.title ?? '',
            type: recommendation.type ?? '',
            matchedTo: recommendation.matchedTo ?? '',
            youtubeLink: recommendation.youtubeLink ?? '',
            description: recommendation.description ?? '',
          ),
      ],
    );
  }

  Future<PhasePredictionEntity> getPhasePrediction() async {
    final response = await _repo.getPhasePrediction();
    return PhasePredictionEntity(
      currentPhase: response.currentPhase ?? '',
      currentDay: response.currentDay ?? 0,
      nextPhase: response.nextPhase ?? '',
      daysUntilNextPhase: response.daysUntilNextPhase ?? 0,
      commonSymptoms: response.commonSymptoms ?? [],
      commonMoods: response.commonMoods ?? [],
      message: response.message,
      loggedToday: response.loggedToday ?? false,
      cycleLength: response.cycleLength ?? 0,
      isIrregular: response.isIrregular ?? false,
    );
  }

  Future<void> logPreviousCycle({
    required String startDate,
    required String endDate,
  }) async {
    await _repo.logPreviousCycle(startDate: startDate, endDate: endDate);
  }

  Future<HistoryEntity> getPeriodHistory() async {
    final response = await _repo.getPeriodHistory();
    return HistoryEntity(
      avgCycleLength: response.avgCycleLength ?? 0.0,
      totalCycles: response.totalCycles ?? 0,
      cycleVariability: response.cycleVariability ?? 0,
      commonSymptoms: response.commonSymptoms ?? [],
      commonMoods: response.commonMoods ?? [],
      healthRecommendations: response.healthRecommendations ?? [],
      irregularityLevel: response.irregularityLevel ?? '',
      isIrregular: response.isIrregular ?? false,
      periodHistory: [
        for (final period in response.periodHistory ?? <PeriodHistoryModel>[])
          PeriodHistoryEntity(
            startDate: period.startDate ?? '',
            endDate: period.endDate ?? '',
            cycleLength: period.cycleLength ?? 0,
            days: period.days ?? 0,
            symptoms: period.symptoms ?? [],
            isIrregular: period.isIrregular ?? false,
          ),
      ],
    );
  }

  Future<HistoryGraphEntity> getHistoryGraph() async {
    final response = await _repo.getHistoryGraph();
    return HistoryGraphEntity(
      labels: response.labels ?? [],
      cycleLength: response.cycleLength ?? [],
      periodLength: response.periodLength ?? [],
      averageCycle: response.averageCycle ?? 0.0,
      averagePeriod: response.averagePeriod ?? 0.0,
      chartType: response.chartType ?? '',
      chartTitle: response.chartTitle ?? '',
      cycleUnit: response.cycleUnit ?? '',
      lastUpdated: response.lastUpdated ?? '',
    );
  }
}

final homeUsecaseProvider = UseCaseProvider(HomeUsecase.new);
