import '../../enums/login_context.dart';

class LoginRequest {
  const LoginRequest({required this.context, this.returnLocation});

  final LoginContext context;
  final String? returnLocation;
}
