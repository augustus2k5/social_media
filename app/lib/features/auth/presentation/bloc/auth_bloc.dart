import 'package:app/features/auth/domain/usecases/login_use_case.dart';
import 'package:app/features/auth/domain/usecases/register_use_case.dart';
import 'package:app/features/auth/presentation/bloc/auth_event.dart';
import 'package:app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUseCase registerUseCase;
  final LoginUseCase loginUseCase;
  final _storage = FlutterSecureStorage();

  AuthBloc({required this.registerUseCase, required this.loginUseCase})
    : super(AuthInitial()) {
    on<RegisterEvent>(_onRegister);
    on<LoginEvent>(_onLogin);
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    print("STEP 1: start register");
    if (event.username.trim().isEmpty) {
      emit(AuthFailure(error: "Username is required"));
      return;
    }

    if (event.username.length < 3) {
      emit(AuthFailure(error: "Username must be at least 3 characters"));
      return;
    }

    if (event.email.trim().isEmpty) {
      emit(AuthFailure(error: "Email is required"));
      return;
    }

    if (!event.email.contains("@")) {
      emit(AuthFailure(error: "Invalid email"));
      return;
    }

    if (event.password.trim().isEmpty) {
      emit(AuthFailure(error: "Password is required"));
      return;
    }

    if (event.password.length < 6) {
      emit(AuthFailure(error: "Password must be at least 6 characters long"));
      return;
    }

    if (event.confirmPassword.trim().isEmpty) {
      emit(AuthFailure(error: "Please confirm your password"));
      return;
    }

    if (event.password != event.confirmPassword) {
      emit(AuthFailure(error: "Passwords do not match"));
      return;
    }
    emit(AuthLoading());
    try {
      print("STEP 2: calling usecase");
      final user = await registerUseCase.call(
        event.username,
        event.email,
        event.password,
      );

      print("STEP 3: success");

      emit(AuthSuccess(message: "Register successfully"));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    if (event.email.trim().isEmpty) {
      emit(AuthFailure(error: "Email is required"));
      return;
    }

    if (!event.email.contains("@")) {
      emit(AuthFailure(error: "Invalid email"));
      return;
    }

    if (event.password.trim().isEmpty) {
      emit(AuthFailure(error: "Password is required"));
      return;
    }
    emit(AuthLoading());
    try {
      final user = await loginUseCase.call(event.email, event.password);
      final token = await _storage.read(key: "token");
      print("TOKEN SAU LOGIN: $token");
      emit(AuthSuccess(message: "Login successfully"));
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }
}
