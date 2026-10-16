class ReviewApplicationModel {
  const ReviewApplicationModel({
    required this.screenTitle,
    required this.stepText,
    required this.headingText,
    required this.businessTitle,
    required this.restaurantName,
    required this.businessSubtext,
    required this.documentsTitle,
    required this.documentsList,
    required this.bankTitle,
    required this.bankInfo,
    required this.feeTitle,
    required this.feeSubtext,
    required this.feeAmount,
    required this.buttonText,
  });

  final String screenTitle;
  final String stepText;
  final String headingText;
  final String businessTitle;
  final String restaurantName;
  final String businessSubtext;
  final String documentsTitle;
  final List<String> documentsList;
  final String bankTitle;
  final String bankInfo;
  final String feeTitle;
  final String feeSubtext;
  final String feeAmount;
  final String buttonText;

  static const dummy = ReviewApplicationModel(
    screenTitle: 'Review Details',
    stepText: 'Step 4 of 4',
    headingText: 'Review Your Application',
    businessTitle: 'Business Details',
    restaurantName: 'The Golden Spoon Kitchen',
    businessSubtext: 'Cloud Kitchen • Sector 62, Noida',
    documentsTitle: 'Uploaded Documents',
    documentsList: ['GST Certificate', 'FSSAI License', 'Aadhaar Card (Front & Back)'],
    bankTitle: 'Bank Account',
    bankInfo: 'HDFC Bank • Verified',
    feeTitle: 'Onboarding Registration Fee',
    feeSubtext: 'Includes partner verification & kitchen listing',
    feeAmount: '₹500',
    buttonText: 'Pay & Submit Application',
  );

  ReviewApplicationModel copyWith({
    String? screenTitle,
    String? stepText,
    String? headingText,
    String? businessTitle,
    String? restaurantName,
    String? businessSubtext,
    String? documentsTitle,
    List<String>? documentsList,
    String? bankTitle,
    String? bankInfo,
    String? feeTitle,
    String? feeSubtext,
    String? feeAmount,
    String? buttonText,
  }) {
    return ReviewApplicationModel(
      screenTitle: screenTitle ?? this.screenTitle,
      stepText: stepText ?? this.stepText,
      headingText: headingText ?? this.headingText,
      businessTitle: businessTitle ?? this.businessTitle,
      restaurantName: restaurantName ?? this.restaurantName,
      businessSubtext: businessSubtext ?? this.businessSubtext,
      documentsTitle: documentsTitle ?? this.documentsTitle,
      documentsList: documentsList ?? this.documentsList,
      bankTitle: bankTitle ?? this.bankTitle,
      bankInfo: bankInfo ?? this.bankInfo,
      feeTitle: feeTitle ?? this.feeTitle,
      feeSubtext: feeSubtext ?? this.feeSubtext,
      feeAmount: feeAmount ?? this.feeAmount,
      buttonText: buttonText ?? this.buttonText,
    );
  }
}
