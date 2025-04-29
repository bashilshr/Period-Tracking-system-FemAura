import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

abstract base class AppRouter<R extends RoutesMixin> {
  AppRouter({required this.initialLocation}) {
    _router = GoRouter(
      initialLocation: initialLocation.path,
      routes: routes,
      redirect: redirect,
      debugLogDiagnostics: true,
    );
  }

  final RoutesMixin initialLocation;

  late final GoRouter _router;
  RouterConfig<Object> get config => _router;
  final List<R> _previousLocations = [];

  final currentRouteValueNotifier = ValueNotifier<RoutesMixin?>(null);

  @protected
  List<RouteBase> get routes;

  @protected
  FutureOr<String?>? redirect(BuildContext context, GoRouterState state);

  void go(
    R route, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    _previousLocations.add(route);
    currentRouteValueNotifier.value = route;
    _router.goNamed(
      route.name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  void push(
    R route, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    _previousLocations.add(route);
    currentRouteValueNotifier.value = route;
    _router.pushNamed(
      route.name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  void goLocation(String location, Object? extra) {
    _router.go(location, extra: extra);
  }

  void goBack() {
    if (_previousLocations.isNotEmpty) {
      final previousLocation =
          _previousLocations[_previousLocations.length - 1];

      go(previousLocation);
    }
  }
}

class AppRoute extends GoRoute {
  AppRoute({
    required RoutesMixin route,
    super.routes,
    super.builder,
    super.pageBuilder,
    super.redirect,
  }) : super(name: route.name, path: route.path);
}

mixin RoutesMixin on Enum {
  String get path;
}

typedef AppRouterState = GoRouterState;

typedef AppRouteBase = RouteBase;

typedef AppRouterProvider<A extends AppRouter> = Provider<A>;
