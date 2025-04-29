import 'package:femaura/core/enums.dart';
import 'package:femaura/core/utils/spacer.dart';
import 'package:femaura/features/log_cycle/presentation/symptoms_info_log/symptoms_info_log_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SymptomsInfoLogView extends ConsumerWidget {
  const SymptomsInfoLogView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final presenter = ref.read(symptomsInfoLogPresenterProvider.notifier);
    final logCycleState = ref.watch(symptomsInfoLogPresenterProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Dimen.x2),
          child: FormBuilder(
            key: presenter.formKey,
            child: Column(
              spacing: Dimen.x3,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Log your Symptoms',
                      style: theme.textTheme.titleLarge!.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Divider(),
                    if (logCycleState.date.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: Dimen.x1),
                        child: Text(
                          'Date: ${logCycleState.date}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    if (logCycleState.description.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: Dimen.x1),
                        child: Text(
                          'Experience: ${logCycleState.description}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What is your Mood?',
                      style: theme.textTheme.titleMedium,
                    ),
                    Divider(),
                    FormBuilderFilterChips(
                      decoration: InputDecoration(border: InputBorder.none),
                      spacing: Dimen.x2,
                      runSpacing: Dimen.x2,
                      name: SymptomsInfoLogFormTags.mood.toString(),
                      options: [
                        ...CycleMoodTags.values.map(
                          (e) => FormBuilderChipOption(
                            value: e,
                            child: Text(e.label),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Any symptoms you are facing?',
                      style: theme.textTheme.titleMedium,
                    ),
                    Divider(),
                    FormBuilderFilterChips(
                      decoration: InputDecoration(border: InputBorder.none),
                      spacing: Dimen.x2,
                      runSpacing: Dimen.x2,
                      name: SymptomsInfoLogFormTags.symptoms.toString(),
                      options: [
                        ...CycleSymptomsTags.values.map(
                          (e) => FormBuilderChipOption(
                            value: e,
                            child: Text(e.label),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: presenter.saveSymptomsInfo,
                      child: Text('Log Symptoms'),
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
