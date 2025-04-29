import 'package:femaura/core/utils/mixins/api_call_helper_mixin.dart';
import 'package:femaura/features/home/domain/entity/main_page_entity.dart';
import 'package:femaura/features/home/domain/home_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainPagePresenter extends AutoDisposeNotifier<MainPageEntity>
    with APICallHelperMixin {
  @override
  MainPageEntity build() {
    getPhasePrediction();
    return MainPageEntity();
  }

  Future<void> getPhasePrediction() async {
    await handleRequest(() async {
      final phasePrediction =
          await ref.read(homeUsecaseProvider).getPhasePrediction();
      state = state.copyWith(phasePrediction: phasePrediction);
    });
  }
}

final mainPagePresenterProvider =
    AutoDisposeNotifierProvider<MainPagePresenter, MainPageEntity>(
      MainPagePresenter.new,
    );
