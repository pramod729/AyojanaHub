import 'package:ayojana_hub/theme/app_colors.dart';
import 'package:ayojana_hub/vendor_model.dart';
import 'package:ayojana_hub/vendor_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VendorReviewsScreen extends StatefulWidget {
  final VendorModel vendor;

  const VendorReviewsScreen({super.key, required this.vendor});

  @override
  State<VendorReviewsScreen> createState() => _VendorReviewsScreenState();
}

class _VendorReviewsScreenState extends State<VendorReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VendorProvider>(context, listen: false).loadVendorReviews(widget.vendor.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reviews & Ratings'),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textLight),
        titleTextStyle: const TextStyle(color: AppColors.textLight, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      body: Consumer<VendorProvider>(
        builder: (context, vendorProvider, _) {
          final reviews = vendorProvider.vendorReviews;
          final loading = vendorProvider.isReviewLoading;
          final error = vendorProvider.reviewError;

          if (loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => vendorProvider.loadVendorReviews(widget.vendor.id),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: AppColors.card,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Vendor Rating', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              widget.vendor.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 12),
                            Text('${widget.vendor.reviewCount} reviews', style: const TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Error message removed per request: silently allow pull-to-refresh instead
                if (reviews.isEmpty)
                  const Column(
                    children: [
                      Icon(Icons.star_outline, size: 80, color: AppColors.textSecondary),
                      SizedBox(height: 16),
                      Text(
                        'No reviews yet for this vendor.',
                        style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                else ...reviews.map((review) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              review.customerName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Row(
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  index < review.rating.round() ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          review.comment.isNotEmpty ? review.comment : 'No comment provided.',
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          review.createdAt.toLocal().toString().split('.').first,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
