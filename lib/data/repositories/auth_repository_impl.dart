import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_database/firebase_database.dart';
import 'package:dartz/dartz.dart';
import '../../core/errors/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final fb.FirebaseAuth firebaseAuth;
  final DatabaseReference dbRef;

  AuthRepositoryImpl(this.firebaseAuth, this.dbRef);

  @override
  Future<Either<Failure, User>> getUserData(String uid) async {
    try {
      final snapshot = await dbRef.child('users/$uid').get();
      if (!snapshot.exists) {
        return Left(Failure('Usuario no encontrado'));
      }

      final data = snapshot.value as Map<dynamic, dynamic>;

      final user = User(
        id: uid,
        email: data['email'] ?? '',
        name: data['name'] ?? '',
        // otros campos si tienes
      );

      return Right(user);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;

      if (user != null) {
        final snapshot = await dbRef.child('users/${user.uid}').get();
        if (snapshot.exists) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          return Right(
            User(
              id: user.uid,
              email: user.email ?? '',
              name: data['name'] ?? '',
              photoUrl: data['photoUrl'],
              createdAt: data['createdAt'],
            ),
          );
        } else {
          return Left(Failure('User data not found in database'));
        }
      } else {
        return Left(Failure('User not found'));
      }
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;

      if (user != null) {
        final userData = {
          'name': name,
          'email': email,
          'photoUrl': user.photoURL,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        };

        await dbRef.child('users/${user.uid}').set(userData);

        return Right(
          User(
            id: user.uid,
            email: email,
            name: name,
            photoUrl: user.photoURL,
            createdAt: userData['createdAt'] as int,
          ),
        );
      } else {
        return Left(Failure('User creation failed'));
      }
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
