import 'package:femaura/core/utils/mixins/api_call_helper_mixin.dart';
import 'package:femaura/features/home/domain/entity/recommendation_entity.dart';
import 'package:femaura/features/home/domain/home_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecommendationPagePresenter
    extends AutoDisposeNotifier<RecommendationEntity>
    with APICallHelperMixin {
  @override
  RecommendationEntity build() {
    getRecommendations();
    return RecommendationEntity();
  }

  Future<void> getRecommendations() async {
    await handleRequest(() async {
      final recommendations =
          await ref.read(homeUsecaseProvider).getRecommendations();
      state = recommendations;
    });
  }
}

final recommendationPagePresenterProvider = AutoDisposeNotifierProvider<
  RecommendationPagePresenter,
  RecommendationEntity
>(RecommendationPagePresenter.new);
