import 'package:femaura/components/form_fields/date_field.dart';
import 'package:femaura/core/utils/spacer.dart';
import 'package:femaura/features/home/presentation/previous_log_cycle/previous_log_cycle_presenter.dart';
import 'package:femaura/routing/femaura_router.dart';
import 'package:femaura/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class PreviousLogCyclePage extends ConsumerWidget {
  const PreviousLogCyclePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final presenter = ref.read(previousLogCyclePresenterProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Dimen.x2),
          child: FormBuilder(
            key: presenter.formKey,
            child: Column(
              spacing: Dimen.x2,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed:
                              () =>
                                  ref.read(routerProvider).go(Routes.mainPage),
                          icon: Icon(Icons.arrow_back),
                        ),
                        Text(
                          'Log Previous Cycle',
                          style: theme.textTheme.titleLarge!.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                  ],
                ),
                Column(
                  spacing: Dimen.x3,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FemDateField(
                      tag: PreviousLogCycleTags.startDate,
                      label: 'Previous Cycle Start Date',
                      validators: [
                        FormBuilderValidators.required(),
                        FormBuilderValidators.date(),
                      ],
                    ),
                    FemDateField(
                      tag: PreviousLogCycleTags.endDate,
                      label: 'Previous Cycle End Date',
                      validators: [
                        FormBuilderValidators.required(),
                        FormBuilderValidators.date(),
                      ],
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: presenter.logPreviousCycle,
                        child: Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
