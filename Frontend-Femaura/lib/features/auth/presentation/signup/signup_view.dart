import 'package:femaura/components/form_fields/text_field.dart';
import 'package:femaura/core/enums.dart';
import 'package:femaura/core/utils/mixins/form_builder_helper_mixin.dart';
import 'package:femaura/core/utils/spacer.dart';
import 'package:femaura/features/auth/presentation/shared/auth_title_widget.dart';
import 'package:femaura/features/auth/presentation/signup/signup_presenter.dart';
import 'package:femaura/routing/femaura_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class SignupView extends ConsumerWidget with FormBuilderHelperMixin {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final presenter = ref.read(signupPresenter.notifier);
    final isLoading = ref.watch(signupPresenter);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            constraints: const BoxConstraints(maxWidth: 500),
            padding: EdgeInsets.all(Dimen.x4),
            child: FormBuilder(
              key: presenter.formKey,
              child: SingleChildScrollView(
                child: Column(
                  spacing: Dimen.x4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    const AuthTitleWidget(
                      firstTitle: 'Embrace your health. ',
                      highlightedTitle: 'Sign up ',
                      lastTitle: 'and let\'s flow together.',
                    ),
                    // Signup Form
                    Column(
                      spacing: Dimen.x2,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FemTextField(
                          label: "Email",
                          tag: SignupFormTags.email,
                          validators: [FormBuilderValidators.required(), FormBuilderValidators.email()],
                        ),
                        FemTextField(
                          label: "Username",
                          tag: SignupFormTags.fullName,
                          validators: [FormBuilderValidators.required()],
                        ),
                        FemTextField(
                          label: "Password",
                          obscureText: true,
                          tag: SignupFormTags.password,
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
                          obscureText: true,
                          tag: SignupFormTags.confirmPassword,
                          validators: [
                            FormBuilderValidators.required(),
                            (value) {
                              final password = getValue<String>(
                                presenter.formKey.currentState!,
                                SignupFormTags.password,
                              );
                              if (value != password) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ],
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading == LoadingState.loading ? null : presenter.signup,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: Dimen.x2_5, horizontal: Dimen.x6),
                              textStyle: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                            ),
                            child:
                                isLoading == LoadingState.loading ? CircularProgressIndicator() : const Text("Signup"),
                          ),
                        ),
                        Center(
                          child: TextButton(
                            onPressed: () => ref.read(routerProvider).goBack(),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Already have an account? Click here to ",
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  TextSpan(
                                    text: "Login",
                                    style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.primary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
