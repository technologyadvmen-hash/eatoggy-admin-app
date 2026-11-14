import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_keys.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/models/application_submitted_model.dart';

class ApplicationSubmittedState {
  const ApplicationSubmittedState({
    required this.data,
    this.status = 'PENDING_REVIEW',
  });

  final ApplicationSubmittedModel data;
  final String status;

  ApplicationSubmittedState copyWith({
    ApplicationSubmittedModel? data,
    String? status,
  }) {
    return ApplicationSubmittedState(
      data: data ?? this.data,
      status: status ?? this.status,
    );
  }
}

class ApplicationSubmittedNotifier
    extends Notifier<ApplicationSubmittedState> {
  @override
  ApplicationSubmittedState build() {
    _loadPartnerInfo();
    return const ApplicationSubmittedState(
      data: ApplicationSubmittedModel.dummy,
    );
  }

  Future<void> _loadPartnerInfo() async {
    try {
      final prefs = await SharedPreferencesService.getInstance();
      final userJson = prefs.getString(AppKeys.user);

      if (userJson != null && userJson.isNotEmpty) {
        final user = jsonDecode(userJson) as Map<String, dynamic>;
        final id = user['id']?.toString() ?? '';
        final resName = user['restaurantName']?.toString() ?? '';
        final status = user['onboardingStatus']?.toString() ?? 'PENDING_REVIEW';

        String appId = state.data.applicationIdValue;
        if (id.isNotEmpty) {
          final suffix = id.length >= 6 ? id.substring(id.length - 6).toUpperCase() : id.toUpperCase();
          appId = 'EAT-$suffix';
        }

        String sub = state.data.subtitle;
        if (resName.isNotEmpty) {
          sub = 'Your application for $resName is under review.';
        }

        state = state.copyWith(
          status: status,
          data: state.data.copyWith(
            applicationIdValue: appId,
            subtitle: sub,
          ),
        );
      }
    } catch (_) {}
  }
}

final applicationSubmittedProvider = NotifierProvider<
    ApplicationSubmittedNotifier, ApplicationSubmittedState>(
  ApplicationSubmittedNotifier.new,
);

