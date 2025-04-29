import 'package:femaura/app/femaura.dart';
import 'package:femaura/core/notification/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:femaura/core/utils/secure_storage/secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SecureStorage().init();
  await NotificationService.init();
  runApp(ProviderScope(child: FemAuraApp()));
}
