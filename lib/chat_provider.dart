import 'package:ayojana_hub/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ConversationModel> _conversations = [];
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedConversationId;

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedConversationId => _selectedConversationId;

  // Load all conversations for current user
  Future<void> loadConversations(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('conversations')
          .where('customerId', isEqualTo: userId)
          .get();

      final convList = snapshot.docs
          .map((doc) => ConversationModel.fromMap(doc.data(), doc.id))
          .toList();

      final snapshot2 = await _firestore
          .collection('conversations')
          .where('vendorId', isEqualTo: userId)
          .get();

      final convList2 = snapshot2.docs
          .map((doc) => ConversationModel.fromMap(doc.data(), doc.id))
          .toList();

      convList.addAll(convList2);
      convList.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

      _conversations = convList;
    } catch (e) {
      _error = 'Failed to load conversations. Please try again.';
      debugPrint('ChatProvider.loadConversations error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load messages for a specific conversation
  Future<void> loadMessages(String conversationId) async {
    _selectedConversationId = conversationId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('sentAt', descending: false)
          .get();

      _messages = snapshot.docs
          .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
          .toList();

      // Mark messages as read
      await markMessagesAsRead(conversationId);
    } catch (e) {
      _error = 'Failed to load messages: $e';
      debugPrint(_error);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Stream messages for real-time updates
  Stream<List<MessageModel>> getMessagesStream(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Send a message
  Future<bool> sendMessage({
    required String conversationId,
    required String receiverId,
    required String receiverName,
    required String message,
    required String senderRole,
    required String bookingId,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _error = 'User not authenticated';
        return false;
      }

      final messageData = MessageModel(
        id: '',
        conversationId: conversationId,
        senderId: currentUser.uid,
        senderName: currentUser.displayName ?? 'Unknown',
        senderRole: senderRole,
        receiverId: receiverId,
        receiverName: receiverName,
        message: message,
        sentAt: DateTime.now(),
        isRead: false,
        messageType: 'text',
        bookingId: bookingId,
      );

      // Add message to subcollection
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add(messageData.toMap());

      // Update conversation last message
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'lastMessage': message,
        'lastMessageTime': Timestamp.now(),
      });

      // Reset unread count for receiver
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
        'unreadCount': 0,
      });

      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to send message: $e';
      debugPrint(_error);
      return false;
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final messagesSnapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .where('receiverId', isEqualTo: currentUser.uid)
          .get();

      for (var doc in messagesSnapshot.docs) {
        await doc.reference.update({'isRead': true});
      }

      // Reset unread count
      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({'unreadCount': 0});

      notifyListeners();
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  // Create or get conversation
  Future<String?> createOrGetConversation({
    required String customerId,
    required String customerName,
    required String vendorId,
    required String vendorName,
    required String bookingId,
  }) async {
    try {
      // Check if conversation already exists
      final existingConv = await _firestore
          .collection('conversations')
          .where('customerId', isEqualTo: customerId)
          .where('vendorId', isEqualTo: vendorId)
          .where('bookingId', isEqualTo: bookingId)
          .get();

      if (existingConv.docs.isNotEmpty) {
        return existingConv.docs.first.id;
      }

      // Create new conversation
      final convData = ConversationModel(
        id: '',
        customerId: customerId,
        customerName: customerName,
        vendorId: vendorId,
        vendorName: vendorName,
        bookingId: bookingId,
        lastMessageTime: DateTime.now(),
        lastMessage: '',
        unreadCount: 0,
        createdAt: DateTime.now(),
      );

      final docRef =
          await _firestore.collection('conversations').add(convData.toMap());
      return docRef.id;
    } catch (e) {
      _error = 'Failed to create conversation: $e';
      debugPrint(_error);
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearMessages() {
    _messages = [];
    _selectedConversationId = null;
    notifyListeners();
  }
}
