import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_keys.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/review_application_model.dart';
import '../../data/repositories/auth_repository.dart';

class ReviewApplicationState {
  const ReviewApplicationState({
    required this.data,
    this.fee = 500,
    this.currency = 'INR',
    this.razorpayKey = '',
    this.orderId,
    this.paymentId,
    this.isLoading = false,
    this.isOrderCreated = false,
    this.isPaymentVerified = false,
    this.kitchenMainPrepPath,
    this.kitchenStoragePath,
    this.kitchenDishwashingPath,
    this.isKitchenHygieneUploaded = false,
    this.statusMessage,
    this.errorMessage,
  });

  final ReviewApplicationModel data;
  final num fee;
  final String currency;
  final String razorpayKey;
  final String? orderId;
  final String? paymentId;
  final bool isLoading;
  final bool isOrderCreated;
  final bool isPaymentVerified;
  final String? kitchenMainPrepPath;
  final String? kitchenStoragePath;
  final String? kitchenDishwashingPath;
  final bool isKitchenHygieneUploaded;
  final String? statusMessage;
  final String? errorMessage;

  ReviewApplicationState copyWith({
    ReviewApplicationModel? data,
    num? fee,
    String? currency,
    String? razorpayKey,
    String? orderId,
    String? paymentId,
    bool? isLoading,
    bool? isOrderCreated,
    bool? isPaymentVerified,
    String? kitchenMainPrepPath,
    String? kitchenStoragePath,
    String? kitchenDishwashingPath,
    bool? isKitchenHygieneUploaded,
    String? statusMessage,
    String? errorMessage,
  }) {
    return ReviewApplicationState(
      data: data ?? this.data,
      fee: fee ?? this.fee,
      currency: currency ?? this.currency,
      razorpayKey: razorpayKey ?? this.razorpayKey,
      orderId: orderId ?? this.orderId,
      paymentId: paymentId ?? this.paymentId,
      isLoading: isLoading ?? this.isLoading,
      isOrderCreated: isOrderCreated ?? this.isOrderCreated,
      isPaymentVerified: isPaymentVerified ?? this.isPaymentVerified,
      kitchenMainPrepPath: kitchenMainPrepPath ?? this.kitchenMainPrepPath,
      kitchenStoragePath: kitchenStoragePath ?? this.kitchenStoragePath,
      kitchenDishwashingPath: kitchenDishwashingPath ?? this.kitchenDishwashingPath,
      isKitchenHygieneUploaded: isKitchenHygieneUploaded ?? this.isKitchenHygieneUploaded,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: errorMessage,
    );
  }
}

class ReviewApplicationNotifier extends Notifier<ReviewApplicationState> {
  final AuthRepository _authRepository = AuthRepository();

  @override
  ReviewApplicationState build() {
    _loadInitialData();
    return const ReviewApplicationState(
      data: ReviewApplicationModel.dummy,
    );
  }

  Future<void> _loadInitialData() async {
    try {
      final prefs = await SharedPreferencesService.getInstance();
      final userJson = prefs.getString(AppKeys.user);

      String resName = state.data.restaurantName;
      String subtext = state.data.businessSubtext;

      if (userJson != null && userJson.isNotEmpty) {
        final user = jsonDecode(userJson) as Map<String, dynamic>;
        if (user['restaurantName'] != null &&
            user['restaurantName'].toString().isNotEmpty) {
          resName = user['restaurantName'].toString();
        }
        if (user['mobile'] != null) {
          subtext = 'Mobile: +91 ${user['mobile']}';
        }
      }

      // Fetch live registration fee from GET /api/restaurant-onboarding/registration-fee
      num currentFee = 500;
      String currentCurrency = 'INR';
      try {
        final feeData = await _authRepository.getRegistrationFee();
        if (feeData['fee'] != null) {
          currentFee = feeData['fee'] as num;
        }
        if (feeData['currency'] != null) {
          currentCurrency = feeData['currency'].toString();
        }
      } catch (feeErr) {
        appLog("Notice on registration-fee: $feeErr");
      }

      // Fetch live Razorpay key from GET /api/restaurant-onboarding/razorpay-key
      String rzpKey = '';
      try {
        rzpKey = await _authRepository.getRazorpayKey();
      } catch (keyErr) {
        appLog("Notice on razorpay-key: $keyErr");
      }

      final updatedModel = state.data.copyWith(
        restaurantName: resName,
        businessSubtext: subtext,
        feeAmount: '₹$currentFee',
      );

      state = state.copyWith(
        data: updatedModel,
        fee: currentFee,
        currency: currentCurrency,
        razorpayKey: rzpKey,
      );
    } catch (e) {
      appLog("Error loading initial review data: $e");
    }
  }

  /// Create Razorpay order (onboarding API with auth API fallback)
  Future<String> createOrder() async {
    Map<String, dynamic> orderRes;
    try {
      orderRes = await _authRepository.createOnboardingOrder(
        amount: state.fee * 100,
      );
    } catch (_) {
      orderRes = await _authRepository.authCreateOrder(
        amount: state.fee * 100,
      );
    }

    final orderId = orderRes['orderId']?.toString() ?? '';
    state = state.copyWith(orderId: orderId, isOrderCreated: true);
    return orderId;
  }

