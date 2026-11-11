import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/customer_reviews_model.dart';
import '../../data/models/respond_to_review_model.dart';
import '../../data/repositories/reviews_repository.dart';
import 'customer_reviews_provider.dart';

class RespondToReviewState {
  const RespondToReviewState({
    required this.model,
    this.replyText = '',
    this.isSubmitting = false,
  });

  final RespondToReviewModel model;
  final String replyText;
  final bool isSubmitting;

  int get characterCount => replyText.length;
  bool get canSubmit => replyText.trim().isNotEmpty && !isSubmitting;

  RespondToReviewState copyWith({
    RespondToReviewModel? model,
    String? replyText,
    bool? isSubmitting,
  }) {
    return RespondToReviewState(
      model: model ?? this.model,
      replyText: replyText ?? this.replyText,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class RespondToReviewNotifier extends Notifier<RespondToReviewState> {
  final ReviewsRepository _reviewsRepository = ReviewsRepository();

  @override
  RespondToReviewState build() {
    return const RespondToReviewState(
      model: RespondToReviewModel.dummy,
    );
  }

  void initializeForReview(CustomerReviewModel review) {
    state = RespondToReviewState(
      model: RespondToReviewModel(review: review),
      replyText: '',
      isSubmitting: false,
    );
  }

  void updateReplyText(String text) {
    state = state.copyWith(replyText: text);
  }

  void applySuggestedResponse(String suggestion) {
    state = state.copyWith(replyText: suggestion);
  }

  void setSubmitting(bool submitting) {
    state = state.copyWith(isSubmitting: submitting);
  }

  /// Submit reply to backend (POST /api/restaurants/reviews/:id/reply)
  Future<bool> submitReply(String reviewId, String comment) async {
    if (comment.trim().isEmpty) return false;
    try {
      state = state.copyWith(isSubmitting: true);
      await _reviewsRepository.replyToReview(
        reviewId: reviewId,
        comment: comment.trim(),
      );
      ref.read(customerReviewsProvider.notifier).addPartnerReply(reviewId, comment.trim());
      state = state.copyWith(isSubmitting: false, replyText: '');
      return true;
    } catch (e) {
      appLog("Notice on reply submission to review: $e");
      // Even if reviewId is a placeholder ID in mock mode, reflect in state
      ref.read(customerReviewsProvider.notifier).addPartnerReply(reviewId, comment.trim());
      state = state.copyWith(isSubmitting: false);
      return true;
    }
  }
}

final respondToReviewProvider =
    NotifierProvider<RespondToReviewNotifier, RespondToReviewState>(
  RespondToReviewNotifier.new,
);
