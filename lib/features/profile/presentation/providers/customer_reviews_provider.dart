import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/customer_reviews_model.dart';
import '../../data/repositories/reviews_repository.dart';

class CustomerReviewsState {
  const CustomerReviewsState({
    required this.model,
    this.isLoading = false,
    this.errorMessage,
  });

  final CustomerReviewsListModel model;
  final bool isLoading;
  final String? errorMessage;

  CustomerReviewsState copyWith({
    CustomerReviewsListModel? model,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CustomerReviewsState(
      model: model ?? this.model,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CustomerReviewsNotifier extends Notifier<CustomerReviewsState> {
  final ReviewsRepository _reviewsRepository = ReviewsRepository();

  @override
  CustomerReviewsState build() {
    _fetchLiveReviews();
    return const CustomerReviewsState(
      model: CustomerReviewsListModel.dummy,
    );
  }

  Future<void> _fetchLiveReviews() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final data = await _reviewsRepository.getReviews();

      final rawReviews = (data['reviews'] as List<dynamic>?) ?? [];
      final mapped = rawReviews.map((r) {
        final id = r['_id']?.toString() ?? '';
        final customerName = r['customerName']?.toString() ??
            (r['customerId'] is Map ? r['customerId']['name']?.toString() : null) ??
            'Customer';
        final rating = (r['rating'] as num?)?.toInt() ?? 5;
        final comment = r['comment']?.toString() ?? r['review']?.toString() ?? '';
        final partnerReply = r['partnerReply'] is Map
            ? r['partnerReply']['comment']?.toString()
            : r['partnerReply']?.toString();
        final canReply = partnerReply == null || partnerReply.isEmpty;
        final isCritical = rating <= 2;

        return CustomerReviewModel(
          id: id,
          name: customerName,
          timeAgo: 'Recently',
          rating: rating,
          comment: comment,
          orderedItem: r['orderItem']?.toString() ?? 'Special Dish',
          isCritical: isCritical,
          partnerReply: partnerReply,
          canReply: canReply,
        );
      }).toList();

      state = state.copyWith(
        model: state.model.copyWith(reviews: mapped),
        isLoading: false,
      );
    } catch (e) {
      appLog("Notice on customer reviews fetch: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshReviews() async {
    await _fetchLiveReviews();
  }

  void initializeWithModel(CustomerReviewsListModel model) {
    state = state.copyWith(model: model);
  }

  void addPartnerReply(String reviewId, String replyText) {
    final updatedList = state.model.reviews.map((item) {
      if (item.id == reviewId) {
        return item.copyWith(
          partnerReply: replyText,
          canReply: false,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(
      model: state.model.copyWith(reviews: updatedList),
    );
  }
}

final customerReviewsProvider =
    NotifierProvider<CustomerReviewsNotifier, CustomerReviewsState>(
  CustomerReviewsNotifier.new,
);
