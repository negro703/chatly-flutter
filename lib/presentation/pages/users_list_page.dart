import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:our_chat/core/constants/app_colors.dart';
import 'package:our_chat/core/constants/app_strings.dart';
import 'package:our_chat/domain/entities/user.dart';
import 'package:our_chat/presentation/cubit/auth/auth_cubit.dart';
import 'package:our_chat/presentation/cubit/auth/auth_state.dart';

/// Screen that displays a list of all registered users for starting new chats.
class UsersListPage extends StatefulWidget {
  const UsersListPage({super.key});

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select User'),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            final currentUserId = authState.user.id;
            return StreamBuilder<List<User>>(
              stream: _getUsersStream(currentUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                final users = snapshot.data ?? [];
                if (users.isEmpty) {
                  return const Center(
                    child: Text('No other users found'),
                  );
                }
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _buildUserTile(user);
                  },
                );
              },
            );
          }
          return const Center(child: Text('Please log in to view users'));
        },
      ),
    );
  }

  Widget _buildUserTile(User user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.accent,
        child: Text(
          user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
          style: const TextStyle(color: AppColors.textOnPrimary),
        ),
      ),
      title: Text(
        user.displayName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(user.email ?? ''),
      trailing: const Icon(Icons.chat_bubble_outline),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/chat/room',
          arguments: {
            'receiverId': user.id,
            'receiverName': user.displayName,
          },
        );
      },
    );
  }

  Stream<List<User>> _getUsersStream(String currentUserId) {
    return FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereNotIn: [currentUserId])
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return User(
          id: doc.id,
          displayName: data['displayName'] as String? ?? 'Unknown',
          email: data['email'] as String?,
          photoUrl: data['photoUrl'] as String?,
          status: data['status'] as String?,
          isOnline: data['isOnline'] as bool? ?? false,
          lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
          createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        );
      }).toList();
    });
  }
}