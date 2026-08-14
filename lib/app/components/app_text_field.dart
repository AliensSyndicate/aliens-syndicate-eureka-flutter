import 'package:flutter/material.dart';
import '../../ui/ui_radius.dart';

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
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: showSearchIcon ? const Icon(Icons.search) : null,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(UiRadius.md),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
