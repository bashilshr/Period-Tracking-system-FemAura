import 'package:femaura/core/utils/spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

/// A reusable date picker form field widget for use in forms.
/// Accepts validators, a label, hint text, and a tag for form identification.
class FemDateField extends StatefulWidget {
  const FemDateField({
    super.key,
    this.label,
    required this.tag,
    this.validators = const [],
    this.hintText,
  });

  final String? label;
  final String? hintText;
  final Object tag;
  final List<String? Function(String?)> validators;

  @override
  State<FemDateField> createState() => _FemDateFieldState();
}

class _FemDateFieldState extends State<FemDateField> {
  late final TextEditingController _controller;
  final _dateFormat = DateFormat('yyyy-MM-dd');
  String? _lastSyncedValue;

  @override
  void initState() {
    super.initState();
    // Initialize the controller when the widget is created.
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Updates the controller's value only if it differs from the current text.
  /// Keeps the text field in sync with the form state.
  void _updateControllerValue(String? value) {
    final newText = value ?? '';
    if (newText != _controller.text) {
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
    _lastSyncedValue = newText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Dimen.x1,
      children: [
        if (widget.label != null) Text(widget.label!),
        FormBuilderField<String>(
          builder: (formState) {
            // Synchronize the controller with the form state.
            if ((formState.value ?? '') != (_lastSyncedValue ?? '')) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _updateControllerValue(formState.value);
              });
            }
            return TextFormField(
              controller: _controller,
              onChanged: (value) => formState.didChange(value),
              validator: FormBuilderValidators.compose(widget.validators),
              decoration: InputDecoration(
                hintText: widget.hintText,
                errorText: formState.errorText,
                suffixIcon: IconButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dateFormat.tryParse(formState.value ?? ''),
                      firstDate: DateTime(1990),
                      lastDate: DateTime.now(),
                    );

                    if (date != null) {
                      final formattedDate = _dateFormat.format(date);
                      formState.didChange(formattedDate);
                    }
                  },
                  icon: Icon(Icons.calendar_month),
                ),
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
          name: widget.tag.toString(),
        ),
      ],
    );
  }
}
