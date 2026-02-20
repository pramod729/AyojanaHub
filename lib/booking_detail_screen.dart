import 'package:ayojana_hub/booking_model.dart';
import 'package:ayojana_hub/booking_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _loadBookingDoc();
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
