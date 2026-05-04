import 'package:app/chat_page.dart';
import 'package:app/core/theme.dart';
import 'package:app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:app/features/auth/data/datasources/token_service.dart';
import 'package:app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:app/features/auth/domain/usecases/login_use_case.dart';
import 'package:app/features/auth/domain/usecases/register_use_case.dart';
import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/auth/presentation/pages/login_page.dart';
import 'package:app/message_page.dart';
import 'package:app/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  
  final authRepository = AuthRepositoryImpl(authRemoteDataSource: AuthRemoteDataSource(), tokenService: TokenService());

  runApp(MyApp(authRepository: authRepository,));
}

class MyApp extends StatefulWidget {
  final AuthRepositoryImpl authRepository;

  const MyApp({super.key, required this.authRepository});

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
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
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
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,

        // 🔥 QUAN TRỌNG NHẤT
        home: token != null ? ChatPage() : LoginPage(),

        routes: {
          "/login": (_) => LoginPage(),
          "/register": (_) => RegisterPage(),
          "/chat": (_) => ChatPage(),
        },
      ),
    );
  }
}