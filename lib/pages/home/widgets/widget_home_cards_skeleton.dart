import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';

class HomeCardsSkeleton extends StatelessWidget {
  const HomeCardsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: AppStrings.loadingContent,
      child: const ExcludeSemantics(
        child: SizedBox.expand(),
      ),
    );
  }
}
