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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event), label: 'Events'),
          NavigationDestination(icon: Icon(Icons.bookmark_outline), selectedIcon: Icon(Icons.bookmark), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userModel?.name ?? 'User';
    final isAdmin = authProvider.userModel?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.jpg', width: 40, height: 40, fit: BoxFit.contain),
            const SizedBox(width: 12),
            Text(
              'Ayojana Hub',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.gold,
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
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F172A), // Deep Navy
                      Color(0xFF1E3A8A), // Royal Blue
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textLight,
                        ),
                        children: [
                          const TextSpan(text: 'Hello, '),
                          TextSpan(
                            text: userName,
                            style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFF5C542), // Soft Gold
                            ),
                          ),
                          const TextSpan(text: '!'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'What event are you planning today?',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFC7D2FE),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Quick Actions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.add_circle_outline,
                          label: 'Create Event',
                          onTap: () => Navigator.pushNamed(context, '/create-event'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.people_outline,
                          label: 'Find Vendors',
                          onTap: () => Navigator.pushNamed(context, '/vendors'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Event Categories Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Event Categories', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _CategoryCard(icon: Icons.favorite, label: 'Wedding', color: const Color(0xFFEC407A), onTap: () => Navigator.pushNamed(context, '/vendors')),
                        _CategoryCard(icon: Icons.cake, label: 'Birthday', color: const Color(0xFF9C27B0), onTap: () => Navigator.pushNamed(context, '/vendors')),
                        _CategoryCard(icon: Icons.business, label: 'Corporate', color: const Color(0xFF1E88E5), onTap: () => Navigator.pushNamed(context, '/vendors')),
                        _CategoryCard(icon: Icons.school, label: 'Seminar', color: const Color(0xFF00897B), onTap: () => Navigator.pushNamed(context, '/vendors')),
                        _CategoryCard(icon: Icons.celebration, label: 'Party', color: const Color(0xFFFFA726), onTap: () => Navigator.pushNamed(context, '/vendors')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Popular Services Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Popular Services', style: Theme.of(context).textTheme.titleLarge),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/vendors'),
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _ServiceCard(icon: Icons.restaurant, title: 'Catering', description: 'Professional catering services'),
                  const SizedBox(height: 8),
                  const _ServiceCard(icon: Icons.camera_alt, title: 'Photography', description: 'Capture your special moments'),
                  const SizedBox(height: 8),
                  const _ServiceCard(icon: Icons.music_note, title: 'DJ & Music', description: 'Set the perfect mood'),
                  const SizedBox(height: 8),
                  const _ServiceCard(icon: Icons.local_florist, title: 'Decoration', description: 'Beautiful venue decoration'),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: const Color(0xFF1E88E5)),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ServiceCard({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E88E5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1E88E5), size: 24),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.pushNamed(context, '/vendors'),
      ),
    );
  }
}