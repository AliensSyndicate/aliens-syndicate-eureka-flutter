import 'package:flutter/material.dart';

import '../../l10n/app_strings.dart';
import '../../pages/explore/page_explore.dart';
import '../../pages/home/page_home.dart';
import '../../pages/profile/page_profile.dart';
import '../../pages/simulation/page_simulation.dart';
import '../../pages/social/page_social.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_icon.dart';
import '../../ui/ui_navigation.dart';

class NavigationApp extends StatefulWidget {
  const NavigationApp({super.key});
  @override
  State<NavigationApp> createState() => _NavigationAppState();
}

class _NavigationAppState extends State<NavigationApp> {
  int index = 0;
  static const pages = [
    PageHome(),
    PageSocial(),
    PageExplore(),
    PageSimulation(),
    PageProfile(),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: IndexedStack(index: index, children: pages),
    ),
    bottomNavigationBar: DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: UiColor.divider,
            width: UiNavigation.topBorderWidth,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: [
          NavigationDestination(icon: UiIcon.home(), label: AppStrings.home),
          NavigationDestination(
            icon: UiIcon.social(),
            label: AppStrings.social,
          ),
          NavigationDestination(
            icon: UiIcon.search(),
            label: AppStrings.explore,
          ),
          NavigationDestination(
            icon: UiIcon.simulated(),
            label: AppStrings.simulation,
          ),
          NavigationDestination(
            icon: UiIcon.profile(),
            label: AppStrings.profile,
          ),
        ],
      ),
    ),
  );
}
