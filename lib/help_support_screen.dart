import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const List<Map<String, String>> _faqs = [
    {
      'question': 'How do I create an event?',
      'answer': 'Go to My Events, then tap Create Event to add your event details and notify vendors.',
    },
    {
      'question': 'How do I book a vendor?',
      'answer': 'Browse the vendor directory, open a vendor profile, and submit a booking request or proposal.',
    },
    {
      'question': 'How can I update my profile?',
      'answer': 'Use the Edit Profile button on your Profile screen to update your name and phone number.',
    },
    {
      'question': 'What if I have payment issues?',
      'answer': 'Contact support through the email or phone listed below and include your booking reference.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How can we help you?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Find quick answers to common questions or reach out to our support team directly.', style: TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 24),
            const Text('Frequently Asked Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ..._faqs.map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['question']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(item['answer']!, style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Contact Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text('support@ayojanahub.com', style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 16),
                    Text('Phone', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text('+977 9800000000', style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 16),
                    Text('Response Time', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text('Typically within 24 hours.', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Need immediate help?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            const Text('If your event is urgent, please include "Urgent" in your email subject or call our support team directly.', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
