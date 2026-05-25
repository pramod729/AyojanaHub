import 'package:ayojana_hub/booking_model.dart';
import 'package:ayojana_hub/booking_provider.dart';
import 'package:ayojana_hub/auth_provider.dart';
import 'package:ayojana_hub/vendor_provider.dart';
import 'package:ayojana_hub/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BookingDetailScreen extends StatefulWidget {
  final BookingModel booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  Map<String, dynamic>? _docData;
  final TextEditingController _reviewController = TextEditingController();
  double _selectedRating = 5.0;
  bool _isSubmittingReview = false;

  @override
  void initState() {
    super.initState();
    _loadBookingDoc();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadBookingDoc() async {
    if (widget.booking.id.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('bookings').doc(widget.booking.id).get();
      if (doc.exists) {
        setState(() {
          _docData = doc.data();
        });
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _showReviewDialog() async {
    _selectedRating = 5.0;
    _reviewController.text = '';

    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Leave a Review'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () => setState(() => _selectedRating = index + 1.0),
                      );
                    }),
                  ),
                  TextField(
                    controller: _reviewController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Share your experience',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Submit Review'),
            ),
          ],
        );
      },
    );

    if (shouldSubmit == true) {
      await _submitReview();
    }
  }

  Future<void> _submitReview() async {
    if (_isSubmittingReview || widget.booking.id.isEmpty) return;

    setState(() {
      _isSubmittingReview = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
    final rating = _selectedRating;
    final comment = _reviewController.text.trim();

    final error = await vendorProvider.submitVendorReview(
      vendorId: widget.booking.vendorId,
      bookingId: widget.booking.id,
      customerId: widget.booking.customerId,
      customerName: widget.booking.customerName,
      rating: rating,
      comment: comment,
    );

    if (!mounted) return;

    setState(() {
      _isSubmittingReview = false;
    });

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully')),
      );
      await _loadBookingDoc();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<void> _cancelBooking(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      final error = await bookingProvider.cancelBooking(widget.booking.id);

      if (context.mounted) {
        if (error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking cancelled successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return Scaffold(
      backgroundColor: AppColors.gradientStart,
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: AppColors.gradientStart,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border.all(color: AppColors.border, width: 1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    booking.status.toLowerCase() == 'confirmed'
                        ? Icons.check_circle_outline
                        : Icons.hourglass_empty,
                    size: 60,
                    color: _getStatusColor(booking.status),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(booking.status),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.business,
                    label: 'Vendor',
                    value: booking.vendorName,
                  ),
                  _InfoRow(
                    icon: Icons.card_giftcard,
                    label: 'Service',
                    value: booking.vendorCategory,
                  ),
                  _InfoRow(
                    icon: Icons.event,
                    label: 'Event',
                    value: booking.eventName,
                  ),
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: 'Event Date',
                    value: DateFormat('MMMM dd, yyyy').format(booking.eventDate),
                  ),
                  _InfoRow(
                    icon: Icons.access_time,
                    label: 'Booking Date',
                    value: DateFormat('MMM dd, yyyy').format(booking.bookingDate),
                  ),
                  _InfoRow(
                    icon: Icons.attach_money,
                    label: 'Price',
                    value: 'NPR ${booking.price.toStringAsFixed(0)}',
                    valueColor: AppColors.gold,
                  ),
                  if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      booking.notes!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (booking.status.toLowerCase() == 'pending') ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _cancelBooking(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel Booking'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (_docData != null && _docData!['history'] != null) ...[
                    const SizedBox(height: 16),
                    const Text('Status History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                    const SizedBox(height: 8),
                    Column(
                      children: List<Widget>.from(((_docData!['history'] ?? []) as List).map((h) {
                        final ts = h['timestamp'];
                        final status = h['status'] ?? '';
                        String timeLabel = '';
                        if (ts is Timestamp) {
                          timeLabel = DateFormat('MMM dd, yyyy – hh:mm a').format(ts.toDate());
                        }
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.circle, size: 12, color: AppColors.iconInactive),
                          title: Text(status.toString(), style: const TextStyle(color: AppColors.textLight)),
                          subtitle: Text(timeLabel, style: const TextStyle(color: AppColors.textSecondary)),
                        );
                      })),
                    ),
                  ],
                  if (booking.status.toLowerCase() == 'completed') ...[
                    const SizedBox(height: 16),
                    const Text('Review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                    const SizedBox(height: 8),
                    if (_docData != null && _docData!['reviewRating'] != null) ...[
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < (_docData!['reviewRating'] as num).round() ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _docData!['reviewComment'] ?? 'Thanks for using the service!',
                        style: const TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.5),
                      ),
                    ] else ...[
                      Text(
                        'Would you like to rate your experience with ${booking.vendorName}?',
                        style: const TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.5),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmittingReview ? null : _showReviewDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(_isSubmittingReview ? 'Submitting...' : 'Leave a Review'),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.iconBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.iconPrimary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
