import 'package:ayojana_hub/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;
  String? _error;
  List<_NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userModel?.id;
    if (userId == null) {
      setState(() {
        _error = 'Please log in to view notifications.';
        _isLoading = false;
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _notifications = snapshot.docs
          .map((doc) => _NotificationItem.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      _error = 'Failed to load notifications. Please try again.';
      debugPrint('Notifications error: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').doc(id).update({'isRead': true});
      setState(() {
        final index = _notifications.indexWhere((item) => item.id == id);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
        }
      });
    } catch (e) {
      debugPrint('Failed to mark notification as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center)))],
                  )
                : _notifications.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [SizedBox(height: 120), Center(child: Text('No notifications yet.', style: TextStyle(fontSize: 16))), SizedBox(height: 12), Center(child: Text('Pull down to refresh.'))],
                      )
                    : ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final item = _notifications[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              tileColor: item.isRead ? Colors.white : const Color(0xFFf2f4ff),
                              leading: Icon(item.icon, color: const Color(0xFF6C63FF)),
                              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [Text(item.message), const SizedBox(height: 4), Text(item.subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54))],
                              ),
                              trailing: item.isRead ? null : const Icon(Icons.circle, size: 10, color: Color(0xFF6C63FF)),
                              onTap: () async {
                                await _markAsRead(item.id);
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(item.title),
                                    content: Text(item.message),
                                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}

class _NotificationItem {
  final String id;
  final String title;
  final String message;
  final String subtitle;
  final bool isRead;
  final DateTime createdAt;
  final String type;
  final IconData icon;

  _NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.subtitle,
    required this.isRead,
    required this.createdAt,
    required this.type,
    required this.icon,
  });

  factory _NotificationItem.fromMap(Map<String, dynamic> map, String id) {
    final type = map['type'] as String? ?? 'notification';
    final DateTime createdAt = (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    return _NotificationItem(
      id: id,
      title: map['title'] ?? 'Notification',
      message: map['message'] ?? '',
      subtitle: '${createdAt.toLocal()}'.split('.').first,
      isRead: map['isRead'] == true,
      createdAt: createdAt,
      type: type,
      icon: _iconForType(type),
    );
  }

  static IconData _iconForType(String type) {
    switch (type) {
      case 'new_event_opportunity':
        return Icons.event_available;
      case 'new_proposal':
        return Icons.note_add;
      case 'proposal_accepted':
        return Icons.check_circle_outline;
      case 'booking_confirmed':
        return Icons.book_online;
      case 'proposal_rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  _NotificationItem copyWith({bool? isRead}) {
    return _NotificationItem(
      id: id,
      title: title,
      message: message,
      subtitle: subtitle,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      type: type,
      icon: icon,
    );
  }
}
