import 'package:ayojana_hub/package_model.dart';
import 'package:ayojana_hub/vendor_model.dart';
import 'package:ayojana_hub/vendor_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VendorDetailScreen extends StatefulWidget {
  final VendorModel vendor;

  const VendorDetailScreen({super.key, required this.vendor});

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
    await vendorProvider.loadVendorPackages(widget.vendor.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vendor Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF6C63FF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: widget.vendor.profileImage != null
                        ? ClipOval(
                            child: Image.network(
                              widget.vendor.profileImage!,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            ),
                          )
                        : Text(
                            widget.vendor.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              color: Color(0xFF6C63FF),
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.vendor.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.vendor.category,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.vendor.rating.toStringAsFixed(1)} (${widget.vendor.reviewCount} reviews)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Vendor Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.vendor.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ContactRow(
                    icon: Icons.phone,
                    label: widget.vendor.phone,
                  ),
                  _ContactRow(
                    icon: Icons.email,
                    label: widget.vendor.email,
                  ),
                  _ContactRow(
                    icon: Icons.location_on,
                    label: widget.vendor.location,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Services Offered',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.vendor.services.map((service) {
                      return Chip(
                        label: Text(service),
                        backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Packages',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Consumer<VendorProvider>(
                    builder: (context, vendorProvider, _) {
                      if (vendorProvider.packages.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text('No packages available'),
                          ),
                        );
                      }

                      return Column(
                        children: vendorProvider.packages.map((package) {
                          return _PackageCard(
                            package: package,
                            vendorName: widget.vendor.name,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ContactRow({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6C63FF)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final PackageModel package;
  final String vendorName;

  const _PackageCard({
    required this.package,
    required this.vendorName,
  });

  void _showBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Package'),
        content: Text('Do you want to book "${package.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement booking logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking feature will be implemented'),
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                    package.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'NPR ${package.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C63FF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              package.description,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Features:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ...package.features.map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showBookingDialog(context),
                child: const Text('Book Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}