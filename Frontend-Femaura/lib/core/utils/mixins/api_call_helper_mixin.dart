import 'package:femaura/core/api/failure.dart';
import 'package:femaura/core/utils/toast_service.dart';
import 'package:femaura/features/auth/domain/auth_usecase.dart';
import 'package:femaura/routing/femaura_router.dart';
import 'package:femaura/routing/routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

mixin APICallHelperMixin<T> on AutoDisposeNotifier<T> {
  Future<void> handleRequest(
    Future<dynamic> Function() func, {
    void Function(Failure failure)? onError,
  }) async {
    try {
      await func();
    } on Failure catch (failure) {
      onError?.call(failure);
      if (failure is NetworkFailure) {
        if (failure.message.toLowerCase().contains('token')) {
          ref
              .read(toastNotifierProvider.notifier)
              .showErrorToast(
                title: 'Token Expired',
                description: 'Please login again',
              );
          ref.read(authUsecaseProvider).logout();
          ref.read(routerProvider).go(Routes.login);
        }
      } else {
        ref
            .read(toastNotifierProvider.notifier)
            .showErrorToast(
              title:
                  failure.error?.isEmpty ?? true
                      ? failure.message
                      : failure.error!,
              description:
                  failure.error?.isEmpty ?? true ? null : failure.message,
            );
      }
    }
  }
}
