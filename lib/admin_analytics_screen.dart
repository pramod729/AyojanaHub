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
  String _selectedRoleFilter = 'all'; // all, vendor, customer
  String _selectedActivityTypeFilter = 'all'; // all, authentication, event, booking, etc.
  DateTimeRange? _selectedDateRange;

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

      // Apply all filters
      List<ActivityLog> activities = provider.activityLogs;

      // Apply role filter
      if (_selectedRoleFilter != 'all') {
        activities = activities
            .where((log) => log.userRole == _selectedRoleFilter)
            .toList();
      }

      // Apply activity type filter
      if (_selectedActivityTypeFilter != 'all') {
        activities = activities
            .where((log) => log.activityType == _selectedActivityTypeFilter)
            .toList();
      }

      // Apply date range filter
      if (_selectedDateRange != null) {
        activities = activities
            .where((log) =>
                log.timestamp.isAfter(_selectedDateRange!.start) &&
                log.timestamp.isBefore(_selectedDateRange!.end))
            .toList();
      }

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final lowerQuery = _searchQuery.toLowerCase();
        activities = activities
            .where((log) =>
                log.activityTitle.toLowerCase().contains(lowerQuery) ||
                log.description.toLowerCase().contains(lowerQuery) ||
                log.userName.toLowerCase().contains(lowerQuery))
            .toList();
      }

      return Column(
        children: [
          // Search bar
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
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'Role',
                    value: _selectedRoleFilter == 'all' ? 'All' : _selectedRoleFilter.toUpperCase(),
                    onTap: () => _showRoleFilterDialog(context),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Type',
                    value: _selectedActivityTypeFilter == 'all'
                        ? 'All'
                        : _selectedActivityTypeFilter.toUpperCase(),
                    onTap: () => _showActivityTypeFilterDialog(context),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: 'Date',
                    value: _selectedDateRange == null
                        ? 'All'
                        : 'Custom',
                    onTap: () => _showDateRangePickerDialog(context),
                  ),
                  if (_selectedRoleFilter != 'all' ||
                      _selectedActivityTypeFilter != 'all' ||
                      _selectedDateRange != null ||
                      _searchQuery.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Clear'),
                      onSelected: (value) {
                        setState(() {
                          _selectedRoleFilter = 'all';
                          _selectedActivityTypeFilter = 'all';
                          _selectedDateRange = null;
                          _searchQuery = '';
                        });
                      },
                      backgroundColor: AppColors.error.withOpacity(0.2),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Activity stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildActivityStatCard(
                    'Vendor Activities',
                    provider.getActivityLogsByRole('vendor').length.toString(),
                    Icons.storefront,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActivityStatCard(
                    'Customer Activities',
                    provider.getActivityLogsByRole('customer').length.toString(),
                    Icons.person,
                    AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Activities list
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
                          _searchQuery.isEmpty &&
                                  _selectedRoleFilter == 'all' &&
                                  _selectedActivityTypeFilter == 'all' &&
                                  _selectedDateRange == null
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
                        return _activityCard(activity, context, provider);
                      },
                    ),
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text('$label: $value'),
        backgroundColor: AppColors.primary.withOpacity(0.1),
        labelStyle: const TextStyle(color: AppColors.primary),
      ),
    );
  }

  Widget _buildActivityStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showRoleFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRadioOption('All', 'all'),
            _buildRadioOption('Vendor', 'vendor'),
            _buildRadioOption('Customer', 'customer'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String label, String value) {
    return RadioListTile(
      title: Text(label),
      value: value,
      groupValue: _selectedRoleFilter,
      onChanged: (val) {
        setState(() => _selectedRoleFilter = val ?? 'all');
        Navigator.pop(context);
      },
    );
  }

  void _showActivityTypeFilterDialog(BuildContext context) {
    final activityTypes = [
      'all',
      'authentication',
      'event',
      'booking',
      'payment',
      'vendor',
      'chat',
      'admin'
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Activity Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: activityTypes
              .map((type) => RadioListTile(
                    title: Text(type == 'all' ? 'All' : type.toUpperCase()),
                    value: type,
                    groupValue: _selectedActivityTypeFilter,
                    onChanged: (val) {
                      setState(() => _selectedActivityTypeFilter = val ?? 'all');
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDateRangePickerDialog(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  Widget _activityCard(ActivityLog activity, BuildContext context, AdminProvider provider) {
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
            const SizedBox(height: 12),
            _divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showActivityDetailsDialog(context, activity),
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Details'),
                ),
                const SizedBox(width: 8),
                if (activity.userRole == 'vendor')
                  TextButton.icon(
                    onPressed: () => _showVendorSummary(context, provider, activity.userId),
                    icon: const Icon(Icons.analytics),
                    label: const Text('Summary'),
                  )
                else if (activity.userRole == 'customer')
                  TextButton.icon(
                    onPressed: () => _showCustomerSummary(context, provider, activity.userId),
                    icon: const Icon(Icons.analytics),
                    label: const Text('Summary'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityDetailsDialog(BuildContext context, ActivityLog activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activity Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Title', activity.activityTitle),
              _detailRow('Description', activity.description),
              _detailRow('User', activity.userName),
              _detailRow('Email', activity.userEmail),
              _detailRow('Role', activity.userRole),
              _detailRow('Activity Type', activity.activityType),
              _detailRow('Timestamp', DateFormat('MMM dd, yyyy HH:mm:ss').format(activity.timestamp)),
              if (activity.relatedId != null)
                _detailRow('Related ID', activity.relatedId!),
              if (activity.relatedType != null)
                _detailRow('Related Type', activity.relatedType!),
              if (activity.metadata != null)
                ..._buildMetadataRows(activity.metadata!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMetadataRows(Map<String, dynamic> metadata) {
    return metadata.entries
        .map((e) => _detailRow(e.key, e.value.toString()))
        .toList();
  }

  void _showVendorSummary(BuildContext context, AdminProvider provider, String vendorId) {
    final summary = provider.getVendorActivitySummary(vendorId);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vendor Activity Summary'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Total Activities', summary['totalActivities'].toString()),
              _detailRow('Activity Types', summary['activityTypes'].toString()),
              _detailRow(
                'Last Activity',
                summary['recentActivity'] != null
                    ? DateFormat('MMM dd, yyyy HH:mm').format(summary['recentActivity'])
                    : 'N/A',
              ),
              const SizedBox(height: 16),
              const Text(
                'Recent Activities',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...((summary['activities'] as List<ActivityLog>).take(5).map(
                    (activity) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '• ${activity.activityTitle}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCustomerSummary(BuildContext context, AdminProvider provider, String customerId) {
    final summary = provider.getCustomerActivitySummary(customerId);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Customer Activity Summary'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Total Activities', summary['totalActivities'].toString()),
              _detailRow('Activity Types', summary['activityTypes'].toString()),
              _detailRow(
                'Last Activity',
                summary['recentActivity'] != null
                    ? DateFormat('MMM dd, yyyy HH:mm').format(summary['recentActivity'])
                    : 'N/A',
              ),
              const SizedBox(height: 16),
              const Text(
                'Recent Activities',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...((summary['activities'] as List<ActivityLog>).take(5).map(
                    (activity) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '• ${activity.activityTitle}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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
