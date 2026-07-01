import 'package:dartz/dartz.dart';

import 'package:our_chat/core/error/exceptions.dart';
import 'package:our_chat/core/error/failures.dart';
import 'package:our_chat/core/network/network_info.dart';
import 'package:our_chat/data/datasources/auth_remote_data_source.dart';
import 'package:our_chat/domain/entities/user.dart';
import 'package:our_chat/domain/repositories/auth_repository.dart';

/// Implementation of [AuthRepository] using Firebase and data sources.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Result<User>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return left(NetworkFailure.noInternet());
    }

    try {
      final userModel = await remoteDataSource.loginWithEmail(
        email: email,
        password: password,
      );
      return right(userModel);
    } on InvalidCredentialsException catch (_) {
      return left(AuthFailure.invalidCredentials());
    } on UserNotFoundException catch (_) {
      return left(AuthFailure.userNotFound());
    } on UnauthorizedException catch (_) {
      return left(AuthFailure.unauthorized());
    } on ServerException catch (_) {
      return left(ServerFailure.internal());
    } catch (_) {
      return left(AuthFailure.serverError());
    }
  }

  @override
  Future<Result<User>> loginWithPhone({
    required String phoneNumber,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return left(NetworkFailure.noInternet());
    }

    try {
      final userModel = await remoteDataSource.loginWithPhone(
        phoneNumber: phoneNumber,
        password: password,
      );
      return right(userModel);
    } on InvalidCredentialsException catch (_) {
      return left(AuthFailure.invalidCredentials());
    } on UserNotFoundException catch (_) {
      return left(AuthFailure.userNotFound());
    } on UnauthorizedException catch (_) {
      return left(AuthFailure.unauthorized());
    } on ServerException catch (_) {
      return left(ServerFailure.internal());
    } catch (_) {
      return left(AuthFailure.serverError());
    }
  }

  @override
  Future<Result<User>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (!await networkInfo.isConnected) {
      return left(NetworkFailure.noInternet());
    }

    try {
      final userModel = await remoteDataSource.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      return right(userModel);
    } on EmailAlreadyInUseException catch (_) {
      return left(AuthFailure.emailAlreadyInUse());
    } on WeakPasswordException catch (_) {
      return left(AuthFailure.weakPassword());
    } on ServerException catch (_) {
      return left(ServerFailure.internal());
    } catch (_) {
      return left(AuthFailure.serverError());
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await remoteDataSource.logout();
      return right(null);
    } on ServerException catch (_) {
      return left(ServerFailure.internal());
    } catch (_) {
      return left(ServerFailure.internal());
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final userId = remoteDataSource.getCurrentUserId();
    if (userId == null) return null;

    try {
      final userModel = await remoteDataSource.getUserById(userId);
      return userModel;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return remoteDataSource.getCurrentUserId() != null;
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    return left(
      const AuthFailure(
        message: 'Not implemented',
        code: 'not-implemented',
      ),
    );
  }
}