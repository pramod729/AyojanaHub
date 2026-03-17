import 'package:ayojana_hub/ai_assistant_screen.dart';
import 'package:ayojana_hub/auth_provider.dart';
import 'package:ayojana_hub/my_bookings_screen.dart';
import 'package:ayojana_hub/my_events_screen.dart';
import 'package:ayojana_hub/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ayojana_hub/theme/app_colors.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeTab(),
    MyEventsScreen(),
    MyBookingsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_outlined),
              selectedIcon: Icon(Icons.event),
              label: 'Events',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_outline),
              selectedIcon: Icon(Icons.bookmark),
              label: 'Bookings',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

/// Main Home Tab Widget
/// Contains the complete redesigned home page with all modern UI elements
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userModel?.name ?? 'User';
    final isAdmin = authProvider.userModel?.role == 'admin';

    return Scaffold(
      // ==================== APP BAR ====================
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.jpg',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Text(
              'Ayojana Hub',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                letterSpacing: 0.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => Navigator.pushNamed(context, '/admin-analytics'),
              tooltip: 'Admin Dashboard',
            ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
        ],
      ),

      // ==================== MAIN BODY ====================
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Greeting Card
            GreetingCard(userName: userName),

            _buildSectionSpacing(),

            // Section: Search Bar
            SearchBarWidget(controller: _searchController),

            _buildSectionSpacing(),

            // Section: Upcoming Event Card
            UpcomingEventCard(),

            _buildSectionSpacing(),

            // Section: Quick Stats Row
            const QuickStatsRow(),

            _buildSectionSpacing(),

            // Section: Quick Actions
            QuickActionsSection(),

            _buildSectionSpacing(),

            // Section: Event Categories
            const EventCategoriesSection(),

            _buildSectionSpacing(),

            // Section: Popular Services
            const PopularServicesSection(),

            _buildSectionSpacing(),

            // Section: Popular Packages
            const PopularPackagesSection(),

            const SizedBox(height: 32),
          ],
        ),
      ),

      // ==================== FLOATING AI BUTTON ====================
      floatingActionButton: FloatingAIButton(
        onPressed: () {
          // Navigate to AI Assistant Screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AIAssistantScreen(),
            ),
          );
        },
      ),
    );
  }

  /// Helper method for consistent vertical spacing between sections
  Widget _buildSectionSpacing() {
    return const SizedBox(height: 24);
  }
}

// ============================================================================
// REUSABLE WIDGET COMPONENTS - Clean & Modern
// ============================================================================

/// 1. GREETING CARD WIDGET
/// Displays a warm greeting with user's name and motivational message
class GreetingCard extends StatelessWidget {
  final String userName;

  const GreetingCard({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Text with Accent
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
                children: [
                  const TextSpan(text: 'Hello, '),
                  TextSpan(
                    text: userName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).primaryColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const TextSpan(text: '! 👋'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            Text(
              'What event are you planning today?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 2. SEARCH BAR WIDGET
/// Clean, functional search bar with rounded corners
class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSearchTap;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Search services, vendors, events...',
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

/// 3. UPCOMING EVENT CARD WIDGET
/// Displays the next upcoming event or prompts to create one
class UpcomingEventCard extends StatelessWidget {
  const UpcomingEventCard({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Connect to event provider to get actual upcoming event
    final hasUpcomingEvent = false; // Replace with actual event check

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: hasUpcomingEvent
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.event_available,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Wedding Day',
                              style:
                                  Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'March 15, 2024 • 50 Guests',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Confirmed',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/my-events'),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('View Event'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.checklist, size: 18),
                          label: const Text('Checklist'),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_note,
                    size: 48,
                    color: Theme.of(context).primaryColor.withOpacity(0.6),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No upcoming events',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first event and start planning!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/create-event'),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create Event'),
                  ),
                ],
              ),
      ),
    );
  }
}

