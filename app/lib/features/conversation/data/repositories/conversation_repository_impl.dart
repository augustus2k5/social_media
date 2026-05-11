import 'package:app/features/auth/data/datasources/token_service.dart';
import 'package:app/features/conversation/data/datasources/conversation_remote_data_source.dart';
import 'package:app/features/conversation/domain/entities/conversation_entity.dart';
import 'package:app/features/conversation/domain/repositories/conversation_repository.dart';

class ConversationRepositoryImpl implements ConversationRepository {

  final ConversationRemoteDataSource remoteDataSource;
  final TokenService tokenService;

  ConversationRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenService,
  });

  @override
  Future<List<ConversationEntity>> fetchConversations() async {

    final token = await tokenService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token not found");
    }

    return await remoteDataSource.fetchConversations(
      token: token,
    );
  }
}