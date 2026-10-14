import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/device_token_service.dart';
import '../../data/models/otp_model.dart';
import '../../data/repositories/auth_repository.dart';

/// State representation for OTP verification screen.
class OtpState {
  const OtpState({
    required this.data,
    this.phoneNumber = '',
    required this.digits,
    this.timerSeconds = 30,
    this.isLoading = false,
    this.errorMessage,
    this.testOtp,
  });

  final OtpModel data;
  final String phoneNumber;
  final List<String> digits;
  final int timerSeconds;
  final bool isLoading;
  final String? errorMessage;
  final String? testOtp;

  /// Full concatenated OTP code string.
  String get otpCode => digits.join();

  /// True when all digits are filled.
  bool get isComplete =>
      digits.length == data.otpLength &&
      digits.every((digit) => digit.isNotEmpty);

  /// True when resend countdown reaches zero.
  bool get canResend => timerSeconds == 0;

  OtpState copyWith({
    OtpModel? data,
    String? phoneNumber,
    List<String>? digits,
    int? timerSeconds,
    bool? isLoading,
    String? errorMessage,
    String? testOtp,
  }) {
    return OtpState(
      data: data ?? this.data,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      digits: digits ?? this.digits,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      testOtp: testOtp ?? this.testOtp,
    );
  }
}

/// Riverpod Notifier for managing OTP verification lifecycle, timer, and validation.
class OtpNotifier extends Notifier<OtpState> {
  final AuthRepository _authRepository = AuthRepository();
  Timer? _timer;

  @override
  OtpState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });

    const defaultModel = OtpModel.dummy;
    return const OtpState(
      data: defaultModel,
      phoneNumber: '',
      digits: ['', '', '', '', '', ''],
      timerSeconds: 30,
    );
  }

  /// Initialize OTP state with passed phone number and start resend countdown.
  void init(String phone, {String? testOtp}) {
    _timer?.cancel();
    final cleanPhone = phone.trim();

    List<String> initialDigits = const ['', '', '', '', '', ''];
    if (testOtp != null && testOtp.length == 6) {
      initialDigits = testOtp.split('');
    }

    state = state.copyWith(
      phoneNumber: cleanPhone,
      digits: initialDigits,
      timerSeconds: 30,
      isLoading: false,
      errorMessage: null,
      testOtp: testOtp,
    );

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timerSeconds <= 1) {
        timer.cancel();
        state = state.copyWith(timerSeconds: 0);
      } else {
        state = state.copyWith(timerSeconds: state.timerSeconds - 1);
      }
    });
  }

  /// Autofills the test OTP into the input boxes.
  void fillTestOtp() {
    if (state.testOtp != null && state.testOtp!.length == 6) {
      state = state.copyWith(
        digits: state.testOtp!.split(''),
        errorMessage: null,
      );
    }
  }

  /// Updates single digit at specified index.
  void updateDigit(int index, String digit) {
    if (index < 0 || index >= state.digits.length) return;
    final newDigits = List<String>.from(state.digits);
    newDigits[index] = digit;
    state = state.copyWith(digits: newDigits, errorMessage: null);
  }

  /// Clears digit at specified index.
  void clearDigit(int index) {
    if (index < 0 || index >= state.digits.length) return;
    final newDigits = List<String>.from(state.digits);
    newDigits[index] = '';
    state = state.copyWith(digits: newDigits, errorMessage: null);
  }

  /// Resends OTP and resets timer via live backend API.
  Future<void> resendOtp({
    required VoidCallback onSuccess,
    required ValueChanged<String> onError,
  }) async {
    if (!state.canResend) return;

    try {
      final res = await _authRepository.resendOtp(mobile: state.phoneNumber);
      final newTestOtp = (res['otp'] ?? res['testOtp'])?.toString();

      state = state.copyWith(
        digits: const ['', '', '', '', '', ''],
        timerSeconds: 30,
        errorMessage: null,
        testOtp: newTestOtp ?? state.testOtp,
      );
      _startTimer();
      onSuccess();
    } catch (e) {
      final msg = e.toString();
      state = state.copyWith(errorMessage: msg);
      onError(msg);
    }
  }

  /// Verifies entered OTP code via live backend API.
  Future<bool> verifyOtp({
    required void Function(Map<String, dynamic> responseData) onSuccess,
    required ValueChanged<String> onError,
  }) async {
    if (!state.isComplete) {
      const msg = 'Please enter complete 6-digit OTP';
      state = state.copyWith(errorMessage: msg);
      onError(msg);
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final res = await _authRepository.verifyOtp(
        mobile: state.phoneNumber,
        otp: state.otpCode,
      );

      // Register device token in background
      unawaited(DeviceTokenService().registerDeviceToken());

      state = state.copyWith(isLoading: false);
      onSuccess(res);
      return true;
    } catch (e) {
      final errorMsg = e.toString();
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      onError(errorMsg);
      return false;
    }
  }
}

/// Provider for OTP Verification state management.
final otpProvider = NotifierProvider<OtpNotifier, OtpState>(
  OtpNotifier.new,
);
