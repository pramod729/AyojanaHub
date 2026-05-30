import 'package:ayojana_hub/auth_provider.dart';
import 'package:ayojana_hub/event_model.dart';
import 'package:ayojana_hub/proposal_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class VendorOpportunitiesScreen extends StatefulWidget {
  const VendorOpportunitiesScreen({super.key});

  @override
  State<VendorOpportunitiesScreen> createState() => _VendorOpportunitiesScreenState();
}

class _VendorOpportunitiesScreenState extends State<VendorOpportunitiesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<EventModel> _matchingEvents = [];
  bool _isLoading = true;
  Set<String> _rejectedEventIds = {};

  @override
  void initState() {
    super.initState();
    _loadMatchingEvents();
  }

  Future<void> _loadMatchingEvents() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userModel = authProvider.userModel;

    if (userModel?.vendorCategory == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final userId = authProvider.user?.uid;
      if (userId != null) {
        final rejectedSnapshot = await _firestore
            .collection('event_responses')
            .where('vendorId', isEqualTo: userId)
            .where('status', isEqualTo: 'rejected')
            .get();

        _rejectedEventIds = rejectedSnapshot.docs
            .map((doc) => doc.data()['eventId'] as String? ?? '')
            .where((id) => id.isNotEmpty)
            .toSet();
      }

      final snapshot = await _firestore
          .collection('events')
          .where('status', isEqualTo: 'awaiting_proposals')
          .orderBy('createdAt', descending: true)
          .get();

      final vendorCategory = userModel?.vendorCategory;
      _matchingEvents = snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data(), doc.id))
          .where((event) => !_rejectedEventIds.contains(event.id))
          .where((event) =>
              vendorCategory == null ||
              event.requiredServices.isEmpty ||
              event.requiredServices.contains(vendorCategory))
          .toList();
    } catch (e) {
      // Error loading events
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Event Opportunities'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _matchingEvents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No events available',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'New event opportunities will appear here for all vendors',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMatchingEvents,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _matchingEvents.length,
                    itemBuilder: (context, index) {
                      final event = _matchingEvents[index];
                      return _EventOpportunityCard(
                        event: event,
                        onTap: () => _navigateToSubmitProposal(event),
                        onReject: () => _rejectEvent(event),
                      );
                    },
                  ),
                ),
    );
  }

  void _navigateToSubmitProposal(EventModel event) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final proposalProvider = Provider.of<ProposalProvider>(context, listen: false);

    final hasSubmitted = await proposalProvider.hasVendorSubmittedProposal(
      event.id,
      authProvider.user!.uid,
    );

    if (!mounted) return;

    if (hasSubmitted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already submitted a proposal for this event'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/submit-proposal',
      arguments: event,
    );
  }

  Future<void> _rejectEvent(EventModel event) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.user?.uid;
    if (userId == null) return;

    try {
      await _firestore.collection('event_responses').add({
        'eventId': event.id,
        'vendorId': userId,
        'status': 'rejected',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _matchingEvents.removeWhere((e) => e.id == event.id);
        _rejectedEventIds.add(event.id);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event rejected. It will no longer appear in opportunities.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to reject the event. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _EventOpportunityCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  final VoidCallback onReject;

  const _EventOpportunityCard({
    required this.event,
    required this.onTap,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.eventType,
                      style: const TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (event.proposalCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people, size: 14, color: Colors.orange.shade700),
                          const SizedBox(width: 4),
                          Text(
                            '${event.proposalCount} proposals',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                event.eventName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.calendar_today,
                text: DateFormat('MMM dd, yyyy').format(event.eventDate),
              ),
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.location_on,
                text: event.location,
              ),
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.people,
                text: '${event.guestCount} guests',
              ),
              if (event.budget != null) ...[
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.attach_money,
                  text: 'Budget: NPR ${event.budget!.toStringAsFixed(0)}',
                ),
              ],
              const SizedBox(height: 12),
              Text(
                event.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.send, size: 18),
                      label: const Text('Submit Proposal'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Reject'),
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
