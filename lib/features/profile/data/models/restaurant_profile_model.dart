class RestaurantProfileModel {
  final String restaurantId;
  final String restaurantName;
  final String ownerName;
  final String email;
  final String mobile;
  final String restaurantType;
  final List<String> cuisines;
  final String fullAddress;
  final String city;
  final String pincode;
  final String bankAccountHolder;
  final String bankAccountNumber;
  final String bankIfsc;
  final String? logoUrl;
  final String? bannerUrl;
  final String status;
  final String onboardingStatus;
  final bool isOnline;
  final String createdAt;

  const RestaurantProfileModel({
    required this.restaurantId,
    required this.restaurantName,
    required this.ownerName,
    required this.email,
    required this.mobile,
    required this.restaurantType,
    required this.cuisines,
    required this.fullAddress,
    required this.city,
    required this.pincode,
    required this.bankAccountHolder,
    required this.bankAccountNumber,
    required this.bankIfsc,
    this.logoUrl,
    this.bannerUrl,
    required this.status,
    required this.onboardingStatus,
    required this.isOnline,
    required this.createdAt,
  });

  String get formattedAddress {
    final parts = [fullAddress, city, pincode].where((p) => p.isNotEmpty).toList();
    return parts.join(', ');
  }

  String get cuisinesString => cuisines.join(', ');

  factory RestaurantProfileModel.fromJson(Map<String, dynamic> json) {
    final bank = json['bankDetails'] as Map<String, dynamic>? ?? {};
    final rawCuisines = json['cuisines'];
    List<String> cuisineList = [];
    if (rawCuisines is List) {
      cuisineList = rawCuisines.map((e) => e.toString()).toList();
    } else if (rawCuisines is String) {
      cuisineList = rawCuisines.split(',').map((e) => e.trim()).toList();
    }

    return RestaurantProfileModel(
      restaurantId: json['restaurantId']?.toString() ?? '',
      restaurantName: json['restaurantName']?.toString() ?? 'My Restaurant',
      ownerName: json['ownerName']?.toString() ?? 'Partner',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      restaurantType: json['restaurantType']?.toString() ?? 'Cloud Kitchen',
      cuisines: cuisineList,
      fullAddress: json['fullAddress']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      bankAccountHolder: bank['accountHolderName']?.toString() ?? '',
      bankAccountNumber: bank['accountNumber']?.toString() ?? '',
      bankIfsc: bank['ifscCode']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString(),
      bannerUrl: json['bannerUrl']?.toString(),
      status: json['status']?.toString() ?? 'ACTIVE',
      onboardingStatus: json['onboardingStatus']?.toString() ?? 'APPROVED',
      isOnline: json['isOnline'] == true,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  factory RestaurantProfileModel.dummy() => const RestaurantProfileModel(
        restaurantId: '',
        restaurantName: 'The Great Kitchen',
        ownerName: 'John Doe',
        email: 'john@example.com',
        mobile: '9999999999',
        restaurantType: 'Cloud Kitchen',
        cuisines: ['North Indian', 'Chinese'],
        fullAddress: '123 Food Street',
        city: 'Mumbai',
        pincode: '400001',
        bankAccountHolder: 'Anil Kumar Singh',
        bankAccountNumber: '••••2455',
        bankIfsc: 'UBIN0572381',
        logoUrl: null,
        bannerUrl: null,
        status: 'PENDING',
        onboardingStatus: 'PENDING_REVIEW',
        isOnline: true,
        createdAt: '',
      );
}
