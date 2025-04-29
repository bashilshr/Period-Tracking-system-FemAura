mixin EndpointMixin on Enum {
  String get path;
}

enum Endpoint with EndpointMixin {
  login('login/'),
  register('register/'),
  verifyEmailOtp('verify/'),
  refreshToken('api/token/refresh/'),
  logout('logout/'),
  profile('profile/'),
  recommendations('api/recommendations/'),
  phasePrediction('phase-prediction/'),
  logPreviousCycle('log/log-previous/'),
  logDailyCycle('log/log_daily'),
  getPeriodHistory('get-period-history/'),
  logDailyStatus('log/log-daily-status/'),
  getHistoryGraph('graph/history-graph/');

  const Endpoint(this.path);

  @override
  final String path;
}
