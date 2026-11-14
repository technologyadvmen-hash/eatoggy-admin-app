import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../features/splash/presentation/pages/splash_screen.dart';
import '../../../features/auth/presentation/pages/login_screen.dart';
import '../../../features/auth/presentation/pages/otp_screen.dart';
import '../../../features/auth/presentation/pages/register_screen.dart';
import '../../../features/auth/presentation/pages/business_profile_screen.dart';
import '../../../features/auth/presentation/pages/verify_documents_screen.dart';
import '../../../features/auth/presentation/pages/identity_bank_screen.dart';
import '../../../features/auth/presentation/pages/review_application_screen.dart';
import '../../../features/auth/presentation/pages/application_submitted_screen.dart';
import '../../../features/dashboard/presentation/pages/main_shell_screen.dart';
import '../../../features/orders/presentation/pages/order_detail_screen.dart';
import '../../../features/orders/presentation/pages/preparing_order_screen.dart';
import '../../../features/orders/presentation/pages/ready_order_screen.dart';
import '../../../features/orders/presentation/pages/assign_partner_screen.dart';
import '../../../features/orders/presentation/pages/handover_order_screen.dart';
import '../../../features/notifications/presentation/pages/notifications_screen.dart';
import '../../../features/menu/presentation/pages/category_items_screen.dart';
import '../../../features/subscriptions/presentation/pages/subscriptions_plans_screen.dart';
import '../../../features/subscriptions/presentation/pages/create_tiffin_plan_screen.dart';
import '../../../features/subscriptions/presentation/pages/manage_tiffin_plan_screen.dart';
import '../../../features/subscriptions/presentation/pages/tiffin_deliveries_screen.dart';
import '../../../features/subscriptions/presentation/pages/subscriber_card_screen.dart';
import '../../../features/subscriptions/data/models/tiffin_deliveries_model.dart';
import '../../../features/menu/presentation/pages/add_menu_item_screen.dart';
import '../../../features/menu/presentation/pages/add_category_screen.dart';
import '../../../features/menu/data/models/category_items_model.dart';
import '../../../features/menu/data/models/menu_management_model.dart';
import '../../../features/profile/presentation/pages/ratings_and_reviews_screen.dart';
import '../../../features/profile/data/models/ratings_and_reviews_model.dart';
import '../../../features/profile/presentation/pages/customer_reviews_screen.dart';
import '../../../features/profile/data/models/customer_reviews_model.dart';
import '../../../features/profile/presentation/pages/respond_to_review_screen.dart';
import '../../../features/profile/data/models/respond_to_review_model.dart';
import '../../../features/profile/presentation/pages/revenue_earnings_screen.dart';
import '../../../features/profile/presentation/pages/transactions_screen.dart';
import '../../../features/profile/presentation/pages/kitchen_profile_screen.dart';
import '../../../features/profile/presentation/pages/edit_profile_screen.dart';
import '../../../features/profile/presentation/pages/help_support_screen.dart';
import '../../../features/profile/presentation/pages/settings_screen.dart';
import '../../../features/profile/presentation/pages/bank_account_details_screen.dart';
import '../../../features/profile/presentation/pages/tax_information_screen.dart';
import '../../../features/profile/presentation/pages/thermal_printer_screen.dart';
import '../../../features/kitchen/presentation/pages/kitchen_hygiene_screen.dart';
import '../constants/app_keys.dart';
import '../services/storage_service.dart';

/// Route name constants — use these instead of raw strings.
abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const otp = '/otp';
  static const register = '/register';
  static const businessProfile = '/business-profile';
  static const verifyDocuments = '/verify-documents';
  static const identityBank = '/identity-bank';
  static const reviewApplication = '/review-application';
  static const applicationSubmitted = '/application-submitted';
  static const dashboard = '/dashboard';
  static const orderDetail = '/order-detail';
  static const preparingOrder = '/preparing-order';
  static const readyOrder = '/ready-order';
  static const assignPartner = '/assign-partner';
  static const handoverOrder = '/handover-order';
  static const notifications = '/notifications';
  static const categoryItems = '/category-items';
  static const subscriptionPlans = '/subscription-plans';
  static const createTiffinPlan = '/create-tiffin-plan';
  static const manageTiffinPlan = '/manage-tiffin-plan';
  static const tiffinDeliveries = '/tiffin-deliveries';
  static const addMenuItem = '/add-menu-item';
  static const addCategory = '/add-category';
  static const subscriberCard = '/subscriber-card';
  static const ratingsAndReviews = '/ratings-and-reviews';
  static const customerReviews = '/customer-reviews';
  static const respondToReview = '/respond-to-review';
  static const revenueEarnings = '/revenue-earnings';
  static const transactions = '/transactions';
  static const kitchenProfile = '/kitchen-profile';
  static const editProfile = '/edit-profile';
  static const helpSupport = '/help-support';
  static const settings = '/settings';
  static const bankAccountDetails = '/bank-account-details';
  static const taxInformation = '/tax-information';
  static const thermalPrinter = '/thermal-printer';
  static const kitchenHygiene = '/kitchen-hygiene';
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

