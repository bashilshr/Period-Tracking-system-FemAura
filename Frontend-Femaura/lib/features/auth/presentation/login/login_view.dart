import 'package:femaura/components/form_fields/text_field.dart';
import 'package:femaura/core/enums.dart';
import 'package:femaura/core/utils/spacer.dart';
import 'package:femaura/features/auth/presentation/login/login_presenter.dart';
import 'package:femaura/features/auth/presentation/shared/auth_title_widget.dart';
import 'package:femaura/routing/femaura_router.dart';
import 'package:femaura/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final presenter = ref.read(loginPresenter.notifier);
    final isLoading = ref.watch(loginPresenter);

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
                  // Header Section
                  const AuthTitleWidget(
                    firstTitle: "Your wellness journey starts here. ",
                    highlightedTitle: "Login",
                    lastTitle: " to continue.",
                  ),
                  // Login Form
                  Column(
                    spacing: Dimen.x2,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FemTextField(
                        label: "Email",
                        tag: LoginFormTags.email,
                        validators: [FormBuilderValidators.required()],
                      ),
                      FemTextField(
                        label: "Password",
                        obscureText: true,
                        tag: LoginFormTags.password,
                        validators: [FormBuilderValidators.required()],
                      ),
                      TextButton(
                        onPressed:
                            () => ref
                                .read(routerProvider)
                                .go(Routes.resetPassword),
                        child: Text(
                          "Forgot Password?",
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              isLoading == LoadingState.loading
                                  ? null
                                  : presenter.login,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: Dimen.x2_5,
                              horizontal: Dimen.x6,
                            ),
                            textStyle: theme.textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child:
                              isLoading == LoadingState.loading
                                  ? CircularProgressIndicator()
                                  : const Text("Login"),
                        ),
                      ),
                    ],
                  ),

                  // Sign up link
                  Center(
                    child: TextButton(
                      onPressed:
                          () => ref.read(routerProvider).go(Routes.signup),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "If you don't have an account. Click here to ",
                              style: theme.textTheme.bodyMedium,
                            ),
                            TextSpan(
                              text: "Sign up",
                              style: theme.textTheme.bodyMedium!.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
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
