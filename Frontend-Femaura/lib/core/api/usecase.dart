import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class UseCase {
  UseCase(this.ref);

  final Ref<Object> ref;
}

typedef UseCaseProvider<U extends UseCase> = Provider<U>;
