import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Sample user data
  final String userName = "Pramod Aryal";
  final bool hasUpcomingEvent = true;
  
  // Event data
  final Map<String, dynamic> upcomingEvent = {
    'name': 'Wedding Reception',
    'date': 'March 15, 2026',
    'guestCount': 150,
    'status': 'Confirmed',
  };

  // Quick stats data
  final List<Map<String, dynamic>> quickStats = [
    {'label': 'Total Events', 'value': '3', 'icon': Iconsax.calendar},
    {'label': 'Active Bookings', 'value': '5', 'icon': Iconsax.bookmark},
    {'label': 'Total Budget', 'value': '\$5,420', 'icon': Iconsax.wallet_2},
  ];

  // Event categories data
  final List<Map<String, String>> eventCategories = [
    {'name': 'Wedding', 'icon': '💒'},
    {'name': 'Birthday', 'icon': '🎂'},
    {'name': 'Corporate', 'icon': '🏢'},
    {'name': 'Festival', 'icon': '🎉'},
    {'name': 'Conference', 'icon': '🎤'},
  ];

  // Popular services data
  final List<Map<String, dynamic>> popularServices = [
    {
      'icon': Iconsax.camera,
      'title': 'Photography',
      'subtitle': 'Professional photo coverage',
    },
    {
      'icon': Iconsax.music,
      'title': 'DJ & Music',
      'subtitle': 'Live DJ and audio setup',
    },
    {
      'icon': Iconsax.bag,
      'title': 'Catering',
      'subtitle': 'Food and beverage services',
    },
  ];

  // Popular packages data
  final List<Map<String, dynamic>> popularPackages = [
    {
      'name': 'Basic Package',
      'description': 'Perfect for small gatherings',
      'price': '\$1,299',
    },
    {
      'name': 'Premium Package',
      'description': 'Full event management included',
      'price': '\$3,499',
    },
    {
      'name': 'Elite Package',
      'description': 'Luxury experience with all services',
      'price': '\$7,999',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              
              // Greeting Card
              GreetingCard(userName: userName),
              const SizedBox(height: 20),

              // Search Bar
              const SearchBarWidget(),
              const SizedBox(height: 24),

              // Upcoming Event Card
              UpcomingEventCard(
                hasEvent: hasUpcomingEvent,
                event: upcomingEvent,
              ),
              const SizedBox(height: 24),

              // Quick Stats Row
              QuickStatsRow(stats: quickStats),
              const SizedBox(height: 24),

              // Quick Actions Section
              const QuickActionsSection(),
              const SizedBox(height: 24),

              // Event Categories Section
              EventCategoriesSection(categories: eventCategories),
              const SizedBox(height: 24),

              // Popular Services Section
              PopularServicesSection(services: popularServices),
              const SizedBox(height: 24),

              // Popular Packages Section
              PopularPackagesSection(packages: popularPackages),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingAIButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opening Ayojana AI Chatbot...')),
          );
        },
      ),
    );
  }

  // Build AppBar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text(
        'Ayojana Hub',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Iconsax.notification,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            Iconsax.user,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}

/// ============================================================================
/// WIDGET 1: GREETING CARD
/// ============================================================================
/// Displays personalized greeting message with soft design
class GreetingCard extends StatelessWidget {
  final String userName;

