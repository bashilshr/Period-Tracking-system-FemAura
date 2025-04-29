import 'package:femaura/components/form_fields/text_field.dart';
import 'package:femaura/core/enums.dart';
import 'package:femaura/core/utils/mixins/form_builder_helper_mixin.dart';
import 'package:femaura/core/utils/spacer.dart';
import 'package:femaura/features/auth/presentation/reset_password/reset_password_presenter.dart';
import 'package:femaura/features/auth/presentation/shared/auth_title_widget.dart';
import 'package:femaura/routing/femaura_router.dart';
import 'package:femaura/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class ResetPasswordView extends ConsumerWidget with FormBuilderHelperMixin {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(resetPasswordPresenter.notifier);
    final isLoading = ref.watch(resetPasswordPresenter);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            constraints: const BoxConstraints(maxWidth: 500),
            padding: EdgeInsets.all(Dimen.x4),
            child: FormBuilder(
              key: presenter.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: Dimen.x4,
                children: [
                  const AuthTitleWidget(
                    firstTitle: "Please enter your ",
                    highlightedTitle: "new password",
                    lastTitle: " to reset.",
                  ),
                  Column(
                    spacing: Dimen.x2,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FemTextField(
                        label: "New Password",
                        tag: ResetPasswordFormTags.password,
                        validators: [
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(8),
                          FormBuilderValidators.maxLength(16),
                          FormBuilderValidators.match(
                            RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$'),
                            errorText:
                                'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character.',
                          ),
                        ],
                      ),
                      FemTextField(
                        label: "Confirm Password",
                        tag: ResetPasswordFormTags.confirmPassword,
                        validators: [
                          FormBuilderValidators.required(),
                          (value) {
                            final password = getValue<String>(
                              presenter.formKey.currentState!,
                              ResetPasswordFormTags.password,
                            );
                            if (value != password) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ],
                      ),
                    ],
                  ),
                  Center(
                    child: Column(
                      spacing: Dimen.x2,
                      children: [
                        Container(
                          constraints: const BoxConstraints(minWidth: 200),
                          child: ElevatedButton(
                            onPressed: () => ref.read(routerProvider).go(Routes.verification),
                            child:
                                isLoading == LoadingState.loading
                                    ? CircularProgressIndicator()
                                    : Text("Reset Password"),
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(minWidth: 200),
                          child: ElevatedButton(
                            onPressed: () => ref.read(routerProvider).goBack(),
                            child: Text("Back to Login"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
