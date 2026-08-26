import 'package:flutter/material.dart';

import '../../app/components/app_bottom_sheet.dart';
import '../../l10n/app_strings.dart';
import '../../models/auth/model_login_request.dart';
import 'widget_login_content.dart';

Future<bool> showLoginBottomSheet(
  BuildContext context,
  LoginRequest request,
) async =>
    await AppBottomSheet.show<bool>(
      context,
      title: AppStrings.loginTitle(request.context),
      content: Builder(
        builder: (sheetContext) => LoginContent(
          request: request,
          showHeading: false,
          onAuthenticated: () => Navigator.of(sheetContext).pop(true),
        ),
      ),
    ) ??
    false;