  const GreetingCard({
    Key? key,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $userName! 👋',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'What event are you planning today?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer
                      .withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// WIDGET 2: SEARCH BAR
/// ============================================================================
/// Search input field with rounded container and search icon
class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.search_normal,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search services, vendors, events...',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withOpacity(0.6),
                    ),
                border: InputBorder.none,
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// WIDGET 3: UPCOMING EVENT CARD
/// ============================================================================
/// Shows upcoming event details with status badge or empty state message
class UpcomingEventCard extends StatelessWidget {
  final bool hasEvent;
  final Map<String, dynamic> event;

  const UpcomingEventCard({
    Key? key,
    required this.hasEvent,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: hasEvent
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with calendar icon and status badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Iconsax.calendar_1,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event['status'] ?? 'Pending',
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Event name
                Text(
                  event['name'] ?? 'Unnamed Event',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                
                // Event date and guest count
                Row(
                  children: [
                    Icon(
                      Iconsax.calendar_2,
                      size: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      event['date'] ?? 'TBD',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Iconsax.people,
                      size: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${event['guestCount'] ?? 0} guests',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ],
            )
          : Center(
              child: Column(
                children: [
                  Icon(
                    Iconsax.calendar,
                    size: 40,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No upcoming events',
                    style:
                        Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create one now to get started',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// ============================================================================
/// WIDGET 4: QUICK STATS ROW
/// ============================================================================
/// Displays 3 equal-width stat cards in a horizontal row
class QuickStatsRow extends StatelessWidget {
  final List<Map<String, dynamic>> stats;

  const QuickStatsRow({
    Key? key,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        stats.length,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < stats.length - 1 ? 12 : 0,
            ),
            child: StatCard(stat: stats[index]),
          ),
        ),
      ),
    );
  }
}

/// Helper Widget: Single Stat Card with icon, value and label
class StatCard extends StatelessWidget {
  final Map<String, dynamic> stat;

  const StatCard({
    Key? key,
    required this.stat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            stat['icon'],
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            stat['value'] ?? '0',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            stat['label'] ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// WIDGET 5: QUICK ACTIONS SECTION
/// ============================================================================
/// Two large action cards for Create Event and Find Vendors
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ActionCard(
                icon: Iconsax.add_square,
                title: 'Create Event',
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ActionCard(
                icon: Iconsax.search_normal_1,
                title: 'Find Vendors',
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Helper Widget: Single Action Card with icon and title
class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ActionCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================================
/// WIDGET 6: EVENT CATEGORIES SECTION
/// ============================================================================
/// Horizontal scrollable event category cards with emoji icons
class EventCategoriesSection extends StatelessWidget {
  final List<Map<String, String>> categories;

  const EventCategoriesSection({
    Key? key,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Categories',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(
              categories.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  right: index < categories.length - 1 ? 12 : 0,
                ),
                child: CategoryCard(category: categories[index]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Helper Widget: Single Category Card with emoji and name
class CategoryCard extends StatelessWidget {
  final Map<String, String> category;

  const CategoryCard({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            category['icon'] ?? '📌',
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              category['name'] ?? 'Category',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// WIDGET 7: POPULAR SERVICES SECTION
/// ============================================================================
/// List of popular services with left icon, title, subtitle and arrow
class PopularServicesSection extends StatelessWidget {
  final List<Map<String, dynamic>> services;

  const PopularServicesSection({
    Key? key,
    required this.services,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Services',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
        ),
        const SizedBox(height: 12),
        Column(
          children: List.generate(
            services.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                bottom: index < services.length - 1 ? 12 : 0,
              ),
              child: ServiceCard(service: services[index]),
            ),
          ),
        ),
      ],
    );
  }
}

/// Helper Widget: Single Service Card with icon and details
class ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;

  const ServiceCard({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon container on left
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              service['icon'],
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Service title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service['title'] ?? 'Service',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  service['subtitle'] ?? 'Description',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                ),
              ],
            ),
          ),
          
          // Arrow icon on right
          Icon(
            Iconsax.arrow_right_3,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// WIDGET 8: POPULAR PACKAGES SECTION
/// ============================================================================
/// List of popular packages with name, description, price and button
class PopularPackagesSection extends StatelessWidget {
  final List<Map<String, dynamic>> packages;

  const PopularPackagesSection({
    Key? key,
    required this.packages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Packages',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
        ),
        const SizedBox(height: 12),
        Column(
          children: List.generate(
            packages.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                bottom: index < packages.length - 1 ? 12 : 0,
              ),
              child: PackageCard(package: packages[index]),
            ),
          ),
        ),
      ],
    );
  }
}

/// Helper Widget: Single Package Card with details and button
class PackageCard extends StatelessWidget {
  final Map<String, dynamic> package;

  const PackageCard({
    Key? key,
    required this.package,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Package name and price row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package['name'] ?? 'Package',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      package['description'] ?? 'Description',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                package['price'] ?? '\$0',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // View Details button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: Text(
                'View Details',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// WIDGET 9: FLOATING AI BUTTON
/// ============================================================================
/// Bottom-right floating action button for AI chatbot with tooltip
class FloatingAIButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FloatingAIButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Ask Ayojana AI',
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Iconsax.messages),
      ),
    );
  }
}
