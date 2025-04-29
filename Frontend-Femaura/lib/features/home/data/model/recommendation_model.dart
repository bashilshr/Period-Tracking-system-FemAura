class RecommendationModel {
  final String? phase;
  final bool? isIrregular;
  final List<RecommendationDataModel>? recommendations;

  RecommendationModel({this.phase, this.isIrregular, this.recommendations});

  factory RecommendationModel.fromMap(Map<String, dynamic> map) {
    return RecommendationModel(
      phase: map['phase'] as String?,
      isIrregular: map['is_irregular'] as bool?,
      recommendations:
          map['recommendations'] != null
              ? (map['recommendations'] as List)
                  .map((x) => RecommendationDataModel.fromMap(x))
                  .toList()
              : null,
    );
  }
}

class RecommendationDataModel {
  final String? title;
  final String? type;
  final String? matchedTo;
  final String? youtubeLink;
  final String? description;
  final String? articleLink;

  RecommendationDataModel({
    this.title,
    this.type,
    this.matchedTo,
    this.youtubeLink,
    this.description,
    this.articleLink,
  });

  factory RecommendationDataModel.fromMap(Map<String, dynamic> map) {
    return RecommendationDataModel(
      title: map['title'] as String?,
      type: map['type'] as String?,
      matchedTo: map['matched_to'] as String?,
      youtubeLink: map['youtube_link'] as String?,
      description: map['description'] as String?,
      articleLink: map['article_link'] as String?,
    );
  }
}
