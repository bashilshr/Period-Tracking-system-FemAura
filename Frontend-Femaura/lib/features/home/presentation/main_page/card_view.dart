import 'package:femaura/core/utils/spacer.dart';
import 'package:flutter/material.dart';

class DataCardWidget extends StatelessWidget {
  const DataCardWidget({super.key, required this.title, required this.value});

  final String title;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(Dimen.x2),
        child: Column(
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            if (value is String)
              Text(value, style: theme.textTheme.displaySmall)
            else
              value,
          ],
        ),
      ),
    );
  }
}
