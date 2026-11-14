import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/ratings_and_reviews_model.dart';
import '../../data/repositories/reviews_repository.dart';

class RatingsAndReviewsState {
  const RatingsAndReviewsState({
    required this.model,
    this.selectedFilter = 'All',
    this.isLoading = false,
    this.errorMessage,
  });

  final RatingsAndReviewsModel model;
  final String selectedFilter;
  final bool isLoading;
  final String? errorMessage;

  List<CustomerReviewItem> get filteredReviews {
    if (selectedFilter == 'All') return model.reviews;
    return model.reviews
        .where((r) => r.tag.toLowerCase() == selectedFilter.toLowerCase())
        .toList();
  }

  RatingsAndReviewsState copyWith({
    RatingsAndReviewsModel? model,
    String? selectedFilter,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RatingsAndReviewsState(
      model: model ?? this.model,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class RatingsAndReviewsNotifier extends Notifier<RatingsAndReviewsState> {
  final ReviewsRepository _reviewsRepository = ReviewsRepository();

  @override
  RatingsAndReviewsState build() {
    _fetchLiveReviews();
    return const RatingsAndReviewsState(
      model: RatingsAndReviewsModel.dummy,
      selectedFilter: 'All',
    );
  }

  Future<void> _fetchLiveReviews() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final data = await _reviewsRepository.getReviews();

      if (data.isNotEmpty) {
        final avgRating = (data['avgRating'] as num?)?.toDouble() ?? 0.0;
        final totalReviews = (data['totalReviews'] as num?)?.toInt() ?? 0;
        final rawReviews = data['reviews'] as List<dynamic>? ?? [];

        final mappedReviews = rawReviews.map((r) {
          final id = r['_id']?.toString() ?? '';
          final customerName = r['customerName']?.toString() ??
              (r['customerId'] is Map ? r['customerId']['name']?.toString() : null) ??
              'Customer';
          final rating = (r['rating'] as num?)?.toDouble() ?? 5.0;
          final comment = r['comment']?.toString() ?? r['review']?.toString() ?? '';
          final tag = rating >= 4.0 ? 'Positive' : (rating >= 3.0 ? 'Neutral' : 'Critical');

          return CustomerReviewItem(
            id: id,
            customerName: customerName,
            rating: rating,
            timeAgo: 'Recently',
            comment: comment,
            tag: tag,
          );
        }).toList();

        final updatedModel = state.model.copyWith(
          overallRating: avgRating > 0 ? avgRating.toStringAsFixed(1) : state.model.overallRating,
          verifiedReviewsCount: totalReviews > 0 ? totalReviews : mappedReviews.length,
          reviews: mappedReviews,
        );

        state = state.copyWith(
          model: updatedModel,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          model: state.model.copyWith(reviews: []),
          isLoading: false,
        );
      }
    } catch (e) {
      appLog("Notice on live reviews fetch: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshReviews() async {
    await _fetchLiveReviews();
  }

  void initializeWithData(RatingsAndReviewsModel data) {
    state = state.copyWith(model: data);
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }
}

final ratingsAndReviewsProvider =
    NotifierProvider<RatingsAndReviewsNotifier, RatingsAndReviewsState>(
  RatingsAndReviewsNotifier.new,
);
