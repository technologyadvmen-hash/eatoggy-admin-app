class FaqItemModel {
  final String id;
  final String question;
  final String answer;

  const FaqItemModel({
    required this.id,
    required this.question,
    required this.answer,
  });
}

class SupportTicketItemModel {
  final String id;
  final String ticketNumber;
  final String subject;
  final String description;
  final String category;
  final String priority;
  final String status;
  final String createdAt;
  final int messagesCount;

  const SupportTicketItemModel({
    required this.id,
    required this.ticketNumber,
    required this.subject,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.messagesCount = 1,
  });

  factory SupportTicketItemModel.fromJson(Map<String, dynamic> json) {
    final messages = json['messages'] as List<dynamic>? ?? [];
    return SupportTicketItemModel(
      id: json['_id']?.toString() ?? '',
      ticketNumber: json['ticketNumber']?.toString() ?? '#TKT-UNKNOWN',
      subject: json['subject']?.toString() ?? 'Support Request',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'OTHER',
      priority: json['priority']?.toString() ?? 'MEDIUM',
      status: json['status']?.toString() ?? 'OPEN',
      createdAt: json['createdAt']?.toString() ?? '',
      messagesCount: messages.isNotEmpty ? messages.length : 1,
    );
  }
}

class HelpSupportModel {
  final String phoneNumber;
  final String email;
  final String operatingHoursText;
  final List<String> issueCategories;
  final List<FaqItemModel> faqs;
  final List<SupportTicketItemModel> myTickets;

  const HelpSupportModel({
    required this.phoneNumber,
    required this.email,
    required this.operatingHoursText,
    required this.issueCategories,
    required this.faqs,
    this.myTickets = const [],
  });

  HelpSupportModel copyWith({
    String? phoneNumber,
    String? email,
    String? operatingHoursText,
    List<String>? issueCategories,
    List<FaqItemModel>? faqs,
    List<SupportTicketItemModel>? myTickets,
  }) {
    return HelpSupportModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      operatingHoursText: operatingHoursText ?? this.operatingHoursText,
      issueCategories: issueCategories ?? this.issueCategories,
      faqs: faqs ?? this.faqs,
      myTickets: myTickets ?? this.myTickets,
    );
  }

  static HelpSupportModel get dummy => const HelpSupportModel(
        phoneNumber: '+91 9999 8888 77',
        email: 'partner@eatoggy.com',
        operatingHoursText:
            'Support is operational everyday from 9:00 AM to 9:00 PM',
        issueCategories: [
          'Payout Issue',
          'Order Delay',
          'App Technical Glitch',
          'Menu Update Problem',
          'Customer Dispute',
          'Other',
        ],
        faqs: [
          FaqItemModel(
            id: 'faq_1',
            question: 'How to manage orders?',
            answer:
                'Go to the "Orders" tab. New incoming orders will flash in the "New" tab. You can accept, mark as preparing, and subsequently update status to Ready for pickup once cooked.',
          ),
          FaqItemModel(
            id: 'faq_2',
            question: 'How to update kitchen menu?',
            answer:
                'Navigate to the "Menu" tab from the bottom bar. You can add new dishes, modify existing prices, or toggle item availability with a single tap.',
          ),
          FaqItemModel(
            id: 'faq_3',
            question: 'How to handle order refunds?',
            answer:
                'Refund requests are reviewed under the Orders history section. You can inspect dispute reasons, accept them directly, or escalate to customer support.',
          ),
          FaqItemModel(
            id: 'faq_4',
            question: 'Subscription plan management?',
            answer:
                'Manage weekly or monthly tiffin delivery plans directly from the Subscriptions dashboard under the Kitchen tab.',
          ),
        ],
        myTickets: [],
      );
}
