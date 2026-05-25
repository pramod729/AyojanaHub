import 'package:ayojana_hub/auth_provider.dart';
import 'package:ayojana_hub/proposal_model.dart';
import 'package:ayojana_hub/proposal_provider.dart';
import 'package:ayojana_hub/vendor_provider.dart';
import 'package:ayojana_hub/vendor_reply_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class VendorProposalsScreen extends StatefulWidget {
  const VendorProposalsScreen({super.key});

  @override
  State<VendorProposalsScreen> createState() => _VendorProposalsScreenState();
}

class _VendorProposalsScreenState extends State<VendorProposalsScreen> {
  @override
  void initState() {
    super.initState();
    _loadProposals();
  }

  Future<void> _loadProposals() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final proposalProvider = Provider.of<ProposalProvider>(context, listen: false);
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);

    if (authProvider.user != null) {
      final vendor = await vendorProvider.getVendorByUserId(authProvider.user!.uid);
      await proposalProvider.loadProposalsForVendor(
        authProvider.user!.uid,
        vendorDocId: vendor?.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('My Proposals'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<ProposalProvider>(
        builder: (context, proposalProvider, _) {
          if (proposalProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (proposalProvider.proposals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mail_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No proposals yet',
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
                      'Check event opportunities and submit proposals',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/vendor-opportunities');
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('View Opportunities'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadProposals,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: proposalProvider.proposals.length,
              itemBuilder: (context, index) {
                final proposal = proposalProvider.proposals[index];
                return _VendorProposalCard(
                  proposal: proposal,
                  onReply: proposal.status == 'requested'
                      ? () async {
                          final replied = await Navigator.push<bool?>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VendorReplyScreen(proposal: proposal),
                            ),
                          );
                          if (replied == true) {
                            _loadProposals();
                          }
                        }
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _VendorProposalCard extends StatelessWidget {
  final ProposalModel proposal;
  final VoidCallback? onReply;

  const _VendorProposalCard({required this.proposal, this.onReply});

  Color _getStatusColor() {
    switch (proposal.status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'quoted':
        return Colors.blue;
      case 'requested':
        return Colors.orange;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon() {
    switch (proposal.status) {
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'quoted':
        return Icons.reply;
      case 'requested':
        return Icons.request_page;
      default:
        return Icons.pending;
    }
  }

  String _getStatusText() {
    switch (proposal.status) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Not Selected';
      case 'quoted':
        return 'Quoted';
      case 'requested':
        return 'Requested';
      default:
        return 'Under Review';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proposal.eventName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        proposal.eventType,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getStatusText(),
                style: TextStyle(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Price',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'NPR ${proposal.proposedPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6C63FF),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Submitted',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM dd').format(proposal.createdAt),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (proposal.userMessage != null && proposal.userMessage!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Customer Message',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                proposal.userMessage!,
                style: const TextStyle(fontSize: 14),
              ),
            ],
            if (proposal.vendorReply != null && proposal.vendorReply!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Your Reply',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                proposal.vendorReply!,
                style: const TextStyle(fontSize: 14),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Services Included',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: proposal.servicesIncluded.take(3).map((service) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    service,
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              }).toList(),
            ),
            if (proposal.servicesIncluded.length > 3) ...[
              const SizedBox(height: 4),
              Text(
                '+${proposal.servicesIncluded.length - 3} more',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            if (proposal.status == 'requested') ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onReply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Reply to Request'),
                ),
              ),
            ],
            if (proposal.status == 'quoted') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.reply, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'You replied to this request',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (proposal.status == 'accepted') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.celebration, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Congratulations! Your proposal was accepted',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
