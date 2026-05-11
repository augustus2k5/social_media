import 'package:app/features/conversation/domain/entities/conversation_entity.dart';

abstract class ConversationState {}

class ConversationsInitial extends ConversationState {

}

class ConversationsLoading extends ConversationState {
  
}

class ConversationsLoaded extends ConversationState {
  final List<ConversationEntity> conversations;

  ConversationsLoaded(this.conversations);
}

class ConversationsError extends ConversationState {
  final String message;

  ConversationsError(this.message);
}