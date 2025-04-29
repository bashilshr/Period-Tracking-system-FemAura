import 'package:femaura/core/utils/entity.dart';

class RecommendationEntity extends Entity {
  const RecommendationEntity({
    this.phase = '',
    this.isIrregular = false,
    this.recommendations = const [],
  });

  final String phase;
  final bool isIrregular;
  final List<RecommendationDataEntity> recommendations;

  @override
  RecommendationEntity copyWith({
    String? phase,
    bool? isIrregular,
    List<RecommendationDataEntity>? recommendations,
  }) {
    return RecommendationEntity(
      phase: phase ?? this.phase,
      isIrregular: isIrregular ?? this.isIrregular,
      recommendations: recommendations ?? this.recommendations,
    );
  }

  @override
  List<Object> get props => [phase, isIrregular, recommendations];
}

class RecommendationDataEntity extends Entity {
  const RecommendationDataEntity({
    this.title = '',
    this.type = '',
    this.matchedTo = '',
    this.youtubeLink = '',
    this.description = '',
    this.articleLink = '',
  });

  final String title;
  final String type;
  final String matchedTo;
  final String youtubeLink;
  final String description;
  final String articleLink;

  @override
  RecommendationDataEntity copyWith({
    String? title,
    String? type,
    String? matchedTo,
    String? youtubeLink,
    String? description,
    String? articleLink,
  }) {
    return RecommendationDataEntity(
      title: title ?? this.title,
      type: type ?? this.type,
      matchedTo: matchedTo ?? this.matchedTo,
      youtubeLink: youtubeLink ?? this.youtubeLink,
      description: description ?? this.description,
      articleLink: articleLink ?? this.articleLink,
    );
  }

  @override
  List<Object> get props => [
    title,
    type,
    matchedTo,
    youtubeLink,
    description,
    articleLink,
  ];
}
