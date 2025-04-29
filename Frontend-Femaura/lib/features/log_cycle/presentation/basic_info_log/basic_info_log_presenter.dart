import 'package:femaura/core/utils/mixins/form_builder_helper_mixin.dart';
import 'package:femaura/features/log_cycle/domain/entity/log_cycle_entity.dart';
import 'package:femaura/features/log_cycle/presentation/symptoms_info_log/symptoms_info_log_presenter.dart';
import 'package:femaura/routing/femaura_router.dart';
import 'package:femaura/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum BasicInfoLogFormTags { date, experience }

class BasicInfoLogPresenter extends AutoDisposeNotifier<LogCycleEntity>
    with FormBuilderHelperMixin {
  final formKey = GlobalKey<FormBuilderState>();
  final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  LogCycleEntity build() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // final field =
      //     formKey.currentState?.fields[BasicInfoLogFormTags.date.toString()];

      formKey.currentState?.patchValue({
        BasicInfoLogFormTags.date.toString(): _dateFormat.format(
          DateTime.now(),
        ),
      });

      // field?.didChange(_dateFormat.format(DateTime.now()));
    });
    return const LogCycleEntity();
  }

  void saveBasicInfo() {
    final form = formKey.currentState;
    if (form == null || !form.validate()) return;

    final date = getValue<String>(form, BasicInfoLogFormTags.date);
    final experience = getValue<String>(form, BasicInfoLogFormTags.experience);

    ref.read(routerProvider).push(Routes.logSymptoms);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(symptomsInfoLogPresenterProvider.notifier)
          .setCycleState(LogCycleEntity(date: date, description: experience));
    });
  }
}

final basicInfoLogPresenterProvider =
    AutoDisposeNotifierProvider<BasicInfoLogPresenter, LogCycleEntity>(
      BasicInfoLogPresenter.new,
    );
