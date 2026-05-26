import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/conversation/domain/entities/conversation_entity.dart';
import 'package:app/features/conversation/domain/usecases/fetch_conversations_usecase.dart';
import 'package:app/features/conversation/presentation/bloc/conversation_event.dart';
import 'package:app/features/conversation/presentation/bloc/conversation_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final FetchConversationsUsecase fetchConversationsUseCase;

  ConversationBloc({required this.fetchConversationsUseCase})
    : super(ConversationsInitial()) {
    on<FetchConversations>(_onFetchConversations);
  }

  Future<void> _onFetchConversations(
    FetchConversations event,
    Emitter<ConversationState> emit,
  ) async {
    emit(ConversationsLoading());

    try {
      final conversations = await fetchConversationsUseCase();
      // final conversations = [
      //   ConversationEntity(
      //     id: "1",
      //     lastMessage: "Hello bro",
      //     lastMessageTime: DateTime.now(),
      //     user: UserEntity(id: "1", email: "test@gmail.com", username: "Kaori", avatar: "", role: "user"),
      //   ),
      // ];
      emit(ConversationsLoaded(conversations));
    } catch (e) {
      print(e);
      emit(ConversationsError(e.toString()));
    }
  }
}
