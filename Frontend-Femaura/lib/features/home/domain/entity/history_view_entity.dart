import 'package:femaura/core/enums.dart';
import 'package:femaura/core/utils/entity.dart';
import 'package:femaura/features/home/domain/entity/history_graph_entity.dart';
import 'package:femaura/features/home/domain/entity/period_history_entity.dart';

class HistoryViewEntity extends Entity {
  const HistoryViewEntity({
    this.history = const HistoryEntity(),
    this.graph = const HistoryGraphEntity(),
    this.loadingState = LoadingState.initial,
  });

  @override
  List<Object> get props => [history, graph, loadingState];

  @override
  HistoryViewEntity copyWith({
    HistoryEntity? history,
    HistoryGraphEntity? graph,
    LoadingState? loadingState,
  }) {
    return HistoryViewEntity(
      history: history ?? this.history,
      graph: graph ?? this.graph,
      loadingState: loadingState ?? this.loadingState,
    );
  }

  final HistoryEntity history;
  final HistoryGraphEntity graph;
  final LoadingState loadingState;
}
