import 'dart:developer';

import 'package:femaura/core/enums.dart';
import 'package:femaura/core/notification/notification_notifier.dart';
import 'package:femaura/core/utils/mixins/api_call_helper_mixin.dart';
import 'package:femaura/core/utils/mixins/form_builder_helper_mixin.dart';
import 'package:femaura/core/utils/toast_service.dart';
import 'package:femaura/features/home/presentation/main_page/main_page_presenter.dart';
import 'package:femaura/features/log_cycle/domain/entity/log_cycle_entity.dart';
import 'package:femaura/features/log_cycle/domain/log_cycle_usecase.dart';
import 'package:femaura/routing/femaura_router.dart';
import 'package:femaura/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SymptomsInfoLogFormTags { symptoms, mood }

class SymptomsInfoLogPresenter extends AutoDisposeNotifier<LogCycleEntity>
    with FormBuilderHelperMixin, APICallHelperMixin {
  final formKey = GlobalKey<FormBuilderState>();

  @override
  LogCycleEntity build() {
    return const LogCycleEntity();
  }

  void setCycleState(LogCycleEntity logCycle) {
    state = logCycle;
  }

  Future<void> saveSymptomsInfo() async {
    log(state.toString());

    final form = formKey.currentState;
    if (form == null || !form.validate()) return;

    final moods = getValue<List<CycleMoodTags>>(
      form,
      SymptomsInfoLogFormTags.mood,
    );
    final symptoms = getValue<List<CycleSymptomsTags>>(
      form,
      SymptomsInfoLogFormTags.symptoms,
    );

    await handleRequest(() async {
      await ref
          .read(logCycleUsecaseProvider)
          .logDailyCase(
            LogCycleEntity(
              date: state.date,
              description: state.description,
              moods: moods.map((e) => e.label).toList(),
              symptoms: symptoms.map((e) => e.label).toList(),
            ),
          );

      ref
          .read(notificationProvider.notifier)
          .scheduleNotification(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title: 'How are you feeling?',
            body:
                'Please record your mood soon so that we can provide you with better insights.',
            scheduledTime: DateTime.now().add(const Duration(seconds: 10)),
          );

      ref
          .read(toastNotifierProvider.notifier)
          .showSuccessToast(
            title: 'Log Successful',
            description: 'Your period has been logged successfully.',
          );

      ref.read(routerProvider).go(Routes.mainPage);
      ref.read(mainPagePresenterProvider.notifier).getPhasePrediction();
    });
  }
}

final symptomsInfoLogPresenterProvider =
    AutoDisposeNotifierProvider<SymptomsInfoLogPresenter, LogCycleEntity>(
      SymptomsInfoLogPresenter.new,
    );
