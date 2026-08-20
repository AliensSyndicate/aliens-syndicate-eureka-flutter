import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/navigation/navigation_router.dart';
import 'l10n/app_strings.dart';
import 'services/service_firebase.dart';
import 'services/service_registry.dart';
import 'ui/ui_color.dart';
import 'ui/ui_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<dynamic>('eureka');
  await Hive.openBox<dynamic>('content_cache_v1');
  await FirebaseService.initialize();
  await ServiceRegistry.content.syncManifest().timeout(
    const Duration(seconds: 4),
    onTimeout: () => false,
  );
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: UiColor.background,
      systemNavigationBarColor: UiColor.background,
      systemNavigationBarDividerColor: UiColor.background,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    ),
  );
  runApp(const EurekaApp());
}

class EurekaApp extends StatelessWidget {
  const EurekaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: AppStrings.appName,
    debugShowCheckedModeBanner: false,
    theme: UiTheme.dark,
    routerConfig: appRouter,
  );
}
