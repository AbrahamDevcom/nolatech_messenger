import '../repositories/auth_repository.dart';
import '../../core/errors/failure.dart';
import 'package:dartz/dartz.dart';
import '../entities/user.dart';

class GetUserData {
  final AuthRepository repository;

  GetUserData(this.repository);

  Future<Either<Failure, User>> call(String uid) {
    return repository.getUserData(uid);
  }
}
