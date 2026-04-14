import 'dart:io';

import 'package:ayojana_hub/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _unreadNotificationCount = 0;
  bool _isLoadingNotifications = false;
  String? _notificationError;

  @override
  void initState() {
    super.initState();
    _loadUnreadNotificationCount();
  }

  Future<void> _loadUnreadNotificationCount() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userModel?.id;
    if (userId == null) {
      return;
    }

    setState(() {
      _isLoadingNotifications = true;
      _notificationError = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      if (mounted) {
        setState(() {
          _unreadNotificationCount = snapshot.docs.length;
        });
      }
    } catch (e) {
      debugPrint('Unread notifications load error: $e');
      if (mounted) {
        setState(() {
          _notificationError = 'Unable to load unread notifications';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingNotifications = false;
        });
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final nameController = TextEditingController(text: authProvider.userModel?.name);
    final phoneController = TextEditingController(text: authProvider.userModel?.phone);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person)), validator: (v) => (v == null || v.isEmpty) ? 'Please enter your name' : null),
              const SizedBox(height: 12),
              TextFormField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone)), validator: (v) => (v == null || v.isEmpty) ? 'Please enter your phone' : null),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final error = await authProvider.updateProfile(name: nameController.text.trim(), phone: phoneController.text.trim());
                if (context.mounted) {
                  Navigator.pop(context);
                  if (error == null) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully'))); else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), automaticallyImplyLeading: false, actions: [IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEditProfileDialog(context))]),
      body: Consumer<AuthProvider>(builder: (context, authProvider, _) {
        final user = authProvider.userModel;
        if (user == null) return const Center(child: CircularProgressIndicator());

        return SingleChildScrollView(
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(color: Color(0xFF6C63FF), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30))),
              child: Column(children: [
                Stack(alignment: Alignment.bottomRight, children: [
                  CircleAvatar(radius: 50, backgroundColor: Colors.white, backgroundImage: user.profileImage != null && user.profileImage!.isNotEmpty ? NetworkImage(user.profileImage!) : null, child: (user.profileImage == null || user.profileImage!.isEmpty) ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 40, color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)) : null),
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final source = await showModalBottomSheet<ImageSource?>(context: context, builder: (context) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Take Photo'), onTap: () => Navigator.pop(context, ImageSource.camera)), ListTile(leading: const Icon(Icons.photo_library), title: const Text('Choose From Gallery'), onTap: () => Navigator.pop(context, ImageSource.gallery))])));
                      if (source == null) return;
                      final picked = await picker.pickImage(source: source, imageQuality: 85);
                      if (picked == null) return;
                      final previewFile = File(picked.path);
                      final confirm = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Preview Photo'), content: Image.file(previewFile, width: 200, height: 200, fit: BoxFit.cover), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Upload'))]));
                      if (confirm != true) return;
                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      final scaffold = ScaffoldMessenger.of(context);
                      scaffold.showSnackBar(const SnackBar(content: Text('Uploading photo...')));
                      final error = await auth.updateProfilePhoto(previewFile);
                      if (error == null) scaffold.showSnackBar(const SnackBar(content: Text('Profile photo updated'))); else scaffold.showSnackBar(SnackBar(content: Text(error)));
                    },
                    child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6)]), child: const Icon(Icons.edit, color: Color(0xFF6C63FF), size: 18)),
                  ),
                ]),
                const SizedBox(height: 16),
                Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text(user.email, style: const TextStyle(fontSize: 16, color: Colors.white70)),
              ]),
            ),
            const SizedBox(height: 24),
            _ProfileOption(icon: Icons.person_outline, title: 'Personal Information', subtitle: 'Manage your profile details', onTap: () => _showEditProfileDialog(context)),
            _ProfileOption(icon: Icons.event, title: 'My Events', subtitle: 'View all your events', onTap: () => Navigator.pushNamed(context, '/my-events')),
            _ProfileOption(icon: Icons.bookmark_border, title: 'My Bookings', subtitle: 'View your vendor bookings', onTap: () => Navigator.pushNamed(context, '/my-bookings')),
            _ProfileOption(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'View and manage your notifications',
              badgeCount: _unreadNotificationCount,
              onTap: () async {
                await Navigator.pushNamed(context, '/notifications');
                _loadUnreadNotificationCount();
              },
            ),
            _ProfileOption(icon: Icons.help_outline, title: 'Help & Support', subtitle: 'Get help with your account', onTap: () => Navigator.pushNamed(context, '/help-support')),
            _ProfileOption(icon: Icons.info_outline, title: 'About UAS', subtitle: 'Learn more about Ayojana Hub', onTap: () => Navigator.pushNamed(context, '/about')),
            if (user.role == 'admin') _ProfileOption(icon: Icons.admin_panel_settings, title: 'Admin Dashboard', subtitle: 'Manage users, vendors, bookings & events', onTap: () => Navigator.pushNamed(context, '/admin-analytics')),
            const SizedBox(height: 16),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/vendors'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Find Vendors')))),
            const SizedBox(height: 12),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => _logout(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 16)), child: const Text('Logout')))),
            const SizedBox(height: 32),
          ]),
        );
      }),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int badgeCount;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF6C63FF).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: const Color(0xFF6C63FF))),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badgeCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}