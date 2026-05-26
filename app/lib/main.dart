import 'package:app/features/chat/data/datasources/messages_remote_data_source.dart';
import 'package:app/features/chat/data/repositories/message_repository_impl.dart';
import 'package:app/features/chat/domain/usecases/fetch_messages_use_case.dart';
import 'package:app/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:app/core/theme.dart';
import 'package:app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:app/features/auth/data/datasources/token_service.dart';
import 'package:app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app/features/auth/domain/usecases/login_use_case.dart';
import 'package:app/features/auth/domain/usecases/register_use_case.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/auth/presentation/pages/login_page.dart';
import 'package:app/features/conversation/data/datasources/conversation_remote_data_source.dart';
import 'package:app/features/conversation/data/repositories/conversation_repository_impl.dart';
import 'package:app/features/conversation/domain/usecases/fetch_conversations_usecase.dart';
import 'package:app/features/conversation/presentation/bloc/conversation_bloc.dart';
import 'package:app/features/conversation/presentation/pages/conversations_page.dart';
import 'package:app/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/features/chat/domain/usecases/send_message_use_case.dart';

void main() {
  final authRepository = AuthRepositoryImpl(
    authRemoteDataSource: AuthRemoteDataSource(),
    tokenService: TokenService(),
  );
  final conversationRepository = ConversationRepositoryImpl(
    remoteDataSource: ConversationRemoteDataSource(),
    tokenService: TokenService(),
  );
  final messagesRepository = MessageRepositoryImpl(
    remoteDataSource: MessageRemoteDataSource(),
    tokenService: TokenService(),
  );
  runApp(
    MyApp(
      authRepository: authRepository,
      conversationRepository: conversationRepository,
      messageRepository: messagesRepository,
    ),
  );
}

class MyApp extends StatefulWidget {
  final AuthRepositoryImpl authRepository;
  final ConversationRepositoryImpl conversationRepository;
  final MessageRepositoryImpl messageRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.conversationRepository,
    required this.messageRepository,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? token;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    forceLogout();
  }

  Future<void> forceLogout() async {
    final tokenService = TokenService();

    await tokenService.clearToken();

    setState(() {
      isLoading = false;
      token = null;
    });
  }

  Future<void> checkLogin() async {
    final tokenService = TokenService();
    final savedToken = await tokenService.getToken();

    print("TOKEN KHI MỞ APP: $savedToken");

    setState(() {
      token = savedToken;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            registerUseCase: RegisterUseCase(repository: widget.authRepository),
            loginUseCase: LoginUseCase(repository: widget.authRepository),
          ),
        ),
        BlocProvider(
          create: (_) => ConversationBloc(
            fetchConversationsUseCase: FetchConversationsUsecase(
              widget.conversationRepository,
            ),
          ),
        ),
        BlocProvider(
          create: (_) => ChatBloc(
            fetchMessagesUseCase: FetchMessagesUseCase(
              messagesRepository: widget.messageRepository,
            ),

            sendMessageUseCase: SendMessageUseCase(
              messagesRepository: widget.messageRepository,
            ),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: token != null ? ConversationsPage() : LoginPage(),

        routes: {
          "/login": (_) => LoginPage(),
          "/register": (_) => RegisterPage(),
          "/conversationsPage": (_) => ConversationsPage(),
        },
      ),
    );
  }
}
