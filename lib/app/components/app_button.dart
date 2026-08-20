import 'package:flutter/material.dart';

import '../../ui/ui_button.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_text.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.color,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;
  bool get isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = isEnabled;
    final activeColor = color ?? UiColor.primary;
    final topColor = enabled ? activeColor : UiColor.surfaceElevated;
    final depthColor = enabled
        ? Color.lerp(activeColor, UiColor.background, .28)!
        : UiColor.divider;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: SizedBox(
        height: UiButton.height + UiButton.bottomDepth,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              top: UiButton.bottomDepth,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: depthColor,
                  borderRadius: BorderRadius.circular(UiButton.radius),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: UiButton.height,
              child: FilledButton(
                onPressed: enabled ? onPressed : null,
                style: FilledButton.styleFrom(
                  backgroundColor: topColor,
                  disabledBackgroundColor: topColor,
                  foregroundColor: UiColor.background,
                  disabledForegroundColor: UiColor.textDisabled,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: UiButton.horizontalPadding,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(UiButton.radius),
                  ),
                  textStyle: UiText.h6.copyWith(),
                ),
                child: isLoading
                    ? const SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: UiColor.background,
                        ),
                      )
                    : Text(label.toUpperCase()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
