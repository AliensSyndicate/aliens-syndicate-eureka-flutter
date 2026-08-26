abstract final class ProductConfig {
  static const v1SchoolYear = 5;
  static const availableSchoolYears = [v1SchoolYear];
  static const socialEnabled = false;
  static const termsUrl = String.fromEnvironment(
    'EUREKA_TERMS_URL',
    defaultValue: 'https://aliens-syndicate-docs.web.app/apps/eureka/terms',
  );
  static const privacyUrl = String.fromEnvironment(
    'EUREKA_PRIVACY_URL',
    defaultValue: 'https://aliens-syndicate-docs.web.app/apps/eureka/policy',
  );
}
