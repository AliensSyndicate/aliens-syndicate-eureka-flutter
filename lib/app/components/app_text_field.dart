import 'package:flutter/material.dart';
import '../../ui/ui_radius.dart';
import '../../ui/ui_icon.dart';
import '../../ui/ui_size.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.hint,
    this.onChanged,
    this.controller,
    this.showSearchIcon = true,
    super.key,
  });
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool showSearchIcon;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: UiSize.inputHeight,
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: showSearchIcon ? UiIcon.search() : null,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UiRadius.input),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}
