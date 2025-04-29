import 'package:femaura/core/utils/mixins/api_call_helper_mixin.dart';
import 'package:femaura/core/utils/mixins/form_builder_helper_mixin.dart';
import 'package:femaura/features/auth/domain/auth_usecase.dart';
import 'package:femaura/features/settings/domain/entity/settings_entity.dart';
import 'package:femaura/features/settings/domain/settings_usecase.dart';
import 'package:femaura/routing/femaura_router.dart';
import 'package:femaura/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SettingFormTags { name, email, exportType }

class SettingsPresenter extends AutoDisposeNotifier<SettingsEntity>
    with FormBuilderHelperMixin, APICallHelperMixin {
  final formKey = GlobalKey<FormBuilderState>();

  @override
  SettingsEntity build() {
    getProfile();
    return SettingsEntity();
  }

  Future<void> logout() async {
    ref.read(authUsecaseProvider).logout();
    ref.read(routerProvider).go(Routes.login);
  }

  Future<void> getProfile() async {
    await handleRequest(() async {
      final profile = await ref.read(settingsUsecaseProvider).getProfile();
      formKey.currentState?.patchValue({
        SettingFormTags.name.toString(): profile.username,
        SettingFormTags.email.toString(): profile.email,
      });
    });
  }
}

final settingsPresenterProvider =
    AutoDisposeNotifierProvider<SettingsPresenter, SettingsEntity>(
      SettingsPresenter.new,
    );
