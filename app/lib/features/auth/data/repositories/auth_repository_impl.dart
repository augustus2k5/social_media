import 'package:app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:app/features/auth/data/datasources/token_service.dart';
import 'package:app/features/auth/domain/entities/user_entity.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final TokenService tokenService;


  AuthRepositoryImpl({required this.authRemoteDataSource, required this.tokenService});

  @override
  Future<UserEntity> login(String email, String password) async {
    final result = await authRemoteDataSource.login(
      email: email,
      password: password,
    );

    final user = result.$1;
    final token = result.$2;

    // 🔥 BẮT BUỘC: lưu token
    await tokenService.saveToken(token);

    return user;
  }

  @override
  Future<UserEntity> register(
    String username,
    String email,
    String password,
  ) async {
    return await authRemoteDataSource.register(
      username: username,
      email: email,
      password: password,
    );
  }
}
