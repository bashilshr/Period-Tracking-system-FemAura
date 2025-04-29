import 'package:femaura/core/utils/mixins/api_call_helper_mixin.dart';
import 'package:femaura/features/home/domain/entity/history_view_entity.dart';
import 'package:femaura/features/home/domain/home_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryViewPresenter extends AutoDisposeNotifier<HistoryViewEntity>
    with APICallHelperMixin {
  @override
  HistoryViewEntity build() {
    _initialize();
    return HistoryViewEntity();
  }

  Future<void> _initialize() async {
    await Future.wait([getPeriodHistory(), getHistoryGraph()]);
  }

  Future<void> getPeriodHistory() async {
    await handleRequest(() async {
      final response = await ref.read(homeUsecaseProvider).getPeriodHistory();
      state = state.copyWith(history: response);
    });
  }

  Future<void> getHistoryGraph() async {
    await handleRequest(() async {
      final response = await ref.read(homeUsecaseProvider).getHistoryGraph();
      state = state.copyWith(graph: response);
    });
  }
}

final historyViewPresenterProvider = AutoDisposeNotifierProvider(
  HistoryViewPresenter.new,
);
