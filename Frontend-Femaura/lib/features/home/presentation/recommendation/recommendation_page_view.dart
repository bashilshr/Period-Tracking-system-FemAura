import 'package:femaura/core/utils/spacer.dart';
import 'package:femaura/features/home/presentation/recommendation/recommendation_page_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommendationPageView extends ConsumerWidget {
  const RecommendationPageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entity = ref.watch(recommendationPagePresenterProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(Dimen.x2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommendations',
            style: theme.textTheme.titleLarge!.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          Divider(),

          Text('Your Recommendations for Today'),
          Divider(),
          if (entity.recommendations.isEmpty)
            Center(
              child: Text(
                'No recommendations available. Please start your cycle/period for recommendations.',
                textAlign: TextAlign.center,
              ),
            )
          else
            for (final recommend in entity.recommendations)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(Dimen.x2),
                  child: Column(
                    spacing: Dimen.x1,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recommend.title),
                      Text(
                        recommend.description,
                        style: theme.textTheme.bodySmall!.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Wrap(
                        spacing: Dimen.x1,
                        runSpacing: Dimen.x1,
                        children: [
                          Chip(label: Text(recommend.type)),
                          Chip(label: Text(recommend.matchedTo)),
                        ],
                      ),
                      Row(
                        children: [
                          if (recommend.articleLink.isNotEmpty)
                            IconButton(
                              icon: Icon(Icons.open_in_new),
                              onPressed: () async {
                                await launchUrl(
                                  Uri.parse(recommend.articleLink),
                                );
                              },
                            ),
                          IconButton(
                            icon: Icon(Icons.video_collection),
                            onPressed: () async {
                              await launchUrl(Uri.parse(recommend.youtubeLink));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
