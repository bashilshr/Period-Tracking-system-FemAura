import 'package:femaura/components/form_fields/date_field.dart';
import 'package:femaura/components/form_fields/text_field.dart';
import 'package:femaura/core/utils/spacer.dart';
import 'package:femaura/features/log_cycle/presentation/basic_info_log/basic_info_log_presenter.dart';
import 'package:femaura/routing/femaura_router.dart';
import 'package:femaura/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class BasicInfoLogView extends ConsumerWidget {
  const BasicInfoLogView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final presenter = ref.read(basicInfoLogPresenterProvider.notifier);

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
                    Row(
                      spacing: Dimen.x1,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed:
                              () =>
                                  ref.read(routerProvider).go(Routes.mainPage),
                          icon: Icon(Icons.arrow_back),
                        ),
                        Text(
                          'Log your Cycle',
                          style: theme.textTheme.titleLarge!.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                  ],
                ),
                FemDateField(
                  tag: BasicInfoLogFormTags.date,
                  label: 'Log your Date',
                  validators: [
                    FormBuilderValidators.required(),
                    FormBuilderValidators.date(),
                  ],
                ),
                FemTextField(
                  tag: BasicInfoLogFormTags.experience,
                  label: 'Log your Experience',
                  hintText: 'Enter your experience',
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed:
                          () => ref.read(routerProvider).go(Routes.mainPage),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: presenter.saveBasicInfo,
                      child: Text('Save'),
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
