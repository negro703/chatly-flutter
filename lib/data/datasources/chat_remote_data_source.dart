import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:our_chat/core/error/exceptions.dart';
import 'package:our_chat/data/models/message_model.dart';

/// Remote data source for chat/messaging via Cloud Firestore.
class ChatRemoteDataSource {
  ChatRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference get _messagesRef => _firestore.collection('messages');

  /// Sends a message to Firestore.
  Future<MessageModel> sendMessage(Map<String, dynamic> messageData) async {
    try {
      final docRef = await _messagesRef.add(messageData);
      final doc = await docRef.get();
      final data = doc.data() as Map<String, dynamic>?;
      return MessageModel.fromJson(data ?? messageData, doc.id);
    } catch (e) {
      throw ServerException.internal();
    }
  }

  /// Retrieves messages for a chat with pagination.
  Future<List<MessageModel>> getMessages({
    required String chatId,
    String? lastMessageId,
    int limit = 30,
  }) async {
    try {
      var query = _messagesRef
          .where('chatId', isEqualTo: chatId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('timestamp', descending: false)
          .limit(limit);

      if (lastMessageId != null) {
        final lastDoc = await _messagesRef.doc(lastMessageId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        return MessageModel.fromJson(data ?? {}, doc.id);
      }).toList();
    } catch (e) {
      throw ServerException.internal();
    }
  }

  /// Streams real-time message updates for a chat.
  /// Returns ALL messages in the chat, sorted ascending by timestamp.
  ///
  /// Required Firestore composite index:
  ///   Collection: messages
  ///   Fields: chatId (Ascending), isDeleted (Ascending), timestamp (Ascending)
  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    try {
      return _messagesRef
          .where('chatId', isEqualTo: chatId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              return MessageModel.fromJson(data as Map<String, dynamic>? ?? {}, doc.id);
            }).toList();
          });
    } on FirebaseException catch (e) {
      print('Firebase Stream Error: ${e.message}');
      print('Code: ${e.code}');
      if (e.message != null && e.message!.contains('index')) {
        print('CREATE COMPOSITE INDEX IN FIREBASE CONSOLE:');
        print('  Collection: messages');
        print('  Fields: chatId (Ascending), isDeleted (Ascending), timestamp (Ascending)');
      }
      rethrow;
    } catch (e) {
      print('Stream Error: $e');
      throw ServerException.internal();
    }
  }

  /// Streams typing indicator updates for a chat.
  Stream<Map<String, dynamic>> getTypingStatusStream(String chatId) {
    try {
      return _firestore
          .collection('typing_indicator')
          .doc(chatId)
          .snapshots()
          .map((snapshot) {
            if (!snapshot.exists) return {};
            return snapshot.data() as Map<String, dynamic>? ?? {};
          });
    } catch (e) {
      print('Typing Status Stream Error: $e');
      throw ServerException.internal();
    }
  }

  /// Updates typing indicator for a user in a chat.
  Future<void> updateTypingStatus({
    required String chatId,
    required String userId,
    required bool isTyping,
  }) async {
    try {
      await _firestore
          .collection('typing_indicator')
          .doc(chatId)
          .set({userId: isTyping}, SetOptions(merge: true));
    } catch (e) {
      print('Update Typing Status Error: $e');
    }
  }

  /// Streams online status for a user.
  Stream<bool> getOnlineStatusStream(String userId) {
    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .snapshots()
          .map((snapshot) {
            if (!snapshot.exists) return false;
            final data = snapshot.data() as Map<String, dynamic>? ?? {};
            return data['isOnline'] as bool? ?? false;
          });
    } catch (e) {
      print('Online Status Stream Error: $e');
      throw ServerException.internal();
    }
  }

  /// Marks a message as read.
  Future<void> markAsRead(String messageId) async {
    try {
      await _messagesRef.doc(messageId).update({'isRead': true});
    } catch (e) {
      throw ServerException.internal();
    }
  }

  /// Marks a message as delivered.
  Future<void> markAsDelivered(String messageId) async {
    try {
      await _messagesRef.doc(messageId).update({'isDelivered': true});
    } catch (e) {
      throw ServerException.internal();
    }
  }

  /// Deletes a message from Firestore (soft delete by marking as deleted).
  Future<void> deleteMessage(String messageId) async {
    try {
      await _messagesRef.doc(messageId).update({
        'isDeleted': true,
      });
    } catch (e) {
      throw ServerException.internal();
    }
  }

  /// Edits a message in Firestore.
  Future<MessageModel> editMessage({
    required String messageId,
    required String newEncryptedText,
  }) async {
    try {
      await _messagesRef.doc(messageId).update({
        'encryptedText': newEncryptedText,
        'isEdited': true,
        'editedAt': DateTime.now(),
      });
      final doc = await _messagesRef.doc(messageId).get();
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return MessageModel.fromJson(data, doc.id);
    } catch (e) {
      throw ServerException.internal();
    }
  }

  /// Clears all messages in a chat room by marking them as deleted.
  Future<void> clearChat(String chatId) async {
    try {
      final snapshot = await _messagesRef
          .where('chatId', isEqualTo: chatId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isDeleted': true});
      }
      await batch.commit();
    } catch (e) {
      throw ServerException.internal();
    }
  }

  /// Updates a chat room's name and/or image in Firestore.
  Future<void> updateChatRoom({
    required String chatId,
    String? roomName,
    String? roomImage,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (roomName != null) updateData['roomName'] = roomName;
      if (roomImage != null) updateData['roomImage'] = roomImage;

      if (updateData.isNotEmpty) {
        await _firestore.collection('chat_rooms').doc(chatId).update(updateData);
      }
    } catch (e) {
      throw ServerException.internal();
    }
  }
}
