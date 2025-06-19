import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nolatech_messenger/domain/usecases/send_message.dart';
import 'package:nolatech_messenger/domain/entities/message.dart';
import '../../helpers/mocks.mocks.dart';

void main() {
  late SendUserMessage sendMessage;
  late MockChatRepository mockChatRepository;

  setUp(() {
    mockChatRepository = MockChatRepository();
    sendMessage = SendUserMessage(mockChatRepository);
  });

  final testChatId = 'chat123';
  final testMessage = Message(
    id: 'msg123',
    senderId: 'uid123',
    content: 'Hola',
    timestamp: DateTime.now(),
  );

  test('should call sendMessage in repository', () async {
    when(
      mockChatRepository.sendMessage(testChatId, testMessage),
    ).thenAnswer((_) async {});

    await sendMessage(testChatId, testMessage);

    verify(mockChatRepository.sendMessage(testChatId, testMessage)).called(1);
  });
}
