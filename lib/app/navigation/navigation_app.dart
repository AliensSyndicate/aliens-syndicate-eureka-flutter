import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../pages/explore/page_explore.dart';
import '../../pages/home/page_home.dart';
import '../../pages/profile/page_profile.dart';
import '../../pages/simulation/page_simulation.dart';
import '../../pages/social/page_social.dart';
import '../../ui/ui_icon.dart';

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
    bottomNavigationBar: NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (value) => setState(() => index = value),
      destinations: const [
        NavigationDestination(icon: Icon(UiIcon.home), label: AppStrings.home),
        NavigationDestination(
          icon: Icon(UiIcon.social),
          label: AppStrings.social,
        ),
        NavigationDestination(
          icon: Icon(UiIcon.explore),
          label: AppStrings.explore,
        ),
        NavigationDestination(
          icon: Icon(UiIcon.simulation),
          label: AppStrings.simulation,
        ),
        NavigationDestination(
          icon: Icon(UiIcon.profile),
          label: AppStrings.profile,
        ),
      ],
    ),
  );
}
