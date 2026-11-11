import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/help_support_model.dart';
import '../../data/repositories/support_repository.dart';

class HelpSupportState {
  final HelpSupportModel model;
  final String? expandedFaqId;
  final String searchQuery;
  final String selectedCategory;
  final String issueDescription;
  final bool isSubmitting;
  final bool isLoadingTickets;
  final String? lastCreatedTicketNumber;

  const HelpSupportState({
    required this.model,
    this.expandedFaqId = 'faq_1',
    this.searchQuery = '',
    this.selectedCategory = 'Payout Issue',
    this.issueDescription = '',
    this.isSubmitting = false,
    this.isLoadingTickets = false,
    this.lastCreatedTicketNumber,
  });

  List<FaqItemModel> get filteredFaqs {
    if (searchQuery.trim().isEmpty) {
      return model.faqs;
    }
    final q = searchQuery.toLowerCase().trim();
    return model.faqs.where((faq) {
      return faq.question.toLowerCase().contains(q) ||
          faq.answer.toLowerCase().contains(q);
    }).toList();
  }

  HelpSupportState copyWith({
    HelpSupportModel? model,
    String? expandedFaqId,
    bool clearExpanded = false,
    String? searchQuery,
    String? selectedCategory,
    String? issueDescription,
    bool? isSubmitting,
    bool? isLoadingTickets,
    String? lastCreatedTicketNumber,
  }) {
    return HelpSupportState(
      model: model ?? this.model,
      expandedFaqId:
          clearExpanded ? null : (expandedFaqId ?? this.expandedFaqId),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      issueDescription: issueDescription ?? this.issueDescription,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isLoadingTickets: isLoadingTickets ?? this.isLoadingTickets,
      lastCreatedTicketNumber:
          lastCreatedTicketNumber ?? this.lastCreatedTicketNumber,
    );
  }
}

class HelpSupportNotifier extends Notifier<HelpSupportState> {
  final SupportRepository _supportRepository = SupportRepository();

  @override
  HelpSupportState build() {
    _fetchMyTickets();
    return HelpSupportState(
      model: HelpSupportModel.dummy,
    );
  }

  Future<void> _fetchMyTickets() async {
    try {
      state = state.copyWith(isLoadingTickets: true);
      final rawTickets = await _supportRepository.getMyTickets();
      final parsedTickets = rawTickets
          .map((t) => SupportTicketItemModel.fromJson(t))
          .toList();

      state = state.copyWith(
        model: state.model.copyWith(myTickets: parsedTickets),
        isLoadingTickets: false,
      );
    } catch (e) {
      appLog("Notice fetching support tickets: $e");
      state = state.copyWith(isLoadingTickets: false);
    }
  }

  Future<void> refreshTickets() async {
    await _fetchMyTickets();
  }

  void toggleFaq(String faqId) {
    if (state.expandedFaqId == faqId) {
      state = state.copyWith(clearExpanded: true);
    } else {
      state = state.copyWith(expandedFaqId: faqId);
    }
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void updateIssueDescription(String text) {
    state = state.copyWith(issueDescription: text);
  }

  Future<bool> submitTicket() async {
    if (state.issueDescription.trim().isEmpty) {
      return false;
    }
    state = state.copyWith(isSubmitting: true);
    try {
      final res = await _supportRepository.createTicket(
        category: state.selectedCategory,
        subject: '${state.selectedCategory} Query',
        description: state.issueDescription.trim(),
        priority: 'MEDIUM',
      );

      final ticketNumber = res['data']?['ticketNumber']?.toString() ?? 'TKT-SUBMITTED';

      // Refresh list from backend to get fresh tickets
      await _fetchMyTickets();

      state = state.copyWith(
        isSubmitting: false,
        issueDescription: '',
        lastCreatedTicketNumber: ticketNumber,
      );
      return true;
    } catch (e) {
      appLog("Error submitting support ticket: $e");
      state = state.copyWith(isSubmitting: false);
      return false;
    }
  }
}

final helpSupportProvider =
    NotifierProvider<HelpSupportNotifier, HelpSupportState>(
  HelpSupportNotifier.new,
);
