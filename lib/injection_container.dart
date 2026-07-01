import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import 'package:our_chat/core/network/network_info.dart';
import 'package:our_chat/data/datasources/auth_remote_data_source.dart';
import 'package:our_chat/data/datasources/chat_remote_data_source.dart';
import 'package:our_chat/data/datasources/storage_remote_data_source.dart';
import 'package:our_chat/data/encryption/e2ee_service.dart';
import 'package:our_chat/data/repositories/auth_repository_impl.dart';
import 'package:our_chat/data/repositories/call_repository_impl.dart';
import 'package:our_chat/data/repositories/chat_repository_impl.dart';
import 'package:our_chat/data/repositories/storage_repository_impl.dart';
import 'package:our_chat/domain/repositories/auth_repository.dart';
import 'package:our_chat/domain/repositories/call_repository.dart';
import 'package:our_chat/domain/repositories/chat_repository.dart';
import 'package:our_chat/domain/repositories/storage_repository.dart';
import 'package:our_chat/domain/usecases/auth/login_usecase.dart';
import 'package:our_chat/domain/usecases/auth/logout_usecase.dart';
import 'package:our_chat/domain/usecases/auth/register_usecase.dart';
import 'package:our_chat/domain/usecases/chat/get_messages_usecase.dart';
import 'package:our_chat/domain/usecases/chat/send_media_usecase.dart';
import 'package:our_chat/domain/usecases/chat/send_message_usecase.dart';
import 'package:our_chat/domain/usecases/encryption/encrypt_message_usecase.dart';
import 'package:our_chat/presentation/cubit/auth/auth_cubit.dart';
import 'package:our_chat/presentation/cubit/call/call_cubit.dart';
import 'package:our_chat/presentation/cubit/chat/chat_cubit.dart';

/// Global service locator instance.
final sl = GetIt.instance;

/// Initializes all dependencies using GetIt.
Future<void> initDependencies() async {
  // ========================================
  // External
  // ========================================

  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // ========================================
  // Core
  // ========================================

  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: sl()),
  );

  // ========================================
  // Encryption
  // ========================================

  sl.registerLazySingleton<E2EEService>(
    () => E2EEService(secureStorage: sl()),
  );

  // ========================================
  // Data Sources
  // ========================================

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );

  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSource(firestore: sl()),
  );

  sl.registerLazySingleton<StorageRemoteDataSource>(
    () => StorageRemoteDataSource(storage: sl()),
  );

  // ========================================
  // Repository Implementations
  // ========================================

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<CallRepository>(
    () => CallRepositoryImpl(),
  );

  sl.registerLazySingleton<StorageRepository>(
    () => StorageRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // ========================================
  // Use Cases
  // ========================================

  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(repository: sl()),
  );

  sl.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(repository: sl()),
  );

  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(repository: sl()),
  );

  sl.registerLazySingleton<SendMessageUseCase>(
    () => SendMessageUseCase(repository: sl()),
  );

  sl.registerLazySingleton<SendMediaUseCase>(
    () => SendMediaUseCase(
      chatRepository: sl(),
      storageRepository: sl(),
    ),
  );

  sl.registerLazySingleton<GetMessagesUseCase>(
    () => GetMessagesUseCase(repository: sl()),
  );

  sl.registerLazySingleton<EncryptMessageUseCase>(
    () => const EncryptMessageUseCase(),
  );

  // ========================================
  // Cubits
  // ========================================

  sl.registerFactory<AuthCubit>(
    () => AuthCubit(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  sl.registerFactory<ChatCubit>(
    () => ChatCubit(
      getMessagesUseCase: sl(),
      sendMessageUseCase: sl(),
      sendMediaUseCase: sl(),
      encryptMessageUseCase: sl(),
      storageRepository: sl(),
      chatRepository: sl(),
    ),
  );

  sl.registerFactory<CallCubit>(
    () => CallCubit(),
  );
}