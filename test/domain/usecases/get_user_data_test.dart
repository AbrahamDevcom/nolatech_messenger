import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:nolatech_messenger/domain/usecases/get_user.dart';
import 'package:nolatech_messenger/domain/entities/user.dart';
import 'package:nolatech_messenger/core/errors/failure.dart';
import '../../helpers/mocks.mocks.dart';

void main() {
  late GetUserData getUserData;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    getUserData = GetUserData(mockAuthRepository);
  });

  final testUserId = 'uid123';
  final testUser = User(
    id: testUserId,
    email: 'test@example.com',
    name: 'User Test',
  );

  test('should return User data successfully', () async {
    when(
      mockAuthRepository.getUserData(testUserId),
    ).thenAnswer((_) async => Right(testUser));

    final result = await getUserData(testUserId);

    expect(result.isRight(), true);
    expect(result.getOrElse(() => User(id: '', email: '', name: '')), testUser);
  });

  test('should return Failure on error', () async {
    final failure = Failure('User not found');

    when(
      mockAuthRepository.getUserData(testUserId),
    ).thenAnswer((_) async => Left(failure));

    final result = await getUserData(testUserId);

    expect(result.isLeft(), true);
    expect(result.swap().getOrElse(() => Failure('')), failure);
  });
}
