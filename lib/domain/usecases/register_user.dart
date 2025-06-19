import '../repositories/auth_repository.dart';
import '../../core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import '../entities/user.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<Either<Failure, User>> call(
    String name,
    String email,
    String password,
  ) {
    return repository.register(name, email, password);
  }
}
