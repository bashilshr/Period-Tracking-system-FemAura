import 'package:flutter/material.dart';

class AuthTitleWidget extends StatelessWidget {
  const AuthTitleWidget({super.key, required this.firstTitle, required this.highlightedTitle, required this.lastTitle});

  final String firstTitle;
  final String highlightedTitle;
  final String lastTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final titleStyle = theme.textTheme.bodyLarge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("FemAura", style: theme.textTheme.displayLarge!.copyWith(color: theme.colorScheme.primary)),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: firstTitle, style: titleStyle),
              TextSpan(text: highlightedTitle, style: titleStyle!.copyWith(color: theme.colorScheme.primary)),
              TextSpan(text: lastTitle, style: titleStyle),
            ],
          ),
        ),
      ],
    );
  }
}
