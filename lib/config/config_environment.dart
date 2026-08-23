enum AppEnvironment { development, staging, production }

abstract final class EnvironmentConfig {
  static const name = String.fromEnvironment(
    'EUREKA_ENV',
    defaultValue: 'development',
  );

  static AppEnvironment get current => switch (name) {
    'production' => AppEnvironment.production,
    'staging' => AppEnvironment.staging,
    _ => AppEnvironment.development,
  };

  static const firebaseEnabled = bool.fromEnvironment(
    'EUREKA_FIREBASE_ENABLED',
    defaultValue: true,
  );

  static const analyticsEnabled = bool.fromEnvironment(
    'EUREKA_ANALYTICS_ENABLED',
    defaultValue: false,
  );

  static const appCheckEnabled = bool.fromEnvironment(
    'EUREKA_APP_CHECK_ENABLED',
    defaultValue: false,
  );

  static const crashReportingEnabled = bool.fromEnvironment(
    'EUREKA_CRASH_REPORTING_ENABLED',
    defaultValue: false,
  );
}
