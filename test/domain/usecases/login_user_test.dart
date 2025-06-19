import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:nolatech_messenger/domain/usecases/login_user.dart';
import 'package:nolatech_messenger/domain/entities/user.dart';
import 'package:nolatech_messenger/core/errors/failure.dart';
import '../../helpers/mocks.mocks.dart';

void main() {
  late LoginUser loginUser;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginUser = LoginUser(mockAuthRepository);
  });

  final testEmail = 'test@example.com';
  final testPassword = 'password123';
  final testUser = User(id: 'uid123', email: testEmail, name: 'User Test');

  test('should return User on successful login', () async {
    when(
      mockAuthRepository.login(testEmail, testPassword),
    ).thenAnswer((_) async => Right(testUser));

    final result = await loginUser(testEmail, testPassword);

    expect(result.isRight(), true);
    expect(result.getOrElse(() => User(id: '', email: '', name: '')), testUser);
  });

  test('should return Failure on login error', () async {
    final failure = Failure('Login failed');

    when(
      mockAuthRepository.login(testEmail, testPassword),
    ).thenAnswer((_) async => Left(failure));

    final result = await loginUser(testEmail, testPassword);

    expect(result.isLeft(), true);
    expect(result.swap().getOrElse(() => Failure('')), failure);
  });
}
