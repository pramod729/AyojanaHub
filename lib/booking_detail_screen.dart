import 'package:ayojana_hub/booking_model.dart';
import 'package:ayojana_hub/booking_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BookingDetailScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailScreen({super.key, required this.booking});

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
      final error = await bookingProvider.cancelBooking(booking.id);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
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
                color: _getStatusColor(booking.status),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    booking.status.toLowerCase() == 'confirmed'
                        ? Icons.check_circle_outline
                        : Icons.hourglass_empty,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    booking.status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                    label: 'Package',
                    value: booking.packageName,
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
                    valueColor: const Color(0xFF6C63FF),
                  ),
                  if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      booking.notes!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
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
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel Booking'),
                      ),
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
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
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
