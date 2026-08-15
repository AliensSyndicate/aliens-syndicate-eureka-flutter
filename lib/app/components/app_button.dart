import 'package:flutter/material.dart';
import '../../ui/ui_button.dart';
import '../../ui/ui_color.dart';
import '../../ui/ui_text.dart';

class AppButton extends StatefulWidget {
  const AppButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  bool get isEnabled => onPressed != null && !isLoading;
  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.isEnabled;
    final topColor = enabled ? UiColor.primary : UiColor.surfaceElevated;
    final depthColor = enabled
        ? Color.lerp(UiColor.primary, UiColor.background, .28)!
        : UiColor.divider;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
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
            AnimatedPositioned(
              duration: const Duration(milliseconds: 70),
              curve: Curves.easeOut,
              left: 0,
              right: 0,
              top: pressed ? UiButton.pressedOffset : 0,
              height: UiButton.height,
              child: Listener(
                onPointerDown: enabled
                    ? (_) => setState(() => pressed = true)
                    : null,
                onPointerUp: enabled
                    ? (_) => setState(() => pressed = false)
                    : null,
                onPointerCancel: enabled
                    ? (_) => setState(() => pressed = false)
                    : null,
                child: FilledButton(
                  onPressed: enabled ? widget.onPressed : null,
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
                    textStyle: const TextStyle(
                      fontFamily: UiText.fontFamily,
                      fontSize: UiButton.fontSize,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .5,
                    ),
                  ),
                  child: widget.isLoading
                      ? const SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: UiColor.background,
                          ),
                        )
                      : Text(widget.label.toUpperCase()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
