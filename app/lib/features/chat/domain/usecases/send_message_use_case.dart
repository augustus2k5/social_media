import 'package:app/features/chat/domain/entities/message_entity.dart';
import 'package:app/features/chat/domain/repositories/message_repository.dart';

class SendMessageUseCase {

  final MessageRepository
      messagesRepository;

  SendMessageUseCase({
    required this.messagesRepository,
  });

  Future<MessageEntity> call({

    required String receiverId,

    required String content,

  }) async {

    return await messagesRepository
        .sendMessage(

      receiverId: receiverId,

      content: content,
    );
  }
}