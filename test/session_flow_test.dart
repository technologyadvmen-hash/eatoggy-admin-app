import 'package:flutter_test/flutter_test.dart';
import 'package:restrorent_partner_app/core/router/app_router.dart';
import 'package:restrorent_partner_app/core/utils/session_manager.dart';

void main() {
  group('SessionManager Flow Resolution Tests', () {
    test('Null user maps to Login screen', () {
      final route = SessionManager.resolveDestination(null);
      expect(route, AppRoutes.login);
    });

    test('Empty user map maps to Login screen', () {
      final route = SessionManager.resolveDestination({});
      expect(route, AppRoutes.login);
    });

    test('Approved partner maps directly to Dashboard', () {
      final route = SessionManager.resolveDestination({
        'onboardingStatus': 'APPROVED',
      });
      expect(route, AppRoutes.dashboard);
    });

    test('Pending review maps to Application Submitted screen', () {
      final route1 = SessionManager.resolveDestination({
        'onboardingStatus': 'PENDING_REVIEW',
      });
      expect(route1, AppRoutes.applicationSubmitted);

      final route2 = SessionManager.resolveDestination({
        'currentStep': 'PENDING_REVIEW',
      });
      expect(route2, AppRoutes.applicationSubmitted);

      final route3 = SessionManager.resolveDestination({
        'currentStep': 'COMPLETED',
      });
      expect(route3, AppRoutes.applicationSubmitted);
    });

    test('Step BUSINESS_DOCS maps to Verify Documents screen', () {
      final route = SessionManager.resolveDestination({
        'currentStep': 'BUSINESS_DOCS',
      });
      expect(route, AppRoutes.verifyDocuments);
    });

    test('Step IDENTITY_BANK maps to Identity Bank screen', () {
      final route = SessionManager.resolveDestination({
        'currentStep': 'IDENTITY_BANK',
      });
      expect(route, AppRoutes.identityBank);
    });

    test('Step KITCHEN_HYGIENE maps to Review Application screen', () {
      final route = SessionManager.resolveDestination({
        'currentStep': 'KITCHEN_HYGIENE',
      });
      expect(route, AppRoutes.reviewApplication);
    });

    test('New partner without approved status maps to Business Profile step 1', () {
      final route = SessionManager.resolveDestination({
        'id': '654321',
        'phone': '9999999999',
      });
      expect(route, AppRoutes.businessProfile);
    });
  });
}
