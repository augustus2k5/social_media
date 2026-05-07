import 'package:app/features/conversation/domain/entities/conversation_entity.dart';
import 'package:app/features/conversation/domain/repositories/conversation_repository.dart';

class FetchConversationsUsecase {
  final ConversationRepository repository;

  FetchConversationsUsecase(this.repository);

  Future<List<ConversationEntity>> call() async {
    return repository.fetchConversations();
  }
}