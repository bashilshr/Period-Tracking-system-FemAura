import 'package:femaura/core/enums.dart';
import 'package:femaura/core/utils/mixins/form_builder_helper_mixin.dart';
import 'package:femaura/features/auth/domain/auth_usecase.dart';
import 'package:femaura/routing/femaura_router.dart';
import 'package:femaura/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum OtpVerifyFormTags { otp }

class OtpVerifyPresenter extends AutoDisposeNotifier<LoadingState>
    with FormBuilderHelperMixin {
  final formKey = GlobalKey<FormBuilderState>();

  @override
  LoadingState build() {
    return LoadingState.initial;
  }

  Future<void> verifyOtp({
    required OTPVerificationFor verifyFor,
    required String email,
  }) async {
    final form = formKey.currentState;
    if (form == null || !form.validate()) return;

    final otp = getValue<String>(form, OtpVerifyFormTags.otp);

    try {
      switch (verifyFor) {
        case OTPVerificationFor.signup:
          await ref
              .read(authUsecaseProvider)
              .verifyEmailOtp(otp: otp, email: email);
          state = LoadingState.success;
          ref.read(routerProvider).go(Routes.login);
        default:
      }
    } catch (e) {
      state = LoadingState.error;
    } finally {
      state = LoadingState.initial;
    }
  }
}

final otpVerifyPresenter =
    AutoDisposeNotifierProvider<OtpVerifyPresenter, LoadingState>(
      () => OtpVerifyPresenter(),
    );
