import 'package:femaura/core/utils/spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class FemTextField extends StatelessWidget {
  FemTextField({
    super.key,
    this.label,
    this.obscureText = false,
    required this.tag,
    this.validators = const [],
    this.hintText,
  });

  final String? label;
  final String? hintText;
  final Object tag;
  final bool obscureText;
  final List<String? Function(String?)> validators;

  final ValueNotifier<bool> onObscureTextChanged = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Dimen.x1,
      children: [
        if (label != null) Text(label!),
        ValueListenableBuilder(
          valueListenable: onObscureTextChanged,
          builder: (context, isObscured, child) {
            return FormBuilderTextField(
              name: tag.toString(),
              obscureText: obscureText ? isObscured : false,
              validator: FormBuilderValidators.compose(validators),
              decoration: InputDecoration(
                hintText: hintText,
                suffixIcon:
                    obscureText
                        ? isObscured
                            ? IconButton(
                              onPressed:
                                  () => onObscureTextChanged.value = false,
                              icon: const Icon(Icons.visibility),
                            )
                            : IconButton(
                              onPressed:
                                  () => onObscureTextChanged.value = true,
                              icon: const Icon(Icons.visibility_off),
                            )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimen.rad6),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimen.rad6),
                  borderSide: BorderSide(color: theme.colorScheme.error),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
