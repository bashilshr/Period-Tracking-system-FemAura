import 'package:femaura/components/form_fields/text_field.dart';
import 'package:femaura/core/enums.dart';
import 'package:femaura/core/utils/spacer.dart';
import 'package:femaura/features/auth/presentation/otp_verification/otp_verify_presenter.dart';
import 'package:femaura/features/auth/presentation/shared/auth_title_widget.dart';
import 'package:femaura/routing/femaura_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpVerifyView extends ConsumerWidget {
  const OtpVerifyView({
    super.key,
    required this.verifyFor,
    required this.email,
  });
  final OTPVerificationFor verifyFor;
  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(otpVerifyPresenter.notifier);
    final theme = Theme.of(context);
    final isLoading = ref.watch(otpVerifyPresenter);

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
                    firstTitle: 'Enter the ',
                    highlightedTitle: 'OTP Code ',
                    lastTitle: 'to authenticate your account.',
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FemTextField(
                        label: "OTP Code",
                        tag: OtpVerifyFormTags.otp,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Resend Code",
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          () => presenter.verifyOtp(
                            verifyFor: verifyFor,
                            email: email,
                          ),
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
                              : const Text("Verify"),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => ref.read(routerProvider).goBack(),
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
                              : const Text("Cancel"),
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
