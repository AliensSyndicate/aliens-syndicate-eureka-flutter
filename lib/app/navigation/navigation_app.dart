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
            color: UiColor.background,
            width: UiNavigation.topBorderWidth,
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        indicatorColor: Colors.transparent,
        destinations: [
          NavigationDestination(
            icon: index == 0 ? UiIcon.navHomeSelected() : UiIcon.navHome(),
            label: AppStrings.home,
          ),
          NavigationDestination(
            icon: index == 1 ? UiIcon.navSocialSelected() : UiIcon.navSocial(),
            label: AppStrings.social,
          ),
          NavigationDestination(
            icon: index == 2 ? UiIcon.navSearchSelected() : UiIcon.navSearch(),
            label: AppStrings.explore,
          ),
          NavigationDestination(
            icon: index == 3
                ? UiIcon.navSimulatedSelected()
                : UiIcon.navSimulated(),
            label: AppStrings.simulation,
          ),
          NavigationDestination(
            icon: index == 4
                ? UiIcon.navProfileSelected()
                : UiIcon.navProfile(),
            label: AppStrings.profile,
          ),
        ],
      ),
    ),
  );
}