CustomTransitionPage<void> _buildSlideFadeTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 360),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slideAnimation = Tween<Offset>(
        begin: const Offset(0.08, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
      );
      final fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      );
      return SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
  );
}

final GoRouter appRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: false,
  redirect: (BuildContext context, GoRouterState state) async {
    final location = state.matchedLocation;

    // Splash screen always allowed so it can show the brand animation and determine route
    if (location == AppRoutes.splash) {
      return null;
    }

    final isPublicRoute = location == AppRoutes.login ||
        location == AppRoutes.otp ||
        location == AppRoutes.register;

    final prefs = await SharedPreferencesService.getInstance();
    final token = prefs.getString(AppKeys.accessToken);
    final isAuthenticated = token != null && token.trim().isNotEmpty;

    // Guard: Prevent unauthenticated users from accessing protected sections
    if (!isAuthenticated && !isPublicRoute) {
      return AppRoutes.login;
    }

    return null;
  },
  routes: [
    // ─── Splash ─────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      pageBuilder: (context, state) => _buildSlideFadeTransition(
        state: state,
        child: const SplashScreen(),
      ),
    ),

    // ─── Auth ────────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      pageBuilder: (context, state) => _buildSlideFadeTransition(
        state: state,
        child: const LoginScreen(),
      ),
    ),

    GoRoute(
      path: AppRoutes.otp,
      name: 'otp',
      pageBuilder: (context, state) {
        Widget child;
        if (state.extra is Map<String, dynamic>) {
          final map = state.extra as Map<String, dynamic>;
          final phone = map['phone'] as String? ?? '';
          final testOtp = map['testOtp'] as String?;
          child = OtpScreen(phoneNumber: phone, testOtp: testOtp);
        } else {
          final phone = state.extra as String? ?? '';
          child = OtpScreen(phoneNumber: phone);
        }
        return _buildSlideFadeTransition(
          state: state,
          child: child,
        );
      },
    ),

    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      pageBuilder: (context, state) => _buildSlideFadeTransition(
        state: state,
        child: const RegisterScreen(),
      ),
    ),

    GoRoute(
      path: AppRoutes.businessProfile,
      name: 'businessProfile',
      builder: (context, state) => const BusinessProfileScreen(),
    ),

    GoRoute(
      path: AppRoutes.verifyDocuments,
      name: 'verifyDocuments',
      builder: (context, state) => const VerifyDocumentsScreen(),
    ),

    GoRoute(
      path: AppRoutes.identityBank,
      name: 'identityBank',
      builder: (context, state) => const IdentityBankScreen(),
    ),

    GoRoute(
      path: AppRoutes.reviewApplication,
      name: 'reviewApplication',
      builder: (context, state) => const ReviewApplicationScreen(),
    ),

    GoRoute(
      path: AppRoutes.applicationSubmitted,
      name: 'applicationSubmitted',
      builder: (context, state) => const ApplicationSubmittedScreen(),
    ),

    // ─── Dashboard Shell ─────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.dashboard,
      name: 'dashboard',
      builder: (context, state) => const MainShellScreen(),
    ),

    // ─── Order Detail ────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.orderDetail,
      name: 'orderDetail',
      builder: (context, state) {
        final orderId = state.extra as String? ?? '';
        return OrderDetailScreen(orderId: orderId);
      },
    ),

    // ─── Preparing Order ─────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.preparingOrder,
      name: 'preparingOrder',
      builder: (context, state) {
        final orderId = state.extra as String? ?? '';
        return PreparingOrderScreen(orderId: orderId);
      },
    ),

    // ─── Ready Order ─────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.readyOrder,
      name: 'readyOrder',
      builder: (context, state) {
        final orderId = state.extra as String? ?? '';
        return ReadyOrderScreen(orderId: orderId);
      },
    ),

    // ─── Assign Partner ──────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.assignPartner,
      name: 'assignPartner',
      builder: (context, state) {
        final orderId = state.extra as String? ?? '';
        return AssignPartnerScreen(orderId: orderId);
      },
    ),

    // ─── Handover Order ──────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.handoverOrder,
      name: 'handoverOrder',
      builder: (context, state) {
        final orderId = state.extra as String? ?? '';
        return HandoverOrderScreen(orderId: orderId);
      },
    ),

    // ─── Notifications ──────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.notifications,
      name: 'notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),

    // ─── Category Items ─────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.categoryItems,
      name: 'categoryItems',
      builder: (context, state) {
        final categoryId = state.extra as String? ?? '1';
        return CategoryItemsScreen(categoryId: categoryId);
      },
    ),

    // ─── Subscription Plans ──────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.subscriptionPlans,
      name: 'subscriptionPlans',
      builder: (context, state) => const SubscriptionsPlansScreen(),
    ),

    // ─── Create Tiffin Plan ───────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.createTiffinPlan,
      name: 'createTiffinPlan',
      builder: (context, state) => const CreateTiffinPlanScreen(),
    ),

    // ─── Manage Tiffin Plan ───────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.manageTiffinPlan,
      name: 'manageTiffinPlan',
      builder: (context, state) {
        final programId = state.extra as String? ?? '1';
        return ManageTiffinPlanScreen(programId: programId);
      },
    ),

    // ─── Tiffin Deliveries ────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.tiffinDeliveries,
      name: 'tiffinDeliveries',
      builder: (context, state) => const TiffinDeliveriesScreen(),
    ),

    // ─── Add Menu Item ───────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.addMenuItem,
      name: 'addMenuItem',
      builder: (context, state) {
        final extra = state.extra;
        final bool isEdit = extra is bool ? extra : (extra != null);
        return AddMenuItemScreen(isEdit: isEdit, editItem: extra is CategoryFoodItem ? extra : null);
      },
    ),

    // ─── Add / Edit Category ──────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.addCategory,
      name: 'addCategory',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is MenuCategoryItem) {
          return AddCategoryScreen(isEdit: true, category: extra);
        } else if (extra is String) {
          return AddCategoryScreen(isEdit: true, categoryName: extra);
        } else if (extra is bool) {
          return AddCategoryScreen(isEdit: extra);
        }
        return const AddCategoryScreen(isEdit: false);
      },
    ),

    // ─── Subscriber Card ─────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.subscriberCard,
      name: 'subscriberCard',
      builder: (context, state) {
        final item = state.extra as DeliveryMealItem;
        return SubscriberCardScreen(item: item);
      },
    ),

    GoRoute(
      path: AppRoutes.ratingsAndReviews,
      name: 'ratingsAndReviews',
      builder: (context, state) {
        final data = state.extra as RatingsAndReviewsModel?;
        return RatingsAndReviewsScreen(initialData: data);
      },
    ),

    // ─── Customer Reviews ────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.customerReviews,
      name: 'customerReviews',
      builder: (context, state) {
        final data = state.extra as CustomerReviewsListModel?;
        return CustomerReviewsScreen(initialModel: data);
      },
    ),

    // ─── Respond To Review ───────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.respondToReview,
      name: 'respondToReview',
      builder: (context, state) {
        final review = state.extra as CustomerReviewModel? ??
            RespondToReviewModel.dummy.review;
        return RespondToReviewScreen(review: review);
      },
    ),

    // ─── Revenue & Earnings ──────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.revenueEarnings,
      name: 'revenueEarnings',
      builder: (context, state) => const RevenueEarningsScreen(),
    ),

    // ─── Transactions ────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.transactions,
      name: 'transactions',
      builder: (context, state) => const TransactionsScreen(),
    ),

    // ─── Kitchen Profile ─────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.kitchenProfile,
      name: 'kitchenProfile',
      builder: (context, state) => const KitchenProfileScreen(),
    ),

    // ─── Edit Profile ────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.editProfile,
      name: 'editProfile',
      builder: (context, state) => const EditProfileScreen(),
    ),

    // ─── Help & Support ──────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.helpSupport,
      name: 'helpSupport',
      builder: (context, state) => const HelpSupportScreen(),
    ),

    // ─── Settings ────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),

    // ─── Bank Account Details ────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.bankAccountDetails,
      name: 'bankAccountDetails',
      builder: (context, state) => const BankAccountDetailsScreen(),
    ),

    // ─── Tax Information ─────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.taxInformation,
      name: 'taxInformation',
      builder: (context, state) => const TaxInformationScreen(),
    ),

    // ─── Thermal Printer ─────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.thermalPrinter,
      name: 'thermalPrinter',
      builder: (context, state) => const ThermalPrinterScreen(),
    ),

    // ─── Kitchen Hygiene Proof ───────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.kitchenHygiene,
      name: 'kitchenHygiene',
      builder: (context, state) => const KitchenHygieneScreen(),
    ),
  ],

  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        'Page not found\n${state.error}',
        textAlign: TextAlign.center,
      ),
    ),
  ),
);
