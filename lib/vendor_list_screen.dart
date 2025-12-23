import 'package:ayojana_hub/vendor_detail_screen.dart';
import 'package:ayojana_hub/vendor_model.dart';
import 'package:ayojana_hub/vendor_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VendorListScreen extends StatefulWidget {
  const VendorListScreen({super.key});

  @override
  State<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  String? _selectedCategory;

  final List<String> _categories = [
    'All',
    'Catering',
    'Photography',
    'DJ & Music',
    'Decoration',
    'Venue',
    'Planning',
  ];

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
    await vendorProvider.loadVendors(
      category: _selectedCategory == 'All' ? null : _selectedCategory,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Vendors'),
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category ||
                    (_selectedCategory == null && category == 'All');
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category == 'All' ? null : category;
                      });
                      _loadVendors();
                    },
                    selectedColor: const Color(0xFF6C63FF),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<VendorProvider>(
              builder: (context, vendorProvider, _) {
                if (vendorProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (vendorProvider.vendors.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No vendors found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vendorProvider.vendors.length,
                  itemBuilder: (context, index) {
                    final vendor = vendorProvider.vendors[index];
                    return _VendorCard(vendor: vendor);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VendorCard extends StatelessWidget {
  final VendorModel vendor;

  const _VendorCard({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VendorDetailScreen(vendor: vendor),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF6C63FF),
                child: vendor.profileImage != null
                    ? ClipOval(
                        child: Image.network(
                          vendor.profileImage!,
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                        ),
                      )
                    : Text(
                        vendor.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vendor.category,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${vendor.rating.toStringAsFixed(1)} (${vendor.reviewCount})',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
