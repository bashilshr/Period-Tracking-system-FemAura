import 'package:femaura/routing/app_router.dart';

enum Routes with RoutesMixin {
  firstLaunch('/first-launch'),
  login('/login'),
  signup('/signup'),
  resetPassword('/reset-password'),
  verification('/verification'),
  signupSuccessful('/signup-successful'),
  mainPage('/main-page'),
  recommendation('/recommendation'),
  history('/history'),
  notifications('/notifications'),
  settings('/settings'),
  logCycle('/log-cycle'),
  logSymptoms('/log-symptoms'),
  previousLogCycle('/previous-log-cycle'),
  logDailySymptoms('/log-daily-symptoms');

  const Routes(this.path);

  @override
  final String path;
}
