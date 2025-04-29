import 'package:femaura/core/api/endpoint.dart';
import 'package:femaura/core/api/repository.dart';
import 'package:femaura/features/home/data/model/history_graph_model.dart';
import 'package:femaura/features/home/data/model/history_model.dart';
import 'package:femaura/features/home/data/model/phase_prediction_model.dart';
import 'package:femaura/features/home/data/model/recommendation_model.dart';

class HomeRepository extends Repository {
  HomeRepository(super.ref);

  Future<RecommendationModel> getRecommendations() async {
    final response = await api.get(Endpoint.recommendations);
    return RecommendationModel.fromMap(response as Map<String, dynamic>);
  }

  Future<PhasePredictionModel> getPhasePrediction() async {
    final response = await api.get(Endpoint.phasePrediction);
    return PhasePredictionModel.fromMap(response as Map<String, dynamic>);
  }

  Future<void> logPreviousCycle({
    required String startDate,
    required String endDate,
  }) async {
    await api.post(
      Endpoint.logPreviousCycle,
      data: {'start_date': startDate, 'end_date': endDate},
    );
  }

  Future<HistoryModel> getPeriodHistory() async {
    final response = await api.get(Endpoint.getPeriodHistory);
    return HistoryModel.fromMap(response as Map<String, dynamic>);
  }

  Future<HistoryGraphModel> getHistoryGraph() async {
    final response = await api.get(Endpoint.getHistoryGraph);
    return HistoryGraphModel.fromMap(response as Map<String, dynamic>);
  }
}

final homeRepositoryProvider = RepositoryProvider(HomeRepository.new);
