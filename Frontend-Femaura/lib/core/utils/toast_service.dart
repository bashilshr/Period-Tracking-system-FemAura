import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

class ToastNotifier extends StateNotifier<void> {
  ToastNotifier() : super(null);

  void showSuccessToast({required String title, String? description}) {
    _toastHandler(
      title: title,
      description: description,
      type: ToastificationType.success,
    );
  }

  void showErrorToast({required String title, String? description}) {
    _toastHandler(
      title: title,
      description: description,
      type: ToastificationType.error,
    );
  }

  void _toastHandler({
    required String title,
    String? description,
    ToastificationType? type,
  }) {
    toastification.show(
      title: Text(title),
      description: description != null ? Text(description) : null,
      type: type,
      autoCloseDuration: const Duration(seconds: 3),
      style: ToastificationStyle.minimal,
      borderRadius: BorderRadius.circular(4),
    );
  }
}

final toastNotifierProvider = StateNotifierProvider<ToastNotifier, void>((ref) {
  return ToastNotifier();
});
