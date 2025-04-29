import 'package:flutter_form_builder/flutter_form_builder.dart';

mixin FormBuilderHelperMixin {
  T getValue<T>(FormBuilderState form, Object tag) {
    return form.fields[tag.toString()]?.value as T;
  }
}
