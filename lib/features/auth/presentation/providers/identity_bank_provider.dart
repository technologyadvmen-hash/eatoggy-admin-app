import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_keys.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/models/identity_bank_model.dart';
import '../../data/repositories/auth_repository.dart';

class IdentityBankState {
  const IdentityBankState({
    required this.data,
    this.aadhaarFrontPath,
    this.isAadhaarFrontUploaded = false,
    this.aadhaarBackPath,
    this.isAadhaarBackUploaded = false,
    this.accountHolderName = '',
    this.accountNumber = '',
    this.ifscCode = '',
    this.bankName = '',
    this.isLoading = false,
    this.errorMessage,
  });

  final IdentityBankModel data;
  final String? aadhaarFrontPath;
  final bool isAadhaarFrontUploaded;
  final String? aadhaarBackPath;
  final bool isAadhaarBackUploaded;
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String bankName;
  final bool isLoading;
  final String? errorMessage;

  /// Backwards-compatibility getter
  String? get aadhaarPath => aadhaarFrontPath;
  bool get isAadhaarUploaded => isAadhaarFrontUploaded && isAadhaarBackUploaded;

  IdentityBankState copyWith({
    IdentityBankModel? data,
    String? aadhaarFrontPath,
    bool? isAadhaarFrontUploaded,
    String? aadhaarBackPath,
    bool? isAadhaarBackUploaded,
    String? accountHolderName,
    String? accountNumber,
    String? ifscCode,
    String? bankName,
    bool? isLoading,
    String? errorMessage,
  }) {
    return IdentityBankState(
      data: data ?? this.data,
      aadhaarFrontPath: aadhaarFrontPath ?? this.aadhaarFrontPath,
      isAadhaarFrontUploaded:
          isAadhaarFrontUploaded ?? this.isAadhaarFrontUploaded,
      aadhaarBackPath: aadhaarBackPath ?? this.aadhaarBackPath,
      isAadhaarBackUploaded:
          isAadhaarBackUploaded ?? this.isAadhaarBackUploaded,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      bankName: bankName ?? this.bankName,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class IdentityBankNotifier extends Notifier<IdentityBankState> {
  final ImagePicker _picker = ImagePicker();
  final AuthRepository _authRepository = AuthRepository();

  @override
  IdentityBankState build() {
    _loadStoredUserData();
    return const IdentityBankState(
      data: IdentityBankModel.dummy,
      accountHolderName: '',
      accountNumber: '',
      ifscCode: '',
      bankName: '',
    );
  }

  Future<void> _loadStoredUserData() async {
    try {
      final prefs = await SharedPreferencesService.getInstance();
      final userJson = prefs.getString(AppKeys.user);
      if (userJson != null && userJson.isNotEmpty) {
        final user = jsonDecode(userJson) as Map<String, dynamic>;
        final owner = (user['ownerName'] ?? '').toString();
        if (owner.isNotEmpty && state.accountHolderName.isEmpty) {
          state = state.copyWith(accountHolderName: owner);
        }
      }
    } catch (_) {}
  }

  Future<void> pickAadhaarFront(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null) {
        state = state.copyWith(
          aadhaarFrontPath: image.path,
          isAadhaarFrontUploaded: true,
          errorMessage: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to pick image: ${e.toString()}',
      );
    }
  }

  Future<void> pickAadhaarBack(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null) {
        state = state.copyWith(
          aadhaarBackPath: image.path,
          isAadhaarBackUploaded: true,
          errorMessage: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to pick image: ${e.toString()}',
      );
    }
  }

  /// Legacy support
  Future<void> pickAadhaar(ImageSource source) => pickAadhaarFront(source);

  void updateAccountHolderName(String value) {
    state = state.copyWith(accountHolderName: value, errorMessage: null);
  }

  void updateAccountNumber(String value) {
    state = state.copyWith(accountNumber: value, errorMessage: null);
  }

  void updateIfscCode(String value) {
    state = state.copyWith(ifscCode: value, errorMessage: null);
  }

  void updateBankName(String value) {
    state = state.copyWith(bankName: value, errorMessage: null);
  }

  Future<bool> submitIdentityBank({
    required VoidCallback onSuccess,
    required ValueChanged<String> onError,
  }) async {
    if (state.aadhaarFrontPath == null ||
        !File(state.aadhaarFrontPath!).existsSync()) {
      const msg = 'Please upload Aadhaar Card (Front Side)';
      state = state.copyWith(errorMessage: msg);
      onError(msg);
      return false;
    }

    if (state.aadhaarBackPath == null ||
        !File(state.aadhaarBackPath!).existsSync()) {
      const msg = 'Please upload Aadhaar Card (Back Side)';
      state = state.copyWith(errorMessage: msg);
      onError(msg);
      return false;
    }

    if (state.accountHolderName.trim().isEmpty) {
      const msg = 'Please enter account holder name';
      state = state.copyWith(errorMessage: msg);
      onError(msg);
      return false;
    }

    final cleanAccount = state.accountNumber.trim();
    if (cleanAccount.isEmpty || cleanAccount.length < 8) {
      const msg = 'Please enter a valid bank account number (min 8 digits)';
      state = state.copyWith(errorMessage: msg);
      onError(msg);
      return false;
    }

    final cleanIfsc = state.ifscCode.trim();
    if (cleanIfsc.isEmpty || cleanIfsc.length != 11) {
      const msg = 'Please enter a valid 11-character IFSC code';
      state = state.copyWith(errorMessage: msg);
      onError(msg);
      return false;
    }

    if (state.bankName.trim().isEmpty) {
      const msg = 'Please enter bank name';
      state = state.copyWith(errorMessage: msg);
      onError(msg);
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authRepository.submitIdentityAndBank(
        accountHolderName: state.accountHolderName.trim(),
        accountNumber: cleanAccount,
        ifscCode: cleanIfsc.toUpperCase(),
        bankName: state.bankName.trim(),
        aadhaarFront: File(state.aadhaarFrontPath!),
        aadhaarBack: File(state.aadhaarBackPath!),
      );

      state = state.copyWith(isLoading: false);
      onSuccess();
      return true;
    } catch (e) {
      final errorMsg = e.toString();
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
      onError(errorMsg);
      return false;
    }
  }
}

final identityBankProvider =
    NotifierProvider<IdentityBankNotifier, IdentityBankState>(
  IdentityBankNotifier.new,
);
