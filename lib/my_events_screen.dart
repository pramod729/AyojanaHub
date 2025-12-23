import 'package:ayojana_hub/auth_provider.dart';
import 'package:ayojana_hub/event_detail_screen.dart';
import 'package:ayojana_hub/event_model.dart';
import 'package:ayojana_hub/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      await eventProvider.loadMyEvents(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, _) {
          if (eventProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (eventProvider.events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No events yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/create-event').then((_) => _loadEvents());
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Event'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadEvents,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: eventProvider.events.length,
              itemBuilder: (context, index) {
                final event = eventProvider.events[index];
                return _EventCard(event: event, onRefresh: _loadEvents);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-event').then((_) => _loadEvents());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onRefresh;

  const _EventCard({required this.event, required this.onRefresh});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'planning':
        return Colors.blue;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailScreen(event: event),
            ),
          ).then((_) => onRefresh());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      event.eventName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(event.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.status.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(event.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    event.eventType,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM dd, yyyy').format(event.eventDate),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.location,
                      style: TextStyle(color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${event.guestCount} guests',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}