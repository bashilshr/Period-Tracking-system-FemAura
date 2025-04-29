import 'package:femaura/routing/femaura_router.dart';
import 'package:femaura/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScaffoldView extends ConsumerWidget {
  const HomeScaffoldView({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navIndex = ref.watch(navIndexProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navIndex,
        destinations: destinations,
        onDestinationSelected: (value) {
          ref.read(navIndexProvider.notifier).state = value;
          ref.read(routerProvider).go(switch (value) {
            0 => Routes.mainPage,
            1 => Routes.recommendation,
            2 => Routes.history,
            _ => Routes.mainPage,
          });
        },
      ),
    );
  }
}

final destinations = [
  NavigationDestination(icon: const Icon(Icons.home), label: 'Home'),
  NavigationDestination(icon: const Icon(Icons.info), label: 'Recommendations'),
  NavigationDestination(icon: const Icon(Icons.timeline), label: 'Insights'),
];

final navIndexProvider = StateProvider<int>((ref) => 0);
