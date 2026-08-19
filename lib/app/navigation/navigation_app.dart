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

  // Helper para criar o ícone com o círculo de fundo dinâmico
  Widget _buildNavIcon({required Widget icon, required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Quando selecionado, usa UiColor.accent com opacidade (ex: 0.2). Quando não, fica transparente.
        color: isSelected
            ? UiColor.accent.withValues(
                alpha: 0.2,
              ) // Ou .withOpacity(0.2) dependendo da sua versão do Flutter
            : Colors.transparent,
      ),
      child: icon,
    );
  }

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
        // Removemos o indicador padrão oval/pílula do Material 3 deixando-o transparente
        indicatorColor: Colors.transparent,
        destinations: [
          NavigationDestination(
            icon: _buildNavIcon(icon: UiIcon.home(), isSelected: index == 0),
            label: AppStrings.home,
          ),
          NavigationDestination(
            icon: _buildNavIcon(icon: UiIcon.social(), isSelected: index == 1),
            label: AppStrings.social,
          ),
          NavigationDestination(
            icon: _buildNavIcon(icon: UiIcon.search(), isSelected: index == 2),
            label: AppStrings.explore,
          ),
          NavigationDestination(
            icon: _buildNavIcon(
              icon: UiIcon.simulated(),
              isSelected: index == 3,
            ),
            label: AppStrings.simulation,
          ),
          NavigationDestination(
            icon: _buildNavIcon(icon: UiIcon.profile(), isSelected: index == 4),
            label: AppStrings.profile,
          ),
        ],
      ),
    ),
  );
}
