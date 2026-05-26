import 'package:app/features/auth/data/datasources/token_service.dart';
import 'package:app/features/chat/data/datasources/messages_remote_data_source.dart';
import 'package:app/features/chat/domain/entities/message_entity.dart';
import 'package:app/features/chat/domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageRemoteDataSource remoteDataSource;

  final TokenService tokenService;

  MessageRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenService,
  });

  @override
  Future<List<MessageEntity>> fetchMessages(String conversationId) async {
    final token = await tokenService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token not found");
    }

    return await remoteDataSource.fetchMessages(
      token: token,
      conversationId: conversationId,
    );
  }

  @override
  Future<MessageEntity> sendMessage({
    required String receiverId,
    required String content,
  }) async {
    final token = await tokenService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token not found");
    }

    return await remoteDataSource.sendMessage(
      token: token,
      receiverId: receiverId,
      content: content,
    );
  }
}
