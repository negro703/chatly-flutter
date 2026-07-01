import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:our_chat/core/constants/app_strings.dart';
import 'package:our_chat/core/error/failures.dart';
import 'package:our_chat/domain/usecases/auth/login_usecase.dart';
import 'package:our_chat/domain/usecases/auth/logout_usecase.dart';
import 'package:our_chat/domain/usecases/auth/register_usecase.dart';
import 'package:our_chat/presentation/cubit/auth/auth_state.dart';

/// Cubit for managing authentication state.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
  }) : super(const AuthInitial());

  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;

  /// Attempts to login with email and password.
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());

    final result = await loginUseCase(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => emit(
        AuthError(
          message: _mapAuthError(failure),
          code: failure.code,
        ),
      ),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  /// Attempts to register a new user.
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    emit(const AuthLoading());

    final result = await registerUseCase(
      email: email,
      password: password,
      displayName: displayName,
    );

    result.fold(
      (failure) => emit(
        AuthError(
          message: _mapAuthError(failure),
          code: failure.code,
        ),
      ),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  /// Logs out the current user.
  Future<void> logout() async {
    emit(const AuthLoading());

    final result = await logoutUseCase();

    result.fold(
      (failure) => emit(
        AuthError(
          message: failure.message,
          code: failure.code,
        ),
      ),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  /// Checks if a user is authenticated.
  void checkAuthStatus({required bool isAuthenticated}) {
    if (isAuthenticated) {
      // Will emit authenticated when user data is fetched
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  /// Maps failures to user-friendly messages.
  String _mapAuthError(Failure failure) {
    if (failure.code == 'invalid-credentials' ||
        failure.code == 'wrong-password') {
      return AppStrings.authErrorArabic;
    }
    return failure.message;
  }
}