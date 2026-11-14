class KitchenDocumentItem {
  final String title;
  final bool isVerified;

  const KitchenDocumentItem({
    required this.title,
    this.isVerified = true,
  });
}

class KitchenProfileModel {
  final String kitchenName;
  final double rating;
  final int reviewsCount;
  final String bannerImagePath;
  final String ownerName;
  final String businessType;
  final String cuisines;
  final String address;
  final String operatingHours;
  final List<KitchenDocumentItem> documents;

  const KitchenProfileModel({
    required this.kitchenName,
    required this.rating,
    required this.reviewsCount,
    required this.bannerImagePath,
    required this.ownerName,
    required this.businessType,
    required this.cuisines,
    required this.address,
    required this.operatingHours,
    required this.documents,
  });

  KitchenProfileModel copyWith({
    String? kitchenName,
    double? rating,
    int? reviewsCount,
    String? bannerImagePath,
    String? ownerName,
    String? businessType,
    String? cuisines,
    String? address,
    String? operatingHours,
    List<KitchenDocumentItem>? documents,
  }) {
    return KitchenProfileModel(
      kitchenName: kitchenName ?? this.kitchenName,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      bannerImagePath: bannerImagePath ?? this.bannerImagePath,
      ownerName: ownerName ?? this.ownerName,
      businessType: businessType ?? this.businessType,
      cuisines: cuisines ?? this.cuisines,
      address: address ?? this.address,
      operatingHours: operatingHours ?? this.operatingHours,
      documents: documents ?? this.documents,
    );
  }

  static KitchenProfileModel get dummy => const KitchenProfileModel(
        kitchenName: 'My Kitchen',
        rating: 5.0,
        reviewsCount: 0,
        bannerImagePath: '',
        ownerName: 'Partner Owner',
        businessType: 'Cloud Kitchen',
        cuisines: 'Multi-Cuisine',
        address: '',
        operatingHours: '10:00 AM - 10:00 PM',
        documents: [],
      );
}
