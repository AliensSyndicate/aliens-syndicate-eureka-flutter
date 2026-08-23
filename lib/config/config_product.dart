abstract final class ProductConfig {
  static const v1SchoolYear = 5;
  static const availableSchoolYears = [v1SchoolYear];
  static const socialEnabled = false;
  static const authenticationEnabled = bool.fromEnvironment(
    'EUREKA_AUTH_ENABLED',
    defaultValue: false,
  );
  static const termsUrl = String.fromEnvironment('EUREKA_TERMS_URL');
  static const privacyUrl = String.fromEnvironment('EUREKA_PRIVACY_URL');
}
