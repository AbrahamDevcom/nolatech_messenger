import '../repositories/auth_repository.dart';
import '../../core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import '../entities/user.dart';

class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<Either<Failure, User>> call(String email, String password) {
    return repository.login(email, password);
  }
}
