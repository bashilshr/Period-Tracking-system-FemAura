import 'package:femaura/core/enums.dart';
import 'package:femaura/core/utils/mixins/form_builder_helper_mixin.dart';
import 'package:femaura/features/auth/domain/auth_usecase.dart';
import 'package:femaura/routing/femaura_router.dart';
import 'package:femaura/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SignupFormTags { fullName, email, password, confirmPassword }

class SignupPresenter extends AutoDisposeNotifier<LoadingState>
    with FormBuilderHelperMixin {
  final formKey = GlobalKey<FormBuilderState>();

  @override
  LoadingState build() {
    return LoadingState.initial;
  }

  Future<void> signup() async {
    final form = formKey.currentState;
    if (form == null || !form.validate()) return;

    state = LoadingState.loading;

    final username = getValue<String>(form, SignupFormTags.fullName);
    final email = getValue<String>(form, SignupFormTags.email);
    final password = getValue<String>(form, SignupFormTags.password);
    final confirmPassword = getValue<String>(
      form,
      SignupFormTags.confirmPassword,
    );

    try {
      await ref
          .read(authUsecaseProvider)
          .signup(
            username: username,
            email: email,
            password: password,
            confirmPassword: confirmPassword,
          );

      state = LoadingState.success;

      ref
          .read(routerProvider)
          .go(
            Routes.verification,
            extra: {'for': OTPVerificationFor.signup, 'email': email},
          );
    } catch (e) {
      state = LoadingState.error;
    } finally {
      state = LoadingState.initial;
    }
  }
}

final signupPresenter =
    AutoDisposeNotifierProvider<SignupPresenter, LoadingState>(
      SignupPresenter.new,
    );
