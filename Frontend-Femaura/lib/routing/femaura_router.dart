import 'dart:async';
import 'package:femaura/features/auth/presentation/login/login_view.dart';
import 'package:femaura/features/auth/presentation/otp_verification/otp_verify_view.dart';
import 'package:femaura/features/auth/presentation/reset_password/reset_password_view.dart';
import 'package:femaura/features/auth/presentation/signup/signup_view.dart';
import 'package:femaura/features/auth/presentation/signup_success/signup_success_view.dart';
import 'package:femaura/features/first_time/presentation/first_time_app_view.dart';
import 'package:femaura/features/home/presentation/home_scaffold/home_scaffold_view.dart';
import 'package:femaura/features/home/presentation/history/history_view.dart';
import 'package:femaura/features/home/presentation/main_page/main_page_view.dart';
import 'package:femaura/features/home/presentation/notifications/notifications_view.dart';
import 'package:femaura/features/home/presentation/previous_log_cycle/previous_log_cycle_page.dart';
import 'package:femaura/features/home/presentation/recommendation/recommendation_page_view.dart';
import 'package:femaura/features/log_cycle/presentation/basic_info_log/basic_info_log_view.dart';
import 'package:femaura/features/log_cycle/presentation/daily_symptoms_log/daily_symptoms_log_view.dart';
import 'package:femaura/features/log_cycle/presentation/symptoms_info_log/symptoms_info_log_view.dart';
import 'package:femaura/features/settings/presentation/settings_view.dart';
import 'package:femaura/routing/app_router.dart';
import 'package:femaura/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final class FemAuraRouter extends AppRouter<Routes> {
  FemAuraRouter() : super(initialLocation: Routes.login);

  @override
  List<AppRouteBase> get routes {
    return [
      AppRoute(
        route: Routes.firstLaunch,
        builder: (context, state) => const FirstTimeAppView(),
      ),
      AppRoute(
        route: Routes.login,
        builder: (context, state) => const LoginView(),
      ),
      AppRoute(
        route: Routes.signup,
        builder: (context, state) => const SignupView(),
      ),
      AppRoute(
        route: Routes.signupSuccessful,
        builder: (context, state) => const SignupSuccessView(),
      ),
      AppRoute(
        route: Routes.resetPassword,
        builder: (context, state) => const ResetPasswordView(),
      ),
      AppRoute(
        route: Routes.verification,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return OtpVerifyView(verifyFor: extra['for'], email: extra['email']);
        },
      ),
      ShellRoute(
        routes: [
          AppRoute(
            route: Routes.mainPage,
            builder: (context, state) => const MainPageView(),
          ),
          AppRoute(
            route: Routes.recommendation,
            builder: (context, state) => const RecommendationPageView(),
          ),
          AppRoute(
            route: Routes.history,
            builder: (context, state) => const HistoryView(),
          ),
          AppRoute(
            route: Routes.notifications,
            builder: (context, state) => const NotificationsView(),
          ),
        ],
        builder: (context, state, child) {
          return HomeScaffoldView(child: child);
        },
      ),
      AppRoute(
        route: Routes.settings,
        builder: (context, state) => const SettingsView(),
      ),
      AppRoute(
        route: Routes.logCycle,
        builder: (context, state) => const BasicInfoLogView(),
      ),
      AppRoute(
        route: Routes.logSymptoms,
        builder: (context, state) => const SymptomsInfoLogView(),
      ),
      AppRoute(
        route: Routes.previousLogCycle,
        builder: (context, state) => const PreviousLogCyclePage(),
      ),
      AppRoute(
        route: Routes.logDailySymptoms,
        builder: (context, state) => const DailySymptomsLogView(),
      ),
    ];
  }

  @override
  FutureOr<String?>? redirect(BuildContext context, AppRouterState state) {
    return null;
  }
}

final routerProvider = AppRouterProvider((_) => FemAuraRouter());
