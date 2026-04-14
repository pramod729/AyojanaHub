import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About US')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('About Ayojana Hub', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('Ayojana Hub is your all-in-one event planning and vendor management platform. We help customers plan events, connect with trusted vendors, and manage bookings from a single mobile experience.', style: TextStyle(fontSize: 16, color: Colors.white70)),
            SizedBox(height: 24),
            Text('Why Choose US?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            SizedBox(height: 12),
            BulletText('Discover verified local vendors across catering, decorators, photographers, venues, and more.'),
            BulletText('Streamline event planning with custom event creation, proposal review, and booking confirmations.'),
            BulletText('Stay informed with notifications for proposals, bookings, and vendor updates.'),
            BulletText('Get easy support from our help center and customer service team.'),
            SizedBox(height: 24),
            Text('Version', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('1.0.0', style: TextStyle(fontSize: 16, color: Colors.white70)),
            SizedBox(height: 24),
            Text('Contact', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            SizedBox(height: 12),
            Text('support@ayojanahub.com', style: TextStyle(fontSize: 16, color: Colors.white70)),
            SizedBox(height: 4),
            Text('+977 9800000000', style: TextStyle(fontSize: 16, color: Colors.white70)),
            SizedBox(height: 24),
            Text('Legal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            SizedBox(height: 12),
            Text('© 2026 Ayojana Hub. All rights reserved.', style: TextStyle(fontSize: 16, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class BulletText extends StatelessWidget {
  final String text;
  const BulletText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 18, color: Colors.white70)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16, color: Colors.white70))),
        ],
      ),
    );
  }
}
