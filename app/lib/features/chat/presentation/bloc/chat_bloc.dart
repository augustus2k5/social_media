import 'package:app/core/socket_service.dart';
import 'package:app/features/chat/domain/entities/message_entity.dart';
import 'package:app/features/chat/domain/usecases/fetch_messages_use_case.dart';
import 'package:app/features/chat/presentation/bloc/chat_event.dart';
import 'package:app/features/chat/presentation/bloc/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app/features/chat/domain/usecases/send_message_use_case.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FetchMessagesUseCase fetchMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;

  final SocketService _socketService = SocketService();

  final List<MessageEntity> _messages = [];
  final _storage = FlutterSecureStorage();

  ChatBloc({
    required this.fetchMessagesUseCase,
    required this.sendMessageUseCase,
  }) : super(ChatLoadingState()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<ReceiveMessageEvent>(_onReceiveMessage);

    _initializeSocket();
  }

  Future<void> _initializeSocket() async {
    await _socketService.connect();

    _socketService.socket?.on("receiveMessage", (data) {
      print("RECEIVED: $data");

      add(ReceiveMessageEvent(data));
    });
  }

  Future<void> _onLoadMessages(
    LoadMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoadingState());

    try {
      final messages = await fetchMessagesUseCase(event.conversationId);

      _messages.clear();

      _messages.addAll(messages);

      emit(ChatLoadedState(List.from(_messages)));

      _socketService.socket?.emit("joinConversation", event.conversationId);
    } catch (e) {
      emit(ChatErrorState("Error: $e"));
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,

    Emitter<ChatState> emit,
  ) async {
    try {
      final message = await sendMessageUseCase(
        receiverId: event.receiverId,

        content: event.content,
      );

      _messages.add(message);

      emit(MessageSentState(List.from(_messages)));
    } catch (e) {
      emit(ChatErrorState("Failed to send message"));
    }
  }

  Future<void> _onReceiveMessage(
    ReceiveMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    print("STEP 2 - RECEIVE EVENT");

    print(event.message);

    final data = event.message;

    final message = MessageEntity(
      id: data["_id"],

      conversationId: data["conversationId"],

      senderId: data["senderId"],

      content: data["content"],

      isRead: data["isRead"] ?? false,

      createdAt: DateTime.parse(data["createdAt"]),

      updatedAt: DateTime.parse(data["updatedAt"]),
    );

    _messages.add(message);

    emit(ChatLoadedState(List.from(_messages)));
  }
}
