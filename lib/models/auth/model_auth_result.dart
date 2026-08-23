enum AuthProvider { google, apple }

enum AuthResultStatus { authenticated, cancelled, error }

class AuthResult {
  const AuthResult._(this.status, {this.message});

  const AuthResult.authenticated() : this._(AuthResultStatus.authenticated);
  const AuthResult.cancelled() : this._(AuthResultStatus.cancelled);
  const AuthResult.error(String message)
    : this._(AuthResultStatus.error, message: message);

  final AuthResultStatus status;
  final String? message;
}
