class RatingDistributionItem {
  const RatingDistributionItem({
    required this.starsLabel,
    required this.percentage,
    required this.fillRatio,
  });

  final String starsLabel;
  final int percentage;
  final double fillRatio;
}

class MonthlyPerformance {
  const MonthlyPerformance({
    required this.averageRating,
    required this.totalReviews,
    required this.responseRate,
  });

  final String averageRating;
  final int totalReviews;
  final String responseRate;
}

class CustomerReviewItem {
  const CustomerReviewItem({
    required this.id,
    required this.customerName,
    required this.rating,
    required this.timeAgo,
    required this.comment,
    required this.tag,
  });

  final String id;
  final String customerName;
  final double rating;
  final String timeAgo;
  final String comment;
  final String tag;
}

class RatingsAndReviewsModel {
  const RatingsAndReviewsModel({
    required this.partnerName,
    required this.overallRating,
    required this.verifiedReviewsCount,
    required this.distributions,
    required this.monthlyPerformance,
    required this.filterChips,
    required this.reviews,
  });

  final String partnerName;
  final String overallRating;
  final int verifiedReviewsCount;
  final List<RatingDistributionItem> distributions;
  final MonthlyPerformance monthlyPerformance;
  final List<String> filterChips;
  final List<CustomerReviewItem> reviews;

  RatingsAndReviewsModel copyWith({
    String? partnerName,
    String? overallRating,
    int? verifiedReviewsCount,
    List<RatingDistributionItem>? distributions,
    MonthlyPerformance? monthlyPerformance,
    List<String>? filterChips,
    List<CustomerReviewItem>? reviews,
  }) {
    return RatingsAndReviewsModel(
      partnerName: partnerName ?? this.partnerName,
      overallRating: overallRating ?? this.overallRating,
      verifiedReviewsCount:
          verifiedReviewsCount ?? this.verifiedReviewsCount,
      distributions: distributions ?? this.distributions,
      monthlyPerformance: monthlyPerformance ?? this.monthlyPerformance,
      filterChips: filterChips ?? this.filterChips,
      reviews: reviews ?? this.reviews,
    );
  }

  static const dummy = RatingsAndReviewsModel(
    partnerName: 'Restaurant Partner',
    overallRating: '5.0',
    verifiedReviewsCount: 0,
    distributions: [
      RatingDistributionItem(
        starsLabel: '5 Star',
        percentage: 100,
        fillRatio: 1.0,
      ),
      RatingDistributionItem(
        starsLabel: '4 Star',
        percentage: 0,
        fillRatio: 0.0,
      ),
      RatingDistributionItem(
        starsLabel: '3 Star',
        percentage: 0,
        fillRatio: 0.0,
      ),
      RatingDistributionItem(
        starsLabel: '2 Star',
        percentage: 0,
        fillRatio: 0.0,
      ),
      RatingDistributionItem(
        starsLabel: '1 Star',
        percentage: 0,
        fillRatio: 0.0,
      ),
    ],
    monthlyPerformance: MonthlyPerformance(
      averageRating: '5.0',
      totalReviews: 0,
      responseRate: '100%',
    ),
    filterChips: ['All', 'Positive', 'Negative', 'Recent'],
    reviews: [],
  );
}
