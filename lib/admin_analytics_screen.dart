import 'package:ayojana_hub/activity_model.dart';
import 'package:ayojana_hub/admin_provider.dart';
import 'package:ayojana_hub/auth_provider.dart';
import 'package:ayojana_hub/booking_model.dart';
import 'package:ayojana_hub/event_model.dart';
import 'package:ayojana_hub/theme/app_colors.dart';
import 'package:ayojana_hub/usermodels.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      provider.fetchStats();
      provider.fetchActivityLogs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.userModel;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (user.role != 'admin') {
      return Scaffold(
        body: Center(
          child: Text(
            'Access Denied',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(text: 'Dashboard', icon: Icon(Icons.dashboard)),
              Tab(text: 'Users', icon: Icon(Icons.people)),
              Tab(text: 'Vendors', icon: Icon(Icons.storefront)),
              Tab(text: 'Bookings', icon: Icon(Icons.book_online)),
              Tab(text: 'Events', icon: Icon(Icons.event)),
              Tab(text: 'Activities', icon: Icon(Icons.history)),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildUsersTab(),
          _buildVendorsTab(),
          _buildBookingsTab(),
          _buildEventsTab(),
          _buildActivitiesTab(),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return Consumer<AdminProvider>(builder: (context, provider, _) {
      if (provider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (provider.error != null) {
        return Center(child: Text('Error: ${provider.error}'));
      }

      return RefreshIndicator(
        onRefresh: () => provider.fetchStats(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Overview',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _statCard(
                  'Total Users',
                  provider.totalUsers.toString(),
                  Icons.people,
                  AppColors.primary,
                  context,
                ),
                _statCard(
                  'Total Vendors',
                  provider.vendorSignups.toString(),
                  Icons.storefront,
                  AppColors.success,
                  context,
                ),
                _statCard(
                  'Total Bookings',
                  provider.totalBookings.toString(),
                  Icons.book_online,
                  AppColors.info,
                  context,
                ),
                _statCard(
                  'Total Events',
                  provider.totalEvents.toString(),
                  Icons.event,
                  AppColors.warning,
                  context,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Performance Metrics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _largeStatCard(
              'Completed Bookings',
              provider.completedBookings.toString(),
              '${((provider.completedBookings / (provider.totalBookings == 0 ? 1 : provider.totalBookings)) * 100).toStringAsFixed(1)}%',
              Icons.check_circle,
              AppColors.success,
              context,
            ),
            const SizedBox(height: 12),
            _largeStatCard(
              'Total Revenue',
              '₹${provider.totalRevenue.toStringAsFixed(0)}',
              '${provider.totalBookings} transactions',
              Icons.attach_money,
              AppColors.warning,
              context,
            ),
            const SizedBox(height: 12),
            _largeStatCard(
              'Avg Revenue/Booking',
              provider.totalBookings == 0
                  ? '₹0'
                  : '₹${(provider.totalRevenue / provider.totalBookings).toStringAsFixed(0)}',
              'Per completed booking',
              Icons.trending_up,
              AppColors.primary,
              context,
            ),
            const SizedBox(height: 24),
            Text(
              'Quick Stats',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _infoRow('Customers', '${provider.totalUsers - provider.vendorSignups}',
                context),
            _infoRow('Active Vendors', provider.vendorSignups.toString(), context),
            _infoRow(
              'Pending Bookings',
              provider.allBookings
                  .where((b) => b.paymentStatus == 'pending')
                  .length
                  .toString(),
              context,
            ),
            _infoRow('Completed Events', provider.totalEvents.toString(), context),
          ],
        ),
      );
    });
  }

  Widget _buildUsersTab() {
    return Consumer<AdminProvider>(builder: (context, provider, _) {
      if (provider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final customers =
          provider.allUsers.where((u) => u.role == 'customer').toList();

      return RefreshIndicator(
        onRefresh: () => provider.fetchStats(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final customer = customers[index];
            return _userCard(customer, provider, context);
          },
        ),
      );
    });
  }

  Widget _buildVendorsTab() {
    return Consumer<AdminProvider>(builder: (context, provider, _) {
      if (provider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: () => provider.fetchStats(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.allVendors.length,
          itemBuilder: (context, index) {
            final vendor = provider.allVendors[index];
            final bookingCount = provider.getBookingsByVendor(vendor.id);
            final revenue = provider.getVendorRevenue(vendor.id);

            return _vendorCard(
              vendor,
              bookingCount,
              revenue,
              provider,
              context,
            );
          },
        ),
      );
    });
  }

  Widget _buildBookingsTab() {
    return Consumer<AdminProvider>(builder: (context, provider, _) {
      if (provider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: () => provider.fetchStats(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.allBookings.length,
          itemBuilder: (context, index) {
            final booking = provider.allBookings[index];
            return _bookingCard(booking, provider, context);
          },
        ),
      );
    });
  }

  Widget _buildEventsTab() {
    return Consumer<AdminProvider>(builder: (context, provider, _) {
      if (provider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      return RefreshIndicator(
        onRefresh: () => provider.fetchStats(),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.allEvents.length,
          itemBuilder: (context, index) {
            final event = provider.allEvents[index];
            final userBookings =
                provider.getEventsByUser(event.userId);

            return _eventCard(event, userBookings, provider, context);
          },
        ),
      );
    });
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _largeStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _userCard(
    UserModel user,
    AdminProvider provider,
    BuildContext context,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  user.phone,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Joined ${DateFormat('MMM dd, yyyy').format(user.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showDeleteConfirmation(
                        context,
                        'Delete User',
                        'Are you sure you want to delete this user? This action cannot be undone.',
                        () => provider.deleteUser(user.id),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _vendorCard(
    UserModel vendor,
    int bookingCount,
    double revenue,
    AdminProvider provider,
    BuildContext context,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.success.withOpacity(0.2),
                  child: Icon(
                    Icons.storefront,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor.businessName ?? vendor.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        vendor.vendorCategory ?? 'Category',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.email, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vendor.email,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  vendor.phone,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  vendor.vendorLocation ?? 'Location',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _divider(),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2,
              children: [
                _smallStat('Bookings', bookingCount.toString()),
                _smallStat('Revenue', '₹${revenue.toStringAsFixed(0)}'),
              ],
            ),
            const SizedBox(height: 12),
            _divider(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _showDeleteConfirmation(
                    context,
                    'Delete Vendor',
                    'Are you sure you want to delete this vendor? This action cannot be undone.',
                    () => provider.deleteUser(vendor.id),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                child: const Text('Delete Vendor'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookingCard(
    BookingModel booking,
    AdminProvider provider,
    BuildContext context,
  ) {
    final statusColor = _getStatusColor(booking.paymentStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.eventName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${booking.customerName} → ${booking.vendorName}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking.paymentStatus.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd, yyyy').format(booking.eventDate),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                      '₹${booking.price.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  '${booking.guestCount} guests',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () {
                        _showStatusDialog(context, booking, provider);
                      },
                      child: const Text('Change Status'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () {
                        _showDeleteConfirmation(
                          context,
                          'Delete Booking',
                          'Are you sure you want to delete this booking?',
                          () => provider.deleteBooking(booking.id),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _eventCard(
    EventModel event,
    int bookingCount,
    AdminProvider provider,
    BuildContext context,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.eventName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'by ${event.userName}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(event.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    event.status.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _getStatusColor(event.status),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.event, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  event.eventType,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM dd, yyyy').format(event.eventDate),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.location,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  '${event.guestCount} guests',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (event.budget != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.attach_money, size: 16, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(
                    '₹${event.budget!.toStringAsFixed(0)} budget',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            _divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () {
                        _showDeleteConfirmation(
                          context,
                          'Delete Event',
                          'Are you sure you want to delete this event?',
                          () => provider.deleteEvent(event.id),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: const Text('Delete Event'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: AppColors.mediumGray.withOpacity(0.5),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'confirmed':
      case 'planning':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'cancelled':
      case 'rejected':
        return AppColors.error;
      case 'booking':
      case 'active':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deleted successfully')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showStatusDialog(
    BuildContext context,
    BookingModel booking,
    AdminProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Pending'),
              onTap: () {
                Navigator.pop(context);
                provider.updateBookingStatus(booking.id, 'pending');
              },
            ),
            ListTile(
              title: const Text('Confirmed'),
              onTap: () {
                Navigator.pop(context);
                provider.updateBookingStatus(booking.id, 'confirmed');
              },
            ),
            ListTile(
              title: const Text('Completed'),
              onTap: () {
                Navigator.pop(context);
                provider.updateBookingStatus(booking.id, 'completed');
              },
            ),
            ListTile(
              title: const Text('Cancelled'),
              onTap: () {
                Navigator.pop(context);
                provider.updateBookingStatus(booking.id, 'cancelled');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesTab() {
    return Consumer<AdminProvider>(builder: (context, provider, _) {
      if (provider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final activities = _searchQuery.isEmpty
          ? provider.activityLogs
          : provider.searchActivityLogs(_searchQuery);

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search activities...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.mediumGray),
                ),
              ),
            ),
          ),
          Expanded(
            child: activities.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 48,
                          color: AppColors.mediumGray,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No activities yet'
                              : 'No activities found',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => provider.fetchActivityLogs(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];
                        return _activityCard(activity, context);
                      },
                    ),
                  ),
          ),
        ],
      );
    });
  }

  Widget _activityCard(ActivityLog activity, BuildContext context) {
    final Color activityColor = _getActivityTypeColor(activity.activityType);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: activityColor.withOpacity(0.2),
                  child: Icon(
                    _getActivityTypeIcon(activity.activityType),
                    color: activityColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.activityTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        activity.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  activity.userName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.email, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          activity.userEmail,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM dd, yyyy HH:mm').format(activity.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: activityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    activity.userRole.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: activityColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            if (activity.metadata != null && activity.metadata!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _divider(),
              const SizedBox(height: 12),
              Text(
                'Details',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              ...activity.metadata!.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.key,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Expanded(
                            child: Text(
                              e.value.toString(),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getActivityTypeColor(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'authentication':
        return AppColors.info;
      case 'event':
        return AppColors.primary;
      case 'booking':
        return AppColors.success;
      case 'payment':
        return AppColors.warning;
      case 'vendor':
        return const Color(0xFF9C27B0);
      case 'chat':
        return const Color(0xFF00BCD4);
      case 'admin':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getActivityTypeIcon(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'authentication':
        return Icons.login;
      case 'event':
        return Icons.event;
      case 'booking':
        return Icons.book_online;
      case 'payment':
        return Icons.attach_money;
      case 'vendor':
        return Icons.storefront;
      case 'chat':
        return Icons.chat;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.timeline;
    }
  }
}