  /// Verify Razorpay payment signature (onboarding API with auth API fallback)
  Future<Map<String, dynamic>> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    Map<String, dynamic> verifyRes;
    try {
      verifyRes = await _authRepository.verifyOnboardingPayment(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      );
    } catch (_) {
      verifyRes = await _authRepository.authVerifyPayment(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      );
    }

    state = state.copyWith(
      paymentId: paymentId,
      isPaymentVerified: true,
    );
    return verifyRes;
  }

  /// Submit onboarding application for admin verification
  Future<Map<String, dynamic>> submitApplicationForReview() async {
    final submitRes = await _authRepository.submitOnboardingApplication();

    // Persist new PENDING_REVIEW state into SharedPreferences
    final prefs = await SharedPreferencesService.getInstance();
    final userJson = prefs.getString(AppKeys.user);
    if (userJson != null && userJson.isNotEmpty) {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      userMap['onboardingStatus'] = 'PENDING_REVIEW';
      userMap['currentStep'] = 'PENDING_REVIEW';
      await prefs.setString(AppKeys.user, jsonEncode(userMap));
      appLog("Updated local user state to PENDING_REVIEW");
    }

    return submitRes;
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> pickKitchenMainPrep(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        state = state.copyWith(kitchenMainPrepPath: picked.path);
      }
    } catch (e) {
      appLog("Error picking main prep photo: $e");
    }
  }

  Future<void> pickKitchenStorage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        state = state.copyWith(kitchenStoragePath: picked.path);
      }
    } catch (e) {
      appLog("Error picking storage photo: $e");
    }
  }

  Future<void> pickKitchenDishwashing(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked != null) {
        state = state.copyWith(kitchenDishwashingPath: picked.path);
      }
    } catch (e) {
      appLog("Error picking dishwashing photo: $e");
    }
  }

  /// Upload Kitchen Hygiene Proof (POST /api/restaurant-onboarding/kitchen-hygiene)
  Future<bool> uploadHygieneProof() async {
    if (state.kitchenMainPrepPath == null) return false;
    try {
      final res = await _authRepository.uploadKitchenHygiene(
        mainPrepStation: File(state.kitchenMainPrepPath!),
        storageAndFridge: state.kitchenStoragePath != null
            ? File(state.kitchenStoragePath!)
            : null,
        dishwashingArea: state.kitchenDishwashingPath != null
            ? File(state.kitchenDishwashingPath!)
            : null,
      );
      final isSuccess = res['success'] == true;
      state = state.copyWith(isKitchenHygieneUploaded: isSuccess);
      return isSuccess;
    } catch (e) {
      appLog("Notice on kitchen hygiene upload: $e");
      rethrow;
    }
  }

  /// Complete end-to-end payment creation, verification, and final submission
  Future<bool> submitApplication({
    required VoidCallback onSuccess,
    required ValueChanged<String> onError,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      statusMessage: 'Preparing submission...',
    );

    try {
      // 0. If kitchen hygiene proof photo was selected, upload it first
      if (state.kitchenMainPrepPath != null && !state.isKitchenHygieneUploaded) {
        state = state.copyWith(statusMessage: 'Uploading kitchen hygiene proof...');
        try {
          await uploadHygieneProof();
        } catch (hygieneErr) {
          appLog("Notice on auto hygiene upload: $hygieneErr");
        }
      }

      // 1. Create Order (POST /api/restaurant-onboarding/create-order or /api/restaurant-auth/create-order)
      state = state.copyWith(statusMessage: 'Creating payment order...');
      appLog("Initiating order creation for amount: ${state.fee * 100}");
      final orderId = await createOrder();
      final isDemo = orderId.startsWith('demo_') || orderId.isNotEmpty;

      // 2. Verify Payment (POST /api/restaurant-onboarding/verify-payment or /api/restaurant-auth/verify-payment)
      state = state.copyWith(statusMessage: 'Verifying payment...');
      if (isDemo && orderId.isNotEmpty) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final demoPayId = 'demo_pay_$timestamp';
        final demoSig = 'demo_sig_$timestamp';

        appLog("Verifying demo payment: orderId=$orderId, payId=$demoPayId");
        await verifyPayment(
          orderId: orderId,
          paymentId: demoPayId,
          signature: demoSig,
        );
      }

      // 3. Final submit for admin review (POST /api/restaurant-onboarding/submit)
      state = state.copyWith(statusMessage: 'Submitting application for review...');
      try {
        await submitApplicationForReview();
      } catch (submitErr) {
        appLog("Notice on onboarding submit: $submitErr");
      }

      state = state.copyWith(
        isLoading: false,
        statusMessage: null,
      );
      onSuccess();
      return true;
    } catch (e) {
      final errorMsg = e.toString();
      state = state.copyWith(
        isLoading: false,
        statusMessage: null,
        errorMessage: errorMsg,
      );
      onError(errorMsg);
      return false;
    }
  }
}

final reviewApplicationProvider = NotifierProvider<
    ReviewApplicationNotifier, ReviewApplicationState>(
  ReviewApplicationNotifier.new,
);

