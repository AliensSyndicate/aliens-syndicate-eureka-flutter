import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_strings.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_icon.dart';
import '../../ui/ui_navigation.dart';

class NavigationApp extends StatelessWidget {
  const NavigationApp({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final isHome = navigationShell.currentIndex == 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Stack(
        children: [
          if (isHome)
            Positioned.fill(
              child: Image.asset(
                'assets/images/home.png',
                fit: BoxFit.cover,
              ),
            ),
          Scaffold(
            backgroundColor: isHome ? Colors.transparent : UiColor.background,
            body: SafeArea(
              child: navigationShell,
            ),
            bottomNavigationBar: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: UiNavigation.topBorderWidth,
                  color: UiColor.outline,
                ),
                NavigationBar(
                  backgroundColor: UiColor.background,
                  elevation: 0,
                  selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: (value) => navigationShell.goBranch(
                  value,
                  initialLocation: value == navigationShell.currentIndex,
                ),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                indicatorColor: Colors.transparent,
                destinations: [
                  NavigationDestination(
                    icon: navigationShell.currentIndex == 0
                        ? UiIcon.navHomeSelected()
                        : UiIcon.navHome(),
                    label: AppStrings.home,
                  ),
                  NavigationDestination(
                    icon: navigationShell.currentIndex == 1
                        ? UiIcon.navSocialSelected()
                        : UiIcon.navSocial(),
                    label: AppStrings.social,
                  ),
                  NavigationDestination(
                    icon: navigationShell.currentIndex == 2
                        ? UiIcon.navSearchSelected()
                        : UiIcon.navSearch(),
                    label: AppStrings.explore,
                  ),
                  NavigationDestination(
                    icon: navigationShell.currentIndex == 3
                        ? UiIcon.navSimulatedSelected()
                        : UiIcon.navSimulated(),
                    label: AppStrings.simulation,
                  ),
                  NavigationDestination(
                    icon: navigationShell.currentIndex == 4
                        ? UiIcon.navProfileSelected()
                        : UiIcon.navProfile(),
                    label: AppStrings.profile,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
  }
}
