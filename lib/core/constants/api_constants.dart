class ApiConstants {
  // Base URLs
  static const String serverUrl = "https://api.eatoggy.in";
  static const String baseUrl = "$serverUrl/api";

  // ================= 1. Auth & Onboarding =================
  static const String sendOtp = "$baseUrl/restaurant-auth/send-otp";
  static const String resendOtp = "$baseUrl/restaurant-auth/resend-otp";
  static const String verifyOtp = "$baseUrl/restaurant-auth/verify-otp";
  static const String authCreateOrder = "$baseUrl/restaurant-auth/create-order";
  static const String authVerifyPayment = "$baseUrl/restaurant-auth/verify-payment";

  static const String businessDetails = "$baseUrl/restaurant-onboarding/business-details";
  static const String businessDocs = "$baseUrl/restaurant-onboarding/business-docs";
  static const String identityBank = "$baseUrl/restaurant-onboarding/identity-bank";
  static const String kitchenHygiene = "$baseUrl/restaurant-onboarding/kitchen-hygiene";
  static const String registrationFee = "$baseUrl/restaurant-onboarding/registration-fee";
  static const String razorpayKey = "$baseUrl/restaurant-onboarding/razorpay-key";
  static const String onboardingCreateOrder = "$baseUrl/restaurant-onboarding/create-order";
  static const String onboardingVerifyPayment = "$baseUrl/restaurant-onboarding/verify-payment";
  static const String onboardingSubmit = "$baseUrl/restaurant-onboarding/submit";

  // Profile & Operational Status
  static const String myProfile = "$baseUrl/restaurants/me";
  static const String toggleOnlineStatus = "$baseUrl/restaurants/status/toggle-online";
  static const String restaurantProfile = "$baseUrl/restaurants/profile";
  static const String restaurantDashboard = "$baseUrl/restaurants/dashboard";

  // ================= 2. Kitchen & Orders =================
  static const String kitchenOrders = "$baseUrl/restaurants/kitchen/orders";
  static String updateOrderStatus(String orderId) => "$baseUrl/restaurants/kitchen/orders/$orderId/status";
  static const String ordersHistory = "$baseUrl/restaurants/orders/history";
  static String orderDetails(String orderId) => "$baseUrl/restaurants/orders/$orderId";
  static String acceptOrder(String orderId) => "$baseUrl/restaurants/orders/$orderId/accept";
  static String rejectOrder(String orderId) => "$baseUrl/restaurants/orders/$orderId/reject";
  static String handoverOrder(String orderId) => "$baseUrl/restaurants/orders/$orderId/handover";

  // ================= 3. Menu Management =================
  static const String menuCategories = "$baseUrl/restaurants/menu/categories";
  static String categoryItems(String categoryId) => "$baseUrl/restaurants/menu/categories/$categoryId/items";
  static const String menuItems = "$baseUrl/restaurants/menu/items";
  static String menuItemDetail(String itemId) => "$baseUrl/restaurants/menu/items/$itemId";
  static String toggleItemStock(String itemId) => "$baseUrl/restaurants/menu/items/$itemId/toggle-stock";

  // ================= 4. Subscriptions & Tiffin Plans =================
  static const String tiffinPlans = "$baseUrl/restaurants/tiffin-plans";
  static String tiffinPlanDetail(String planId) => "$baseUrl/restaurants/tiffin-plans/$planId";
  static const String todayTiffinDeliveries = "$baseUrl/restaurants/tiffin-plans/deliveries/today";

  // ================= 5. Earnings, Wallet & Analytics =================
  static const String earnings = "$baseUrl/restaurants/earnings";
  static const String wallet = "$baseUrl/restaurants/wallet";
  static const String walletTransactions = "$baseUrl/restaurants/wallet/transactions";
  static const String analyticsOverview = "$baseUrl/restaurants/analytics/overview";
  static const String walletWithdraw = "$baseUrl/restaurants/wallet/withdraw";

  // ================= 6. Customer Reviews =================
  static const String reviews = "$baseUrl/restaurants/reviews";
  static String replyToReview(String reviewId) => "$baseUrl/restaurants/reviews/$reviewId/reply";

  // ================= 7. Support & Notifications =================
  static const String mySupportTickets = "$baseUrl/support/tickets/restaurant/my";
  static const String createSupportTicket = "$baseUrl/support/tickets";
  static const String notifications = "$baseUrl/restaurants/notifications";
  static const String markNotificationsRead = "$baseUrl/restaurants/notifications/mark-read";
  static const String registerDeviceToken = "$baseUrl/restaurants/notifications/device-token";

  // Legacy compatibility
  static const String refreshToken = "$baseUrl/restaurant-auth/refresh-token";
  static const String geoapifyApiKey = "2ecb147800e2472eab47bbfeaf5d010a";
}