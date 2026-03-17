import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AI Assistant Chat Screen
/// Provides intelligent suggestions for event planning, vendor recommendations, budgeting, etc.
class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    
    // Add initial greeting
    _addBotMessage(
      'Hello! 👋 I\'m Ayojana AI, your event planning assistant. I can help you with:\n\n'
      '• Event planning tips & ideas\n'
      '• Budget recommendations\n'
      '• Vendor suggestions\n'
      '• Timeline & scheduling advice\n'
      '• Event checklist guidance\n\n'
      'What can I help you with today?',
      isGreeting: true,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addBotMessage(String text, {bool isGreeting = false}) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        isGreeting: isGreeting,
      ));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// AI Response Generator - Provides contextual suggestions
  Future<String> _getAIResponse(String userMessage) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    final lowerMessage = userMessage.toLowerCase();

    // Event Planning Tips
    if (lowerMessage.contains('plan') || lowerMessage.contains('event')) {
      return '📋 **Event Planning Tips:**\n\n'
          '1. **Set Timeline**: Start 3-6 months early\n'
          '2. **Define Budget**: Allocate 30% for venue, 30% catering, 20% decor, 20% misc\n'
          '3. **Create Guest List**: Finalize 6 weeks before\n'
          '4. **Book Vendors**: Secure key vendors 2-3 months ahead\n'
          '5. **Send Invites**: 4-6 weeks before event\n'
          '6. **Final Confirmations**: 1 week before\n\n'
          'Would you like specific advice on any of these areas?';
    }

    // Budget Questions
    if (lowerMessage.contains('budget') || lowerMessage.contains('cost') || lowerMessage.contains('price')) {
      return '💰 **Budget Breakdown Guide:**\n\n'
          '**For a Wedding (100 guests):**\n'
          '• Venue: ₹50,000-₹2,00,000\n'
          '• Catering: ₹40,000-₹1,50,000\n'
          '• Decoration: ₹20,000-₹1,00,000\n'
          '• Photography: ₹20,000-₹75,000\n'
          '• DJ/Music: ₹10,000-₹50,000\n'
          '• Miscellaneous: ₹10,000-₹50,000\n\n'
          '💡 **Pro Tip**: Set aside 10-15% extra for contingencies.\n\n'
          'Tell me your total budget and guest count for personalized recommendations!';
    }

    // Vendor Recommendations
    if (lowerMessage.contains('vendor') || lowerMessage.contains('service') || lowerMessage.contains('catering') || 
        lowerMessage.contains('photographer') || lowerMessage.contains('decoration')) {
      return '👥 **Finding the Right Vendors:**\n\n'
          '**Top Priorities:**\n'
          '1. **Reviews & Portfolio**: Check at least 3-5 previous events\n'
          '2. **Availability**: Confirm dates immediately\n'
          '3. **Budget Alignment**: Get clear pricing\n'
          '4. **Flexibility**: Discuss customization options\n'
          '5. **Contract**: Always have written agreement\n\n'
          '**Question to Ask Vendors:**\n'
          '✓ Experience with similar events?\n'
          '✓ What\'s included in the package?\n'
          '✓ Cancellation policy?\n'
          '✓ Backup plan if issues arise?\n\n'
          'Browse our curated vendor list for quality providers!';
    }

    // Decoration Ideas
    if (lowerMessage.contains('decor') || lowerMessage.contains('decoration') || 
        lowerMessage.contains('theme') || lowerMessage.contains('design')) {
      return '🎨 **Decoration & Theme Ideas:**\n\n'
          '**Popular Themes:**\n'
          '• **Minimalist**: Clean lines, neutral colors, modern elements\n'
          '• **Vintage**: Antiques, warm lighting, classic elegance\n'
          '• **Tropical**: Bright colors, plants, natural elements\n'
          '• **Garden**: Flowers, greenery, outdoor vibes\n'
          '• **Luxury**: Gold accents, premium materials, sophisticated\n\n'
          '**Budget-Friendly Tips:**\n'
          '💡 Use DIY elements\n'
          '💡 Leverage natural lighting\n'
          '💡 Choose seasonal flowers\n'
          '💡 Mix premium & budget items\n\n'
          'What\'s your event type and preferred style?';
    }

    // Timeline & Scheduling
    if (lowerMessage.contains('timeline') || lowerMessage.contains('schedule') || 
        lowerMessage.contains('when') || lowerMessage.contains('month')) {
      return '📅 **Event Planning Timeline:**\n\n'
          '**6 Months Before:**\n'
          '• Set date & budget\n'
          '• Create guest list\n'
          '• Scout venues\n\n'
          '**3 Months Before:**\n'
          '• Book venue & key vendors\n'
          '• Finalize guest list\n'
          '• Start shopping for decor\n\n'
          '**1 Month Before:**\n'
          '• Confirm all vendors\n'
          '• Send final invites\n'
          '• Plan day-of logistics\n\n'
          '**1 Week Before:**\n'
          '• Final confirmations\n'
          '• Prepare checklist\n'
          '• Brief all vendors\n\n'
          'What event type are you planning?';
    }

    // Wedding Specific
    if (lowerMessage.contains('wedding') || lowerMessage.contains('marry') || lowerMessage.contains('bride')) {
      return '💒 **Wedding Planning Essentials:**\n\n'
          '**Key Decisions:**\n'
          '1. Date & Venue\n'
          '2. Guest Count\n'
          '3. Catering Style (Buffet/Plated/BBQ)\n'
          '4. Decor Theme\n'
          '5. Photography Style\n\n'
          '**Common Vendors Needed:**\n'
          '✓ Caterer (Most Important!)\n'
          '✓ Photographer/Videographer\n'
          '✓ Decorator/Florist\n'
          '✓ DJ/Music\n'
          '✓ Coordinator (Highly Recommended)\n\n'
          '**Budget Alert**: Catering = 40-50% of total budget\n\n'
          'How many guests are you expecting?';
    }

    // Birthday/Party
    if (lowerMessage.contains('birthday') || lowerMessage.contains('party') || lowerMessage.contains('celebration')) {
      return '🎉 **Birthday & Party Planning:**\n\n'
          '**Quick Checklist:**\n'
          '□ Date & Venue\n'
          '□ Guest List (50-100 guests is sweet spot)\n'
          '□ Catering/Snacks\n'
          '□ Decorations & Supplies\n'
          '□ Music/Entertainment\n'
          '□ Cake & Desserts\n'
          '□ Photography\n\n'
          '**Budget Guide (50 guests):**\n'
          '• Venue: ₹5,000-₹20,000\n'
          '• Catering: ₹8,000-₹25,000\n'
          '• Decor: ₹3,000-₹10,000\n'
          '• Cake: ₹2,000-₹8,000\n\n'
          '**Pro Tip**: Party themes are budget-friendly & fun!\n\n'
          'What\'s the age of the birthday person?';
    }

    // Corporate Events
    if (lowerMessage.contains('corporate') || lowerMessage.contains('conference') || 
        lowerMessage.contains('seminar') || lowerMessage.contains('business')) {
      return '🏢 **Corporate Event Planning:**\n\n'
          '**Must-Haves:**\n'
          '✓ Professional Venue\n'
          '✓ AV/Tech Setup\n'
          '✓ Quality Catering\n'
          '✓ Event Coordinator\n'
          '✓ Registration System\n\n'
          '**Timeline:**\n'
          '• 2-3 months for venue\n'
          '• 1-2 months for vendors\n'
          '• 2 weeks for final logistics\n\n'
          '**Key Metrics:**\n'
          '• Expected attendance\n'
          '• Budget per person\n'
          '• Duration (4-8 hours typical)\n\n'
          'Tell me more about your corporate event!';
    }

    // Checklist Request
    if (lowerMessage.contains('checklist') || lowerMessage.contains('todo') || lowerMessage.contains('list')) {
      return '✅ **Event Planning Checklist:**\n\n'
          '**Planning Phase (3-6 months):**\n'
          '□ Set date & budget\n'
          '□ Define event type & size\n'
          '□ Create guest list\n'
          '□ Scout 3-5 venues\n\n'
          '**Booking Phase (2-3 months):**\n'
          '□ Book venue\n'
          '□ Book caterer\n'
          '□ Book photographer\n'
          '□ Book decorator\n\n'
          '**Execution Phase (2-4 weeks):**\n'
          '□ Send invitations\n'
          '□ Confirm all vendors\n'
          '□ Finalize menu\n'
          '□ Brief all teams\n\n'
          '**Final Week:**\n'
          '□ Reconfirm everything\n'
          '□ Prepare day-of schedule\n'
          '□ Check weather\n'
          '□ Rest well!\n\n'
          'Would you like help with any specific phase?';
    }

    // Greeting/Hello
    if (lowerMessage.contains('hi') || lowerMessage.contains('hello') || 
        lowerMessage.contains('hey') || lowerMessage.contains('help')) {
      return 'Hello! 👋 Great to meet you!\n\n'
          'I\'m here to help with:\n'
          '• Event planning strategies\n'
          '• Budget & cost management\n'
          '• Vendor recommendations\n'
          '• Timeline & scheduling\n'
          '• Theme & decoration ideas\n'
          '• Event type-specific tips\n\n'
          'What\'s your event, and how can I assist?';
    }

    // Weather/Season Question
    if (lowerMessage.contains('weather') || lowerMessage.contains('season') || lowerMessage.contains('outdoor')) {
      return '🌤️ **Planning for Weather & Season:**\n\n'
          '**Outdoor Events:**\n'
          '✓ Consider backup tent (₹5,000-₹15,000)\n'
          '✓ Check seasonal weather patterns\n'
          '✓ Plan for sunrise/sunset timing\n'
          '✓ Arrange proper parking\n\n'
          '**Best Seasons:**\n'
          '• Summer (Mar-May): Bright but hot\n'
          '• Monsoon (Jun-Sep): Challenging, discounts available\n'
          '• Winter (Oct-Feb): Perfect! Popular & premium pricing\n'
          '• Spring (Mar-May): Beautiful blooms\n\n'
          '💡 **Pro Tip**: Monsoon season = 20-30% vendor discounts!\n\n'
          'When are you planning your event?';
    }

    // Default Response - Offer options
    return '🤔 That\'s an interesting question!\n\n'
        'I can help you with:\n\n'
        '📋 **Ask me about:**\n'
        '• Event planning timeline\n'
        '• Budget breakdown\n'
        '• Vendor selection\n'
        '• Specific event types (wedding, birthday, corporate)\n'
        '• Decoration themes\n'
        '• Catering ideas\n'
        '• Event checklists\n\n'
        'Feel free to ask anything about event planning! 😊';
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _addUserMessage(text);

    setState(() => _isLoading = true);
    final response = await _getAIResponse(text);
    setState(() => _isLoading = false);

    _addBotMessage(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.smart_toy,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ayojana AI',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Your event planning assistant',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About Ayojana AI'),
                  content: const Text(
                    'I\'m an intelligent event planning assistant powered by Ayojana Hub. '
                    'I can provide:\n\n'
                    '• Planning strategies\n'
                    '• Budget recommendations\n'
                    '• Timeline guidance\n'
                    '• Vendor tips\n'
                    '• Event-specific advice\n\n'
                    'For detailed vendor info and bookings, explore our vendor directory!',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'About AI Assistant',
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(message: message);
              },
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Ayojana is thinking...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ask about event planning...',
                      hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  onPressed: _isLoading ? null : _sendMessage,
                  child: Icon(
                    _isLoading ? Icons.hourglass_empty : Icons.send,
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

/// Chat Message Model
class ChatMessage {
  final String text;
  final bool isUser;
  final bool isGreeting;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isGreeting = false,
  });
}

/// Chat Bubble Widget
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(message.isUser ? 14 : 0),
            bottomRight: Radius.circular(message.isUser ? 0 : 14),
          ),
          border: message.isUser
              ? null
              : Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bot Badge
            if (!message.isUser && !message.isGreeting)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.smart_toy,
                      size: 14,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Ayojana AI',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            // Message Text
            Text(
              message.text,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: message.isUser
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
