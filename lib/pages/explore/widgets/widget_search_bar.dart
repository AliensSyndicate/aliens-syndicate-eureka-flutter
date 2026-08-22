import 'package:flutter/material.dart';

import '../../../l10n/app_strings.dart';
import '../../../ui/ui_color.dart';
import '../../../ui/ui_icon.dart';
import '../../../ui/ui_radius.dart';
import '../../../ui/ui_size.dart';
import '../../../ui/ui_text.dart';

/// Campo de busca principal do Explorar.
///
/// Exibe ícone de lupa, placeholder humanizado e botão × para limpar.
/// A busca acontece automaticamente (via debounce no controller);
/// o botão de teclado `search` dispara [onSubmitted].
class ExploreSearchBar extends StatefulWidget {
  const ExploreSearchBar({
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    this.initialValue = '',
    super.key,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onClear;
  final String initialValue;

  @override
  State<ExploreSearchBar> createState() => _ExploreSearchBarState();
}

class _ExploreSearchBarState extends State<ExploreSearchBar> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _hasText = widget.initialValue.isNotEmpty;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    final hasText = value.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
    widget.onChanged(value);
  }

  void _handleClear() {
    _controller.clear();
    setState(() => _hasText = false);
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: UiSize.inputHeight,
    child: TextField(
      controller: _controller,
      onChanged: _handleChanged,
      onSubmitted: (_) => widget.onSubmitted(),
      textAlignVertical: TextAlignVertical.center,
      textInputAction: TextInputAction.search,
      style: UiText.p.copyWith(color: UiColor.textPrimary),
      decoration: InputDecoration(
        hintText: AppStrings.exploreSearchHint,
        hintStyle: UiText.p.copyWith(color: UiColor.textDisabled),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: UiIcon.search(color: UiColor.textDisabled),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        suffixIcon: _hasText
            ? GestureDetector(
                onTap: _handleClear,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: UiIcon.close(
                    size: UiSize.iconSm,
                    color: UiColor.textSecondary,
                  ),
                ),
              )
            : null,
        filled: true,
        fillColor: UiColor.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiRadius.input),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiRadius.input),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiRadius.input),
          borderSide: const BorderSide(color: UiColor.accent, width: 1.5),
        ),
        contentPadding: EdgeInsets.zero,
      ),
    ),
  );
}
