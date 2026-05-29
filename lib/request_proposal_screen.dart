import 'package:ayojana_hub/auth_provider.dart';
import 'package:ayojana_hub/event_model.dart';
import 'package:ayojana_hub/proposal_model.dart';
import 'package:ayojana_hub/proposal_provider.dart';
import 'package:ayojana_hub/vendor_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RequestProposalScreen extends StatefulWidget {
  final VendorModel vendor;

  const RequestProposalScreen({super.key, required this.vendor});

  @override
  State<RequestProposalScreen> createState() => _RequestProposalScreenState();
}

class _RequestProposalScreenState extends State<RequestProposalScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<EventModel> _events = [];
  EventModel? _selectedEvent;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadMyEvents();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadMyEvents() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.user;

    if (currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final querySnapshot = await _firestore
          .collection('events')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _events = querySnapshot.docs
            .map((doc) => EventModel.fromMap(doc.data(), doc.id))
            .toList();
        if (_events.isNotEmpty) {
          _selectedEvent = _events.first;
        }
      });
    } catch (e) {
      debugPrint('Failed to load events for proposal request: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate() || _selectedEvent == null) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final proposalProvider = Provider.of<ProposalProvider>(context, listen: false);
    final currentUser = authProvider.user;
    final currentUserModel = authProvider.userModel;

    if (currentUser == null || currentUserModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to request a proposal'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final proposal = ProposalModel(
      id: '',
      eventId: _selectedEvent!.id,
      eventName: _selectedEvent!.eventName,
      eventType: _selectedEvent!.eventType,
      userId: currentUser.uid,
      vendorId: (widget.vendor.userId != null && widget.vendor.userId!.isNotEmpty)
          ? widget.vendor.userId!
          : widget.vendor.id,
      vendorName: widget.vendor.name,
      vendorCategory: widget.vendor.category,
      proposedPrice: double.tryParse(_priceController.text.trim()) ?? 0,
      description: _messageController.text.trim(),
      servicesIncluded: _selectedEvent!.requiredServices,
      deliveryTime: DateFormat('MMM dd, yyyy').format(_selectedEvent!.eventDate),
      status: 'requested',
      createdAt: DateTime.now(),
      userMessage: _messageController.text.trim(),
    );

    final error = await proposalProvider.submitProposalRequest(proposal);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proposal request sent successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Proposal'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_available, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'No events found',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Create an event first and then request a proposal from this vendor.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/create-event');
                        },
                        child: const Text('Create Event'),
                      ),
                    ],
                  ),
                )
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Send proposal request to ${widget.vendor.name}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<EventModel>(
                          value: _selectedEvent,
                          decoration: InputDecoration(
                            labelText: 'Choose Event',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: _events.map((event) {
                            return DropdownMenuItem<EventModel>(
                              value: event,
                              child: Text(event.eventName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedEvent = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_selectedEvent != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedEvent!.eventType,
                                  style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _selectedEvent!.eventName,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  DateFormat('MMM dd, yyyy').format(_selectedEvent!.eventDate),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Expected Budget (NPR)',
                            hintText: 'Enter your budget for this event',
                            prefixIcon: const Icon(Icons.currency_rupee, color: Color(0xFF6C63FF)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a budget';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _messageController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: 'Message to vendor',
                            hintText: 'Describe your event needs and expectations',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a message';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitRequest,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Send Request'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
