class CustomerReviewModel {
  const CustomerReviewModel({
    required this.id,
    required this.name,
    required this.timeAgo,
    required this.rating,
    required this.comment,
    this.orderedItem,
    this.isCritical = false,
    this.partnerReply,
    this.canReply = false,
  });

  final String id;
  final String name;
  final String timeAgo;
  final int rating;
  final String comment;
  final String? orderedItem;
  final bool isCritical;
  final String? partnerReply;
  final bool canReply;

  CustomerReviewModel copyWith({
    String? id,
    String? name,
    String? timeAgo,
    int? rating,
    String? comment,
    String? orderedItem,
    bool? isCritical,
    String? partnerReply,
    bool? canReply,
  }) {
    return CustomerReviewModel(
      id: id ?? this.id,
      name: name ?? this.name,
      timeAgo: timeAgo ?? this.timeAgo,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      orderedItem: orderedItem ?? this.orderedItem,
      isCritical: isCritical ?? this.isCritical,
      partnerReply: partnerReply ?? this.partnerReply,
      canReply: canReply ?? this.canReply,
    );
  }
}

class CustomerReviewsListModel {
  const CustomerReviewsListModel({
    required this.restaurantName,
    required this.reviews,
  });

  final String restaurantName;
  final List<CustomerReviewModel> reviews;

  CustomerReviewsListModel copyWith({
    String? restaurantName,
    List<CustomerReviewModel>? reviews,
  }) {
    return CustomerReviewsListModel(
      restaurantName: restaurantName ?? this.restaurantName,
      reviews: reviews ?? this.reviews,
    );
  }

  static const dummy = CustomerReviewsListModel(
    restaurantName: 'Restaurant Reviews',
    reviews: [],
  );
}
