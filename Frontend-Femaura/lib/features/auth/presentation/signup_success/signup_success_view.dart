import 'package:femaura/core/utils/spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupSuccessView extends ConsumerWidget {
  const SignupSuccessView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            constraints: const BoxConstraints(maxWidth: 500),
            padding: EdgeInsets.all(Dimen.x4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Congratulations!",
                  style: theme.textTheme.displayLarge!.copyWith(color: theme.colorScheme.primary),
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(text: "You have successfully created and your ", style: theme.textTheme.bodyLarge),
                      TextSpan(
                        text: "information ",
                        style: theme.textTheme.bodyLarge!.copyWith(color: theme.colorScheme.primary),
                      ),
                      TextSpan(text: "is secured with us.", style: theme.textTheme.bodyLarge),
                    ],
                  ),
                ),
                const VSpace(Dimen.x2),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: Dimen.x2_5, horizontal: Dimen.x6),
                    textStyle: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                  ),
                  child: const Text("Get Started"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