/// 4. QUICK STATS ROW WIDGET
/// Three cards showing key statistics (Events, Bookings, Budget)
class QuickStatsRow extends StatelessWidget {
  const QuickStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Total Events Stat
          Expanded(
            child: _StatCard(
              icon: Icons.event,
              value: '5',
              label: 'Events',
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          // Active Bookings Stat
          Expanded(
            child: _StatCard(
              icon: Icons.bookmark,
              value: '12',
              label: 'Bookings',
              color: Colors.purple,
            ),
          ),
          const SizedBox(width: 12),
          // Total Budget Stat
          Expanded(
            child: _StatCard(
              icon: Icons.wallet,
              value: '₹5L',
              label: 'Budget',
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper Widget: Individual Stat Card (used in QuickStatsRow)
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}

/// 5. QUICK ACTIONS SECTION WIDGET
/// Two prominent action cards for creating events and finding vendors
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Create Event Action
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.add_circle_outline,
                  label: 'Create Event',
                  color: Colors.blue,
                  onTap: () => Navigator.pushNamed(context, '/create-event'),
                ),
              ),
              const SizedBox(width: 16),
              // Find Vendors Action
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.people_outline,
                  label: 'Find Vendors',
                  color: Colors.purple,
                  onTap: () => Navigator.pushNamed(context, '/vendors'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Helper Widget: Individual Quick Action Card
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 6. EVENT CATEGORIES SECTION WIDGET
/// Horizontal scrollable list of event type categories
class EventCategoriesSection extends StatelessWidget {
  const EventCategoriesSection({super.key});

  // Sample category data
  static const List<Map<String, dynamic>> categories = [
    {
      'icon': Icons.favorite,
      'label': 'Wedding',
      'color': Color(0xFFEC407A),
    },
    {
      'icon': Icons.cake,
      'label': 'Birthday',
      'color': Color(0xFF9C27B0),
    },
    {
      'icon': Icons.business,
      'label': 'Corporate',
      'color': Color(0xFF1E88E5),
    },
    {
      'icon': Icons.school,
      'label': 'Seminar',
      'color': Color(0xFF00897B),
    },
    {
      'icon': Icons.celebration,
      'label': 'Party',
      'color': Color(0xFFFFA726),
    },
    {
      'icon': Icons.sports_bar,
      'label': 'Reunion',
      'color': Color(0xFFEF5350),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Event Categories',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _CategoryCard(
                  icon: category['icon'] as IconData,
                  label: category['label'] as String,
                  color: category['color'] as Color,
                  onTap: () => Navigator.pushNamed(context, '/vendors'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Helper Widget: Individual Category Card
class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 7. POPULAR SERVICES SECTION WIDGET
/// List of commonly used services with icons and descriptions
class PopularServicesSection extends StatelessWidget {
  const PopularServicesSection({super.key});

  // Sample services data
  static const List<Map<String, dynamic>> services = [
    {
      'icon': Icons.restaurant,
      'title': 'Catering',
      'description': 'Professional catering services',
    },
    {
      'icon': Icons.camera_alt,
      'title': 'Photography',
      'description': 'Capture your special moments',
    },
    {
      'icon': Icons.music_note,
      'title': 'DJ & Music',
      'description': 'Set the perfect mood',
    },
    {
      'icon': Icons.local_florist,
      'title': 'Decoration',
      'description': 'Beautiful venue decoration',
    },
    {
      'icon': Icons.directions_car,
      'title': 'Transportation',
      'description': 'Reliable transport solutions',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Services',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/vendors'),
                child: Text(
                  'View All',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: services.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final service = services[index];
            return _ServiceCard(
              icon: service['icon'] as IconData,
              title: service['title'] as String,
              description: service['description'] as String,
              onTap: () => Navigator.pushNamed(context, '/vendors'),
            );
          },
        ),
      ],
    );
  }
}

/// Helper Widget: Individual Service Card
class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Service Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 24,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 14),
            // Service Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }
}

/// 8. POPULAR PACKAGES SECTION WIDGET
/// Grid/list of premium packages with pricing
class PopularPackagesSection extends StatelessWidget {
  const PopularPackagesSection({super.key});

  // Sample packages data
  static const List<Map<String, dynamic>> packages = [
    {
      'name': 'Basic Package',
      'description': 'Perfect for intimate gatherings',
      'price': '₹15,000',
      'features': ['100 Guests', 'Catering', 'Basic Decor'],
    },
    {
      'name': 'Premium Package',
      'description': 'Complete event management',
      'price': '₹50,000',
      'features': ['500 Guests', 'Full Catering', 'Photography'],
    },
    {
      'name': 'Luxury Package',
      'description': 'All-inclusive premium experience',
      'price': '₹1,00,000+',
      'features': ['Unlimited Guests', 'All Services', 'Premium Support'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Popular Packages',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: packages.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final package = packages[index];
            return _PackageCard(
              name: package['name'] as String,
              description: package['description'] as String,
              price: package['price'] as String,
              features: List<String>.from(package['features'] as List),
              onViewDetails: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Viewing ${package['name']} details...'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

/// Helper Widget: Individual Package Card
class _PackageCard extends StatelessWidget {
  final String name;
  final String description;
  final String price;
  final List<String> features;
  final VoidCallback onViewDetails;

  const _PackageCard({
    required this.name,
    required this.description,
    required this.price,
    required this.features,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                price,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Features List
          ...features.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(
                top: entry.key == 0 ? 0 : 8,
                bottom: entry.key == features.length - 1 ? 0 : 0,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
          // View Details Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onViewDetails,
              child: const Text('View Details'),
            ),
          ),
        ],
      ),
    );
  }
}

/// 9. FLOATING AI BUTTON WIDGET
/// Bottom-right floating action button for AI Assistant
class FloatingAIButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FloatingAIButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Ask Ayojana AI',
      child: FloatingActionButton(
        onPressed: onPressed,
        tooltip: 'Ask Ayojana AI',
        child: const Icon(Icons.chat_bubble_outline),
      ),
    );
  }
}