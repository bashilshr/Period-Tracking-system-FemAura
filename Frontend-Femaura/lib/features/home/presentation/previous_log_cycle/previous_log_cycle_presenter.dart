import 'package:femaura/core/enums.dart';
import 'package:femaura/core/utils/mixins/api_call_helper_mixin.dart';
import 'package:femaura/core/utils/mixins/form_builder_helper_mixin.dart';
import 'package:femaura/features/home/domain/home_usecase.dart';
import 'package:femaura/routing/femaura_router.dart';
import 'package:femaura/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PreviousLogCycleTags { startDate, endDate }

class PreviousLogCyclePresenter extends AutoDisposeNotifier<LoadingState>
    with APICallHelperMixin, FormBuilderHelperMixin {
  final formKey = GlobalKey<FormBuilderState>();

  @override
  LoadingState build() {
    return LoadingState.initial;
  }

  Future<void> logPreviousCycle() async {
    final form = formKey.currentState;
    bool hasError = false;

    if (form == null || !form.validate()) return;

    final startDate = getValue<String>(form, PreviousLogCycleTags.startDate);
    final endDate = getValue<String>(form, PreviousLogCycleTags.endDate);

    final parsedStartDate = DateTime.tryParse(startDate);
    final parsedEndDate = DateTime.tryParse(endDate);

    if (parsedStartDate?.isAfter(DateTime.now()) ?? false) {
      form.fields[PreviousLogCycleTags.startDate.toString()]?.invalidate(
        'Entered Date cannot be Future Date.',
      );
      hasError = true;
    }

    if (parsedEndDate?.isAfter(DateTime.now()) ?? false) {
      form.fields[PreviousLogCycleTags.endDate.toString()]?.invalidate(
        'Entered Date cannot be Future Date.',
      );
      hasError = true;
    }

    if (parsedStartDate?.isAfter(parsedEndDate ?? DateTime.now()) ?? false) {
      form.fields[PreviousLogCycleTags.startDate.toString()]?.invalidate(
        'Start Date cannot be after End Date.',
      );
      hasError = true;
    }

    if (hasError) return;

    await handleRequest(() async {
      await ref
          .read(homeUsecaseProvider)
          .logPreviousCycle(startDate: startDate, endDate: endDate);
      ref.read(routerProvider).go(Routes.mainPage);
    });
  }
}

final previousLogCyclePresenterProvider =
    AutoDisposeNotifierProvider<PreviousLogCyclePresenter, LoadingState>(
      PreviousLogCyclePresenter.new,
    );
