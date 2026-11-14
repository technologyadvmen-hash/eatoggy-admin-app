import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_keys.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/network_exceptions.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/logger.dart';

class AuthRepository {
  final Dio _dio = ApiService.dio;

  /// Send OTP to restaurant partner's mobile number
  /// POST /api/restaurant-auth/send-otp
  Future<Map<String, dynamic>> sendOtp({required String mobile}) async {
    try {
      final response = await _dio.post(
        ApiConstants.sendOtp,
        data: {'mobile': mobile},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['success'] == false) {
          throw data['message'] ?? 'Failed to send OTP';
        }
        appLog("✅ Send OTP Response: $data");
        return data;
      }
      return {'success': true, 'message': 'OTP sent successfully'};
    } on DioException catch (e) {
      appLog("❌ Send OTP Error: ${e.response?.data}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Send OTP General Error: $e");
      if (e is String) rethrow;
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  /// Resend OTP to restaurant partner's mobile number
  /// POST /api/restaurant-auth/resend-otp
  Future<Map<String, dynamic>> resendOtp({required String mobile}) async {
    try {
      final response = await _dio.post(
        ApiConstants.resendOtp,
        data: {'mobile': mobile},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['success'] == false) {
          throw data['message'] ?? 'Failed to resend OTP';
        }
        appLog("✅ Resend OTP Response: $data");
        return data;
      }
      return {'success': true, 'message': 'OTP resent successfully'};
    } on DioException catch (e) {
      appLog("❌ Resend OTP Error: ${e.response?.data}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Resend OTP General Error: $e");
      if (e is String) rethrow;
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  /// Verify OTP and receive JWT token + user details
  /// POST /api/restaurant-auth/verify-otp
  Future<Map<String, dynamic>> verifyOtp({
    required String mobile,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyOtp,
        data: {
          'mobile': mobile,
          'otp': otp,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        final token = data['token'] as String?;
        if (token != null && token.isNotEmpty) {
          final prefs = await SharedPreferencesService.getInstance();
          await prefs.setString(AppKeys.accessToken, token);
          appLog("🔐 Stored JWT Bearer Token in SharedPreferences");
        }

        if (data['user'] != null) {
          final prefs = await SharedPreferencesService.getInstance();
          await prefs.setString(AppKeys.user, jsonEncode(data['user']));
          appLog("👤 Stored User Details in SharedPreferences");
        }

        return data;
      }

      throw data['message'] ?? 'OTP verification failed';
    } on DioException catch (e) {
      appLog("❌ Verify OTP Error: ${e.response?.data}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Verify OTP General Error: $e");
      if (e is String) rethrow;
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  /// Submit Business Details during onboarding
  /// PUT /api/restaurant-onboarding/business-details
  Future<Map<String, dynamic>> updateBusinessDetails({
    required String restaurantName,
    required String ownerName,
    required String restaurantType,
    required String fullAddress,
    String? phone,
    String? email,
    String? cuisine,
    Map<String, String>? operatingHours,
  }) async {
    try {
      final payload = <String, dynamic>{
        'restaurantName': restaurantName,
        'ownerName': ownerName,
        'restaurantType': restaurantType,
        'fullAddress': fullAddress,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (email != null && email.isNotEmpty) 'email': email,
        if (cuisine != null && cuisine.isNotEmpty) 'cuisine': cuisine,
        'operatingHours': ?operatingHours,
      };

      final response = await _dio.put(
        ApiConstants.businessDetails,
        data: payload,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        // Update token if new token is provided
        final newToken = data['data']?['token'] as String?;
        if (newToken != null && newToken.isNotEmpty) {
          final prefs = await SharedPreferencesService.getInstance();
          await prefs.setString(AppKeys.accessToken, newToken);
          appLog("🔄 Updated JWT Bearer Token from Business Details response");
        }
        return data;
      }

      throw data['message'] ?? 'Failed to update business details';
    } on DioException catch (e) {
      appLog("❌ Business Details Error: ${e.response?.data}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Business Details General Error: $e");
      if (e is String) rethrow;
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  /// Upload GST Certificate and FSSAI Food License
  /// PUT /api/restaurant-onboarding/business-docs
  Future<Map<String, dynamic>> uploadBusinessDocs({
    required File gstCertificate,
    required File foodLicense,
  }) async {
    try {
      final gstFileName = gstCertificate.path.split(Platform.pathSeparator).last;
      final foodFileName = foodLicense.path.split(Platform.pathSeparator).last;

      final formData = FormData.fromMap({
        'gstCertificate': await MultipartFile.fromFile(
          gstCertificate.path,
          filename: gstFileName,
        ),
        'foodLicense': await MultipartFile.fromFile(
          foodLicense.path,
          filename: foodFileName,
        ),
      });

      final response = await _dio.put(
        ApiConstants.businessDocs,
        data: formData,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        appLog("✅ Business Documents uploaded successfully");
        return data;
      }

      throw data['message'] ?? 'Failed to upload business documents';
    } on DioException catch (e) {
      appLog("❌ Business Docs Error: ${e.response?.data}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Business Docs General Error: $e");
      if (e is String) rethrow;
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  /// Submit Identity (Aadhaar Front & Back) & Bank Account Details
  /// POST /api/restaurant-onboarding/identity-bank
  Future<Map<String, dynamic>> submitIdentityAndBank({
    required String accountHolderName,
    required String accountNumber,
    required String ifscCode,
    required String bankName,
    required File aadhaarFront,
    required File aadhaarBack,
  }) async {
    try {
      final frontFileName = aadhaarFront.path.split(Platform.pathSeparator).last;
      final backFileName = aadhaarBack.path.split(Platform.pathSeparator).last;

      final formData = FormData.fromMap({
        'accountHolderName': accountHolderName.trim(),
        'accountNumber': accountNumber.trim(),
        'ifscCode': ifscCode.trim().toUpperCase(),
        'bankName': bankName.trim(),
        'aadhaarFront': await MultipartFile.fromFile(
          aadhaarFront.path,
          filename: frontFileName,
        ),
        'aadhaarBack': await MultipartFile.fromFile(
          aadhaarBack.path,
          filename: backFileName,
        ),
      });

      final response = await _dio.post(
        ApiConstants.identityBank,
        data: formData,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        appLog("✅ Identity and Bank details submitted successfully");
        return data;
      }

      throw data['message'] ?? 'Failed to save identity and bank details';
    } on DioException catch (e) {
      appLog("❌ Identity & Bank Error: ${e.response?.data}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Identity & Bank General Error: $e");
      if (e is String) rethrow;
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  /// Fetch onboarding registration fee amount
  /// GET /api/restaurant-onboarding/registration-fee
  Future<Map<String, dynamic>> getRegistrationFee() async {
    try {
      final response = await _dio.get(ApiConstants.registrationFee);
      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        appLog("✅ Registration Fee retrieved: ${data['data']}");
        return data['data'] as Map<String, dynamic>? ?? {};
      }
      return {'fee': 500, 'currency': 'INR'};
    } on DioException catch (e) {
      appLog("❌ Registration Fee Error: ${e.response?.data}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Registration Fee General Error: $e");
      if (e is String) rethrow;
      throw 'Failed to fetch registration fee';
    }
  }

  /// Fetch Razorpay public key ID
  /// GET /api/restaurant-onboarding/razorpay-key
  Future<String> getRazorpayKey() async {
    try {
      final response = await _dio.get(ApiConstants.razorpayKey);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final key = (data['key'] ?? data['data']?['key'])?.toString();
        if (key != null && key.isNotEmpty) {
          appLog("✅ Razorpay Key ID retrieved");
          return key;
        }
      }
      return '';
    } on DioException catch (e) {
      appLog("❌ Razorpay Key Error: ${e.response?.data}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Razorpay Key General Error: $e");
      if (e is String) rethrow;
      throw 'Failed to fetch Razorpay key';
    }
  }

  /// Create Razorpay order for onboarding registration fee
  /// POST /api/restaurant-onboarding/create-order
  Future<Map<String, dynamic>> createOnboardingOrder({num? amount}) async {
    try {
      final response = await _dio.post(
        ApiConstants.onboardingCreateOrder,
        data: amount != null ? {'amount': amount} : {},
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        appLog("✅ Onboarding Order Created: orderId=${data['orderId']}");
        return data;
      }

      throw data['message'] ?? 'Failed to create order';
    } on DioException catch (e) {
      appLog("❌ Create Order Error: ${e.response?.data}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Create Order General Error: $e");
      if (e is String) rethrow;
      throw 'An unexpected error occurred while creating order';
    }
  }

  /// Verify Razorpay onboarding payment signature
  /// POST /api/restaurant-onboarding/verify-payment
  Future<Map<String, dynamic>> verifyOnboardingPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.onboardingVerifyPayment,
        data: {
          'razorpay_order_id': orderId,
          'razorpay_payment_id': paymentId,
          'razorpay_signature': signature,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        appLog("✅ Onboarding Payment Verified successfully");
        return data;
      }

      throw data['message'] ?? 'Payment verification failed';
    } on DioException catch (e) {
      appLog("❌ Verify Payment Error: ${e.response?.data}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Verify Payment General Error: $e");
      if (e is String) rethrow;
      throw 'An unexpected error occurred while verifying payment';
    }
  }

  /// Submit restaurant onboarding application for admin review
  /// POST /api/restaurant-onboarding/submit
  Future<Map<String, dynamic>> submitOnboardingApplication() async {
    try {
      final response = await _dio.post(ApiConstants.onboardingSubmit);
      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        appLog("✅ Onboarding Application submitted successfully: ${data['data']}");
        return data;
      }
      throw data['message'] ?? 'Failed to submit onboarding application';
    } on DioException catch (e) {
      appLog("❌ Submit Application Error: ${e.response?.data}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Submit Application General Error: $e");
      if (e is String) rethrow;
      throw 'An unexpected error occurred while submitting application';
    }
  }

  /// Upload Kitchen Hygiene proof (main prep station, storage, dishwashing)
  /// POST /api/restaurant-onboarding/kitchen-hygiene
  Future<Map<String, dynamic>> uploadKitchenHygiene({
    required File mainPrepStation,
    File? storageAndFridge,
    File? dishwashingArea,
  }) async {
    try {
      final mainFileName = mainPrepStation.path.split(Platform.pathSeparator).last;
      final formData = FormData.fromMap({
        'mainPrepStation': await MultipartFile.fromFile(
          mainPrepStation.path,
          filename: mainFileName,
        ),
        if (storageAndFridge != null)
          'storageAndFridge': await MultipartFile.fromFile(
            storageAndFridge.path,
            filename: storageAndFridge.path.split(Platform.pathSeparator).last,
          ),
        if (dishwashingArea != null)
          'dishwashingArea': await MultipartFile.fromFile(
            dishwashingArea.path,
            filename: dishwashingArea.path.split(Platform.pathSeparator).last,
          ),
      });

      final response = await _dio.post(
        ApiConstants.kitchenHygiene,
        data: formData,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        appLog("✅ Kitchen Hygiene proof uploaded successfully");
        return data;
      }
      throw data['message'] ?? 'Failed to upload kitchen hygiene proof';
    } on DioException catch (e) {
      appLog("❌ Kitchen Hygiene Error: ${e.response?.data}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Kitchen Hygiene General Error: $e");
      if (e is String) rethrow;
      throw 'An unexpected error occurred while uploading kitchen hygiene';
    }
  }

  /// Public Auth Fallback: Create Razorpay order
  /// POST /api/restaurant-auth/create-order
  Future<Map<String, dynamic>> authCreateOrder({num? amount}) async {
    try {
      final response = await _dio.post(
        ApiConstants.authCreateOrder,
        data: amount != null ? {'amount': amount} : {},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        appLog("✅ Auth Public Order Created: $data");
        return data;
      }
      throw 'Failed to create auth order';
    } on DioException catch (e) {
      appLog("❌ Auth Create Order Error: ${e.response?.data}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Auth Create Order General Error: $e");
      if (e is String) rethrow;
      throw 'An unexpected error occurred while creating order';
    }
  }

  /// Public Auth Fallback: Verify Razorpay payment signature
  /// POST /api/restaurant-auth/verify-payment
  Future<Map<String, dynamic>> authVerifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.authVerifyPayment,
        data: {
          'razorpay_order_id': orderId,
          'razorpay_payment_id': paymentId,
          'razorpay_signature': signature,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic> &&
          (data['success'] == true || data['isDemo'] == true)) {
        appLog("✅ Auth Public Payment Verified: $data");
        return data;
      }
      throw data['message'] ?? 'Payment verification failed';
    } on DioException catch (e) {
      appLog("❌ Auth Verify Payment Error: ${e.response?.data}");
      throw NetworkExceptions.getErrorMessage(e);
    } catch (e) {
      appLog("❌ Auth Verify Payment General Error: $e");
      if (e is String) rethrow;
      throw 'An unexpected error occurred while verifying payment';
    }
  }
}
