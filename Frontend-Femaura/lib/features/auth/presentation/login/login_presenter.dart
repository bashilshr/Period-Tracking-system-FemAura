import 'package:femaura/core/enums.dart';
import 'package:femaura/core/utils/mixins/api_call_helper_mixin.dart';
import 'package:femaura/core/utils/mixins/form_builder_helper_mixin.dart';
import 'package:femaura/features/auth/domain/auth_usecase.dart';
import 'package:femaura/routing/femaura_router.dart';
import 'package:femaura/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LoginFormTags { email, password }

class LoginPresenter extends AutoDisposeNotifier<LoadingState>
    with FormBuilderHelperMixin, APICallHelperMixin {
  final formKey = GlobalKey<FormBuilderState>();

  @override
  LoadingState build() {
    return LoadingState.initial;
  }

  Future<void> login() async {
    final form = formKey.currentState;
    if (form == null || !form.validate()) return;

    final email = getValue<String>(form, LoginFormTags.email);
    final password = getValue<String>(form, LoginFormTags.password);

    state = LoadingState.loading;

    await handleRequest(
      () async {
        await ref
            .read(authUsecaseProvider)
            .login(email: email, password: password);
        state = LoadingState.success;
        ref.read(routerProvider).go(Routes.mainPage);
      },
      onError: (failure) {
        state = LoadingState.error;
      },
    );
  }
}

final loginPresenter =
    AutoDisposeNotifierProvider<LoginPresenter, LoadingState>(
      LoginPresenter.new,
    );
