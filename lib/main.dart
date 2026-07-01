import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:our_chat/core/theme/app_theme.dart';
import 'package:our_chat/firebase_options.dart';
import 'package:our_chat/injection_container.dart' as di;
import 'package:our_chat/presentation/cubit/auth/auth_cubit.dart';
import 'package:our_chat/presentation/cubit/call/call_cubit.dart';
import 'package:our_chat/presentation/cubit/chat/chat_cubit.dart';
import 'package:our_chat/presentation/pages/auth/login_page.dart';
import 'package:our_chat/presentation/pages/auth/register_page.dart';
import 'package:our_chat/presentation/pages/call/video_call_page.dart';
import 'package:our_chat/presentation/pages/call/voice_call_page.dart';
import 'package:our_chat/presentation/pages/chat/chat_room_page.dart';
import 'package:our_chat/presentation/pages/home/home_page.dart';
import 'package:our_chat/presentation/pages/settings/settings_page.dart';
import 'package:our_chat/presentation/pages/users_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await di.initDependencies();
  runApp(const OurChatApp());
}

class OurChatApp extends StatelessWidget {
  const OurChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => di.sl<AuthCubit>()),
        BlocProvider<ChatCubit>(create: (_) => di.sl<ChatCubit>()),
        BlocProvider<CallCubit>(create: (_) => di.sl<CallCubit>()),
      ],
      child: MaterialApp(
        title: 'Our Chat',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomePage(),
          '/chat/room': (context) => const ChatRoomPage(),
          '/chat/room1': (context) => const ChatRoomPage(),
          '/users/list': (context) => const UsersListPage(),
          '/call/voice': (context) => const VoiceCallPage(),
          '/call/video': (context) => const VideoCallPage(),
          '/settings': (context) => const SettingsPage(),
        },
      ),
    );
  }
}