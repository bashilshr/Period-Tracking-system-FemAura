import 'package:femaura/core/utils/spacer.dart';
import 'package:femaura/routing/femaura_router.dart';
import 'package:femaura/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirstTimeAppView extends ConsumerWidget {
  const FirstTimeAppView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            spacing: Dimen.x4,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TitleTextWidget(),
              ElevatedButton(
                onPressed: () => ref.read(routerProvider).go(Routes.login),
                child: Text("Begin your Journey"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleTextWidget extends StatelessWidget {
  const _TitleTextWidget();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final TextPainter centerTextPainter = TextPainter(
                    text: TextSpan(
                      text: 'FemAura',
                      style: theme.textTheme.displayMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    textDirection: TextDirection.ltr,
                  )..layout(maxWidth: constraints.maxWidth);

                  final centerTextWidth = centerTextPainter.width;
                  final centerPosition = constraints.maxWidth / 2 - centerTextWidth / 2;

                  return SizedBox(
                    width: constraints.maxWidth,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          left: centerPosition,
                          top: 0,
                          child: Text('Welcome To', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500)),
                        ),
                        Positioned(
                          top: 25,
                          child: Text(
                            'FemAura',
                            style: theme.textTheme.displayMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        Positioned(
                          right: centerPosition,
                          bottom: 0,
                          child: Text(
                            'Flow. Heal. Grow',
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
