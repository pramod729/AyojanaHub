import 'package:ayojana_hub/proposal_model.dart';
import 'package:ayojana_hub/proposal_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VendorReplyScreen extends StatefulWidget {
  final ProposalModel proposal;

  const VendorReplyScreen({super.key, required this.proposal});

  @override
  State<VendorReplyScreen> createState() => _VendorReplyScreenState();
}

class _VendorReplyScreenState extends State<VendorReplyScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _priceController;
  final TextEditingController _replyController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.proposal.proposedPrice > 0 ? widget.proposal.proposedPrice.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    if (!_formKey.currentState!.validate()) return;

    final proposalProvider = Provider.of<ProposalProvider>(context, listen: false);
    setState(() {
      _isSubmitting = true;
    });

    final error = await proposalProvider.replyToProposal(
      widget.proposal.id,
      double.parse(_priceController.text.trim()),
      _replyController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply sent successfully'),
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
        title: const Text('Reply to Request'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Customer Request',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                widget.proposal.description,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quote Price (NPR)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a quote price';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _replyController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Reply message',
                  hintText: 'Write a brief response to the event owner',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a reply message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _sendReply,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Send Reply'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
