import 'package:femaura/components/form_fields/text_field.dart';
import 'package:femaura/core/theme/theme_select_handler.dart';
import 'package:femaura/core/utils/spacer.dart';
import 'package:femaura/features/settings/presentation/settings_presenter.dart';
import 'package:femaura/routing/femaura_router.dart';
import 'package:femaura/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final presenter = ref.read(settingsPresenterProvider.notifier);

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
                          'Settings',
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
                  spacing: Dimen.x2,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Profile'),
                    FemTextField(tag: SettingFormTags.email, hintText: 'Email'),
                    FemTextField(tag: SettingFormTags.name, hintText: 'Name'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Export Your Data'),
                    Divider(),
                    Row(
                      children: [
                        ElevatedButton(onPressed: () {}, child: Text('Export')),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Theme'),
                    Divider(),
                    Center(
                      child: SegmentedButton<ThemeMode>(
                        segments: [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text('System'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text('Light'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text('Dark'),
                          ),
                        ],
                        selected: {ref.watch(themeSelectHandlerProvider)},
                        onSelectionChanged: (values) {
                          ref
                              .read(themeSelectHandlerProvider.notifier)
                              .setThemeMode(values.first);
                        },
                      ),
                    ),
                  ],
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: presenter.logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                    ),
                    child: Text(
                      'Log out',
                      style: theme.textTheme.titleMedium!.copyWith(
                        color: theme.colorScheme.onError,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
