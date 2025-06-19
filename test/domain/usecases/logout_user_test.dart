import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:nolatech_messenger/domain/usecases/logout_user.dart';
import 'package:nolatech_messenger/core/errors/failure.dart';

import '../../helpers/mocks.mocks.dart';

void main() {
  late LogoutUser logoutUser;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    logoutUser = LogoutUser(mockAuthRepository);
  });

  test('should return void on successful logout', () async {
    when(mockAuthRepository.logout()).thenAnswer((_) async => Right(null));

    final result = await logoutUser();

    expect(result.isRight(), true);
  });

  test('should return Failure on logout error', () async {
    final failure = Failure('Logout failed');

    when(mockAuthRepository.logout()).thenAnswer((_) async => Left(failure));

    final result = await logoutUser();

    expect(result.isLeft(), true);
    expect(result.swap().getOrElse(() => Failure('')), failure);
  });
}
