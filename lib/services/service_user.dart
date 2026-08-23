import '../interfaces/repository_user.dart';
import '../models/model_user.dart';

class UserService {
  UserService(this._repository);
  final UserRepository _repository;
  static const temporaryUser = AppUser(
    id: 'local_test_user',
    displayName: 'Explorador',
    schoolYear: 5,
    isTemporary: true,
  );
  AppUser loadCurrentUser() {
    return _repository.loadCurrentUser() ?? temporaryUser;
  }

  bool get isAuthenticated => !loadCurrentUser().isTemporary;
}
