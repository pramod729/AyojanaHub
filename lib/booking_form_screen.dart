import 'package:ayojana_hub/auth_provider.dart';
import 'package:ayojana_hub/booking_model.dart';
import 'package:ayojana_hub/booking_provider.dart';
import 'package:ayojana_hub/theme/app_colors.dart';
import 'package:ayojana_hub/vendor_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BookingFormScreen extends StatefulWidget {
  final VendorModel vendor;

  const BookingFormScreen({super.key, required this.vendor});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _eventTypeController;
  late TextEditingController _guestCountController;
  late TextEditingController _budgetController;
  late TextEditingController _notesController;
  late DateTime _selectedEventDate;

  @override
  void initState() {
    super.initState();
    _eventTypeController = TextEditingController();
    _guestCountController = TextEditingController();
    _budgetController = TextEditingController();
    _notesController = TextEditingController();
    _selectedEventDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _eventTypeController.dispose();
    _guestCountController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectEventDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedEventDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedEventDate = picked);
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final user = authProvider.userModel;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    // Use vendor's userId (auth UID) instead of vendor document ID
    final vendorAuthUid = widget.vendor.userId ?? widget.vendor.id;
    
    print('DEBUG: Creating booking with vendorId: $vendorAuthUid (userId: ${widget.vendor.userId}, id: ${widget.vendor.id})');
    
    final booking = BookingModel(
      id: '',
      customerId: authProvider.user!.uid,
      customerName: user.name,
      vendorId: vendorAuthUid,
      vendorName: widget.vendor.name,
      vendorCategory: widget.vendor.category,
      price: double.parse(_budgetController.text),
      guestCount: int.parse(_guestCountController.text),
      eventType: _eventTypeController.text.trim(),
      bookingDate: DateTime.now(),
      eventDate: _selectedEventDate,
      status: 'pending',
      notes: _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final error = await bookingProvider.createBooking(booking);
    if (context.mounted) Navigator.pop(context);

    if (error == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking request sent successfully!')),
        );
        Navigator.pop(context);
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gradientStart,
      appBar: AppBar(
        title: const Text('Book Service'),
        backgroundColor: AppColors.gradientStart,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vendor Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border.all(color: AppColors.border, width: 1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.iconBackground,
                        child: widget.vendor.profileImage != null
                            ? ClipOval(
                                child: Image.network(
                                  widget.vendor.profileImage!,
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                  errorBuilder: (_, __, ___) => Text(
                                    widget.vendor.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      color: AppColors.iconPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            : Text(
                                widget.vendor.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 32,
                                  color: AppColors.iconPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.vendor.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.vendor.category,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 14, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.vendor.rating.toStringAsFixed(1)} (${widget.vendor.reviewCount})',
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Form
            Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booking Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Event Type
                    TextFormField(
                      controller: _eventTypeController,
                      decoration: InputDecoration(
                        labelText: 'Event Type',
                        hintText: 'e.g., Wedding, Birthday, Corporate',
                        prefixIcon: const Icon(Icons.event),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.card,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Event type is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Event Date
                    InkWell(
                      onTap: () => _selectEventDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Event Date',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppColors.card,
                        ),
                        child: Text(
                          DateFormat('MMM dd, yyyy').format(_selectedEventDate),
                          style: const TextStyle(fontSize: 16, color: AppColors.textLight),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Guest Count
                    TextFormField(
                      controller: _guestCountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Number of Guests',
                        hintText: 'e.g., 100',
                        prefixIcon: const Icon(Icons.people),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.card,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Guest count is required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Budget
                    TextFormField(
                      controller: _budgetController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Budget (NPR)',
                        hintText: 'e.g., 50000',
                        prefixIcon: const Icon(Icons.monetization_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.card,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Budget is required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Notes
                    TextFormField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Additional Notes',
                        hintText: 'Any special requests or preferences...',
                        prefixIcon: const Icon(Icons.note),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.card,
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Send Booking Request',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
