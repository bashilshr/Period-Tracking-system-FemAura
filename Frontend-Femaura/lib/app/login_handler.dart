// Notifier LoginHandler

import 'package:femaura/core/utils/mixins/api_call_helper_mixin.dart';
import 'package:femaura/features/auth/domain/auth_usecase.dart';
import 'package:femaura/routing/femaura_router.dart';
import 'package:femaura/routing/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginHandler extends AutoDisposeNotifier<LoginHandler>
    with APICallHelperMixin<LoginHandler> {
  @override
  LoginHandler build() {
    return LoginHandler();
  }

  Future<void> isLoggedIn() async {
    await handleRequest(() async {
      if (ref.read(authUsecaseProvider).isLoggedIn()) {
        ref.read(routerProvider).go(Routes.mainPage);
      }
    });
  }
}

final loginHandlerProvider =
    AutoDisposeNotifierProvider<LoginHandler, LoginHandler>(LoginHandler.new);
