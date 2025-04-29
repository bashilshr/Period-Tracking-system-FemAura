import 'package:femaura/core/enums.dart';
import 'package:femaura/core/utils/mixins/form_builder_helper_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ResetPasswordFormTags { password, confirmPassword }

class ResetPasswordPresenter extends AutoDisposeNotifier<LoadingState> with FormBuilderHelperMixin {
  final formKey = GlobalKey<FormBuilderState>();

  @override
  LoadingState build() {
    return LoadingState.initial;
  }
}

final resetPasswordPresenter = AutoDisposeNotifierProvider<ResetPasswordPresenter, LoadingState>(
  () => ResetPasswordPresenter(),
);
