import 'package:eureka/ui/ui_color.dart';
import 'package:eureka/ui/ui_text.dart';
import 'package:flutter/material.dart';

import '../../ui/ui_bottom_sheet.dart';
import '../../ui/ui_navigation.dart';
import '../../ui/ui_spacing.dart';

class AppBottomSheet {
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    Widget? header,
    List<Widget> actions = const [],
    bool isDismissible = true,
    bool enableDrag = true,
    Color titleColor = UiColor.accent,
  }) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxSheetHeight = screenHeight - statusBarHeight;

    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: UiColor.background,
      barrierColor: UiBottomSheet.overlayColor,
      sheetAnimationStyle: const AnimationStyle(
        duration: UiBottomSheet.openDuration,
        reverseDuration: UiBottomSheet.closeDuration,
      ),
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      builder: (context) {
        final sheet = SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: header == null
                ? EdgeInsets.fromLTRB(
                    UiBottomSheet.horizontalPadding,
                    UiBottomSheet.topPadding,
                    UiBottomSheet.horizontalPadding,
                    MediaQuery.viewInsetsOf(context).bottom +
                        UiBottomSheet.bottomPadding,
                  )
                : EdgeInsets.only(
                    bottom:
                        MediaQuery.viewInsetsOf(context).bottom +
                        UiBottomSheet.bottomPadding,
                  ),
            child: header == null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          style: UiText.h4.copyWith(color: titleColor),
                        ),
                      ),
                      const SizedBox(height: UiSpacing.md),
                      content,
                      if (actions.isNotEmpty) ...[
                        const SizedBox(height: UiSpacing.lg),
                        ...actions,
                      ],
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      header,
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          UiBottomSheet.horizontalPadding,
                          UiSpacing.headerBottomGap,
                          UiBottomSheet.horizontalPadding,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            content,
                            if (actions.isNotEmpty) ...[
                              const SizedBox(height: UiSpacing.lg),
                              ...actions,
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        );
        return DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: UiColor.outline,
                width: UiNavigation.topBorderWidth,
              ),
            ),
          ),
          child: sheet,
        );
      },
    );
  }
}
