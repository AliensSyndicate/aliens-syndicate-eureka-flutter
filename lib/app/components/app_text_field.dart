import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../ui/ui_radius.dart';
import '../../ui/ui_icon.dart';
import '../../ui/ui_size.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.hint,
    this.onChanged,
    this.controller,
    this.inputFormatters,
    this.showSearchIcon = true,
    super.key,
  });
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final bool showSearchIcon;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: UiSize.inputHeight,
    child: TextField(
      controller: controller,
      inputFormatters: inputFormatters,
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
