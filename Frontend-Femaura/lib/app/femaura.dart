import 'package:femaura/app/login_handler.dart';
import 'package:femaura/core/theme/text_theme.dart';
import 'package:femaura/core/theme/theme.dart';
import 'package:femaura/core/theme/theme_select_handler.dart';
import 'package:femaura/core/utils/scaffold_messenger_key_pod.dart';
import 'package:femaura/routing/femaura_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

class FemAuraApp extends ConsumerStatefulWidget {
  const FemAuraApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FemAuraAppState();
}

class _FemAuraAppState extends ConsumerState<FemAuraApp> {
  @override
  void initState() {
    ref.read(loginHandlerProvider.notifier).isLoggedIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    TextTheme textTheme = createTextTheme(context, "Quicksand", "Quicksand");

    FemAuraTheme theme = FemAuraTheme(textTheme);

    return ToastificationWrapper(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router.config,
        theme: theme.light(),
        darkTheme: theme.dark(),
        highContrastTheme: theme.lightHighContrast(),
        highContrastDarkTheme: theme.darkHighContrast(),
        themeMode: ref.watch(themeSelectHandlerProvider),
        scaffoldMessengerKey: ref.read(scaffoldMessengerKeyPod),
      ),
    );
  }
}
