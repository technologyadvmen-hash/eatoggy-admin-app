# Eatoggy Restaurant Partner App - Backend API Specification (Remaining APIs)

> **Base URL**: `https://api.eatoggy.in`  
> **Target Audience**: Backend Engineering Team  
> **Status**: **All 32 Postman APIs Implemented (100%)** | **12 Action Items for Backend Team (1 Bug Fix + 11 Endpoints)**  
> **Date**: October 2026  

---

## 📌 1. Authentication & Common Standards

### 1.1 Bearer Token
All endpoints require the JWT Bearer token obtained from `/api/restaurant-auth/verify-otp`:
```http
Authorization: Bearer <JWT_TOKEN>
```
The backend must extract `restaurantId` from the JWT payload:
```json
{
  "restaurant": { "id": "6ab3cc6f96d118c6b8704eb9", "role": "Restaurant" },
  "user": { "id": "6ab3cc6f96d118c6b8704eb9", "role": "Restaurant" }
}
```

### 1.2 Standard Response Envelopes
**Success Response:**
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {}
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Human-readable error description"
}
```

---

## 🚀 SECTION 1: PRIORITY 1 — HIGH (MVP Core Endpoints)

---

### API 1: Check Authenticated Restaurant Profile & Onboarding Status
* **Screen in Flutter**: `SplashScreen`, App Launch & Auto-login (`lib/features/splash/presentation/pages/splash_screen.dart`)
* **Method**: `GET`
* **Path**: `/api/restaurants/me`
* **Auth**: Required (`Bearer <token>`)

#### Purpose
Used by the Flutter app immediately on splash screen to check if the stored token is valid, and route the partner:
- If `onboardingStatus` is `APPROVED` $\rightarrow$ Open Main Dashboard.
- If `onboardingStatus` is `PENDING_REVIEW` $\rightarrow$ Open Application Submitted Screen.
- If `onboardingStatus` is `PENDING_DETAILS` / `PENDING_DOCS` $\rightarrow$ Resume onboarding flow.

#### Headers
```http
Authorization: Bearer <token>
Accept: application/json
```

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Restaurant profile retrieved successfully",
  "data": {
    "restaurantId": "6ab3cc6f96d118c6b8704eb9",
    "restaurantName": "The Great Kitchen",
    "ownerName": "John Doe",
    "mobile": "9999999999",
    "email": "john@example.com",
    "restaurantType": "Cloud Kitchen",
    "cuisine": "North Indian, Thali",
    "onboardingStatus": "APPROVED",
    "currentStep": "COMPLETED",
    "isOnline": true,
    "operatingHours": {
      "open": "10:00",
      "close": "23:00"
    },
    "fullAddress": "123 Food Street, Cyber City, Gurugram, 122002",
    "logoUrl": "https://api.eatoggy.in/uploads/restaurants/logo.png"
  }
}
```

---

### API 2: Toggle Restaurant Online / Offline Status
* **Screen in Flutter**: `HomeScreen` & `KitchenScreen` (`lib/features/home/pages/home_screen.dart`)
* **Method**: `PATCH`
* **Path**: `/api/restaurants/status/toggle-online`
* **Auth**: Required (`Bearer <token>`)

#### Purpose
Single switch on the app header. When offline, diners cannot place new orders for this restaurant.

#### Request Body (`application/json`)
```json
{
  "isOnline": false,
  "reason": "Kitchen maintenance / ingredients restock"
}
```

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Restaurant is now offline",
  "data": {
    "restaurantId": "6ab3cc6f96d118c6b8704eb9",
    "isOnline": false,
    "offlineSince": "2026-10-01T15:30:00.000Z"
  }
}
```

---

### API 3: Past Orders History
* **Screen in Flutter**: `OrdersScreen` (Past Orders Tab) (`lib/features/orders/presentation/pages/orders_screen.dart`)
* **Method**: `GET`
* **Path**: `/api/restaurants/orders/history`
* **Auth**: Required (`Bearer <token>`)

#### Purpose
Fetches delivered, completed, and cancelled orders with pagination and date filtering.

#### Query Parameters
| Parameter | Type | Required | Default | Description |
| :--- | :---: | :---: | :---: | :--- |
| `page` | `integer` | No | `1` | Page number |
| `limit` | `integer` | No | `20` | Orders per page |
| `status` | `string` | No | `ALL` | Filter: `DELIVERED`, `CANCELLED`, `COMPLETED` |
| `dateFrom` | `string` | No | `null` | ISO date (`YYYY-MM-DD`) |
| `dateTo` | `string` | No | `null` | ISO date (`YYYY-MM-DD`) |

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Past orders retrieved successfully",
  "data": {
    "orders": [
      {
        "_id": "6abda2a4bda84c00216fd4c3",
        "orderNumber": "ORD-20261001-1048",
        "orderStatus": "DELIVERED",
        "items": [
          {
            "foodName": "Paneer Butter Masala",
            "quantity": 2,
            "unitPrice": 220,
            "totalPrice": 440
          },
          {
            "foodName": "Butter Naan",
            "quantity": 4,
            "unitPrice": 35,
            "totalPrice": 140
          }
        ],
        "pricing": {
          "itemSubtotal": 580,
          "packagingFee": 20,
          "tax": 30,
          "grandTotal": 630
        },
        "customer": {
          "name": "Rahul Sharma",
          "mobile": "9876543210"
        },
        "deliveryAddress": {
          "fullAddress": "Flat 402, Sunshine Heights, Sector 62, Noida"
        },
        "deliveredAt": "2026-10-01T14:15:00.000Z",
        "createdAt": "2026-10-01T13:45:00.000Z"
      }
    ],
    "pagination": {
      "totalRecords": 142,
      "page": 1,
      "limit": 20,
      "totalPages": 8
    }
  }
}
```

---

### API 4: Single Order Full Details
* **Screen in Flutter**: `OrderDetailScreen` (`lib/features/orders/presentation/pages/order_detail_screen.dart`)
* **Method**: `GET`
* **Path**: `/api/restaurants/orders/:orderId`
* **Auth**: Required (`Bearer <token>`)

#### Purpose
Fetches full line-item customization, special cooking instructions, customer address, delivery rider status, and live timeline.

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Order details retrieved successfully",
  "data": {
    "_id": "6abda2a4bda84c00216fd4c3",
    "orderNumber": "ORD-20261001-1048",
    "orderStatus": "PREPARING",
    "prepTimeEstimatedMinutes": 20,
    "specialInstructions": "Please make less spicy. Send extra green mint chutney.",
    "items": [
      {
        "menuItemId": "6abba001b589c5998f050b85",
        "foodName": "Paneer Butter Masala",
        "quantity": 2,
        "portion": "Full",
        "unitPrice": 220,
        "addons": [{ "title": "Extra Butter", "price": 20 }],
        "itemTotal": 480
      }
    ],
    "pricing": {
      "itemSubtotal": 480,
      "restaurantPackaging": 20,
      "tax": 25,
      "grandTotal": 525
    },
    "customer": {
      "_id": "6aba2d5296d118c6b8704eed",
      "name": "Rahul Sharma",
      "mobile": "9876543210"
    },
    "deliveryAddress": {
      "label": "Home",
      "addressLine1": "Flat 402, Sunshine Heights, Sector 62",
      "city": "Noida",
      "pincode": "201301"
    },
    "statusTimeline": [
      { "status": "PLACED", "time": "2026-10-01T13:40:00.000Z" },
      { "status": "ACCEPTED", "time": "2026-10-01T13:42:00.000Z" },
      { "status": "PREPARING", "time": "2026-10-01T13:45:00.000Z" }
    ],
    "createdAt": "2026-10-01T13:40:00.000Z"
  }
}
```

---

### API 5: Reject Incoming Order
* **Screen in Flutter**: `OrdersScreen` & `OrderDetailScreen`
* **Method**: `POST`
* **Path**: `/api/restaurants/orders/:orderId/reject`
* **Auth**: Required (`Bearer <token>`)

#### Purpose
Used when a partner cannot fulfill an order. Transitions order to `CANCELLED` and triggers automatic customer refund.

#### Request Body (`application/json`)
```json
{
  "reasonCode": "OUT_OF_STOCK",
  "reasonNote": "Paneer is temporarily finished for today"
}
```

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Order has been rejected and refund initiated",
  "data": {
    "orderId": "6abda2a4bda84c00216fd4c3",
    "orderStatus": "CANCELLED",
    "rejectionReason": "Paneer is temporarily finished for today"
  }
}
```

---

### API 6: Restaurant Food Categories List
* **Screen in Flutter**: `MenuScreen` (`lib/features/menu/presentation/pages/menu_screen.dart`)
* **Method**: `GET`
* **Path**: `/api/restaurants/menu/categories`
* **Auth**: Required (`Bearer <token>`)

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Categories retrieved successfully",
  "data": [
    {
      "_id": "6ab_cat_001",
      "title": "North Indian",
      "iconEmoji": "🍲",
      "itemCount": 12,
      "isEnabled": true,
      "displayOrder": 1
    },
    {
      "_id": "6ab_cat_002",
      "title": "Thali Combos",
      "iconEmoji": "🍱",
      "itemCount": 4,
      "isEnabled": true,
      "displayOrder": 2
    }
  ]
}
```

---

### API 7: Create Restaurant Food Category
* **Screen in Flutter**: `AddCategoryScreen` (`lib/features/menu/presentation/pages/add_category_screen.dart`)
* **Method**: `POST`
* **Path**: `/api/restaurants/menu/categories`
* **Auth**: Required (`Bearer <token>`)

#### Request Body (`application/json`)
```json
{
  "title": "Chinese Delights",
  "iconEmoji": "🍜",
  "isEnabled": true,
  "displayOrder": 3
}
```

#### Success Response (`201 Created`)
```json
{
  "success": true,
  "message": "Category created successfully",
  "data": {
    "_id": "6ab_cat_003",
    "restaurantId": "6ab3cc6f96d118c6b8704eb9",
    "title": "Chinese Delights",
    "iconEmoji": "🍜",
    "itemCount": 0,
    "isEnabled": true,
    "displayOrder": 3
  }
}
```

---

### API 8: Category Dishes List
* **Screen in Flutter**: `CategoryItemsScreen` (`lib/features/menu/presentation/pages/category_items_screen.dart`)
* **Method**: `GET`
* **Path**: `/api/restaurants/menu/categories/:categoryId/items`
* **Auth**: Required (`Bearer <token>`)

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Category dishes retrieved successfully",
  "data": {
    "categoryId": "6ab_cat_001",
    "categoryTitle": "North Indian",
    "items": [
      {
        "_id": "6ab_item_101",
        "itemName": "Kadai Paneer",
        "description": "Fresh cottage cheese cooked with onions, tomatoes and bell peppers.",
        "price": 220,
        "isVeg": true,
        "prepTimeMinutes": 15,
        "isAvailableImmediately": true,
        "imageUrl": "https://api.eatoggy.in/uploads/menu/kadai_paneer.jpg",
        "sizeVariants": [
          { "id": "var_1", "title": "Half Portion", "price": 120 },
          { "id": "var_2", "title": "Full Portion", "price": 220 }
        ],
        "addons": [
          { "id": "add_1", "title": "Extra Cheese", "price": 30 }
        ]
      }
    ]
  }
}
```

---

### API 9: Create Menu Item / Dish
* **Screen in Flutter**: `AddMenuItemScreen` (`lib/features/menu/presentation/pages/add_menu_item_screen.dart`)
* **Method**: `POST`
* **Path**: `/api/restaurants/menu/items`
* **Auth**: Required (`Bearer <token>`)
* **Content-Type**: `multipart/form-data` or `application/json`

#### Form Fields / Payload:
| Field | Type | Required | Description |
| :--- | :---: | :---: | :--- |
| `categoryId` | `string` | Yes | 24-char ObjectId of Category |
| `itemName` | `string` | Yes | Dish title (e.g. "Dal Makhani") |
| `description` | `string` | No | Recipe / dish description |
| `price` | `number` | Yes | Base selling price (INR) |
| `isVeg` | `boolean` | Yes | `true` for Veg, `false` for Non-Veg |
| `prepTimeMinutes`| `number` | Yes | Estimated cooking time in minutes |
| `isAvailableImmediately` | `boolean` | No | Default `true` |
| `sizeVariants` | `JSON array`| No | `[{"title": "Half", "price": 120}, {"title": "Full", "price": 220}]` |
| `addons` | `JSON array`| No | `[{"title": "Extra Butter", "price": 20}]` |
| `image` | `file` | No | Image file upload (PNG/JPG) |

#### Success Response (`201 Created`)
```json
{
  "success": true,
  "message": "Menu item created successfully",
  "data": {
    "_id": "6ab_item_102",
    "restaurantId": "6ab3cc6f96d118c6b8704eb9",
    "categoryId": "6ab_cat_001",
    "itemName": "Dal Makhani",
    "price": 180,
    "isVeg": true,
    "prepTimeMinutes": 20,
    "isAvailableImmediately": true,
    "imageUrl": "https://api.eatoggy.in/uploads/menu/dal_makhani.jpg"
  }
}
```

---

### API 10: Edit Menu Item / Dish
* **Screen in Flutter**: `AddMenuItemScreen` (Edit Mode)
* **Method**: `PUT`
* **Path**: `/api/restaurants/menu/items/:itemId`
* **Auth**: Required (`Bearer <token>`)

#### Request Body (`application/json`)
```json
{
  "itemName": "Kadai Paneer (Special)",
  "price": 240,
  "prepTimeMinutes": 18,
  "description": "Updated rich gravy with roasted spices",
  "sizeVariants": [
    { "title": "Half Portion", "price": 130 },
    { "title": "Full Portion", "price": 240 }
  ]
}
```

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Menu item updated successfully",
  "data": {
    "_id": "6ab_item_101",
    "itemName": "Kadai Paneer (Special)",
    "price": 240
  }
}
```

---

### API 11: Toggle Dish In-Stock / Out-of-Stock
* **Screen in Flutter**: `MenuItemCard` (Quick Switch) (`lib/features/menu/presentation/widgets/menu_item_card.dart`)
* **Method**: `PATCH`
* **Path**: `/api/restaurants/menu/items/:itemId/toggle-stock`
* **Auth**: Required (`Bearer <token>`)

#### Request Body (`application/json`)
```json
{
  "isAvailableImmediately": false
}
```

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Dish availability updated",
  "data": {
    "_id": "6ab_item_101",
    "isAvailableImmediately": false
  }
}
```

---

### API 12: Delete Menu Item
* **Screen in Flutter**: `CategoryItemsScreen`
* **Method**: `DELETE`
* **Path**: `/api/restaurants/menu/items/:itemId`
* **Auth**: Required (`Bearer <token>`)

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Menu item deleted successfully"
}
```

---

### API 13: Register FCM Device Token for Push Audio Alerts
* **Screen in Flutter**: Core Notification Service (`lib/core/services/notification_service.dart`)
* **Method**: `POST`
* **Path**: `/api/restaurants/notifications/device-token`
* **Auth**: Required (`Bearer <token>`)

#### Purpose
Stores the partner's device Firebase Cloud Messaging (FCM) token so the backend triggers a high-priority background push notification and loud order bell sound on incoming orders.

#### Request Body (`application/json`)
```json
{
  "fcmToken": "cE3f8xQ_SAMPLE_FCM_TOKEN_xyz123...",
  "devicePlatform": "ANDROID",
  "appVersion": "1.0.0"
}
```

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "FCM device token registered successfully"
}
```

---

## ⚡ SECTION 2: PRIORITY 2 — MEDIUM (Operations & Payouts)

---

### API 14: Handover Order to Delivery Partner (Rider Pickup)
* **Screen in Flutter**: `HandoverOrderScreen` (`lib/features/orders/presentation/pages/handover_order_screen.dart`)
* **Method**: `POST`
* **Path**: `/api/restaurants/orders/:orderId/handover`
* **Auth**: Required (`Bearer <token>`)

#### Request Body (`application/json`)
```json
{
  "handoverCode": "4892",
  "riderId": "6ab9988ffda11234bda12345"
}
```

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Order successfully handed over to delivery partner",
  "data": {
    "orderId": "6abda2a4bda84c00216fd4c3",
    "orderStatus": "DISPATCHED",
    "handedOverAt": "2026-10-01T16:30:00.000Z"
  }
}
```

---

### API 15: Update or Pause Tiffin Plan
* **Screen in Flutter**: `ManageTiffinPlanScreen` (`lib/features/subscriptions/presentation/pages/manage_tiffin_plan_screen.dart`)
* **Method**: `PUT`
* **Path**: `/api/restaurants/tiffin-plans/:planId`
* **Auth**: Required (`Bearer <token>`)

#### Request Body (`application/json`)
```json
{
  "planName": "Deluxe Daily Thali Subscription",
  "pricePerMeal": 160,
  "isActive": true,
  "cutoffTime": "09:30"
}
```

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Tiffin plan updated successfully"
}
```

---

### API 16: Today's Tiffin Dispatch Schedule & Deliveries
* **Screen in Flutter**: `TiffinDeliveriesScreen` & `SubscriberCardScreen`
* **Method**: `GET`
* **Path**: `/api/restaurants/tiffin-plans/deliveries/today`
* **Auth**: Required (`Bearer <token>`)

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Today tiffin dispatch loads retrieved",
  "data": {
    "summary": {
      "totalPacksToday": 57,
      "lunchPacks": 45,
      "dinnerPacks": 12
    },
    "deliveries": [
      {
        "subscriberId": "sub_901",
        "customerName": "Aarav Sharma",
        "mobile": "9812345678",
        "planName": "Deluxe Lunch Thali",
        "mealType": "LUNCH",
        "deliveryAddress": "Flat 201, Tower 3, Silver Oak Apartments, Gurugram",
        "dispatchTime": "12:00 PM",
        "status": "PACKED"
      }
    ]
  }
}
```

---

### API 17: Wallet Withdrawal / Bank Payout Request
* **Screen in Flutter**: `WalletScreen` (`lib/features/wallet/presentation/pages/wallet_screen.dart`)
* **Method**: `POST`
* **Path**: `/api/restaurants/wallet/withdraw`
* **Auth**: Required (`Bearer <token>`)

#### Request Body (`application/json`)
```json
{
  "amount": 12000.00
}
```

#### Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Withdrawal request submitted for bank transfer",
  "data": {
    "transactionId": "TXN_WTH_902183",
    "amount": 12000.00,
    "status": "PROCESSING",
    "estimatedSettlementDate": "2026-10-02"
  }
}
```

---

### API 18: Kitchen Profile Details & Operating Hours
* **Screen in Flutter**: `KitchenProfileScreen` & `EditProfileScreen`
* **Method**: `GET` (Fetch) & `PUT` (Update)
* **Path**: `/api/restaurants/profile`
* **Auth**: Required (`Bearer <token>`)

#### GET Response (`200 OK`)
```json
{
  "success": true,
  "data": {
    "restaurantName": "The Great Kitchen",
    "ownerName": "John Doe",
    "email": "john@example.com",
    "mobile": "9999999999",
    "cuisines": ["North Indian", "Chinese", "Thali"],
    "operatingHours": {
      "open": "10:00",
      "close": "23:00"
    },
    "breakSlot": {
      "start": "16:00",
      "end": "17:30"
    },
    "fullAddress": "123 Food Street, Cyber City, Gurugram, 122002",
    "bannerImageUrl": "https://api.eatoggy.in/uploads/banners/kitchen_banner.jpg"
  }
}
```

#### PUT Body:
```json
{
  "operatingHours": { "open": "09:30", "close": "23:30" },
  "breakSlot": { "start": "16:00", "end": "17:00" },
  "cuisines": ["North Indian", "Mughlai", "Thali"]
}
```

---

### API 19: Notifications Center List & Mark Read
* **Screen in Flutter**: `NotificationsScreen` (`lib/features/notifications/presentation/pages/notifications_screen.dart`)
* **Method**: `GET` (List) & `PATCH` (Mark Read)
* **Path**: `/api/restaurants/notifications` & `/api/restaurants/notifications/mark-read`
* **Auth**: Required (`Bearer <token>`)

#### GET Response (`200 OK`)
```json
{
  "success": true,
  "data": {
    "unreadCount": 2,
    "notifications": [
      {
        "_id": "notif_001",
        "title": "New order received #ORD-1048",
        "description": "Customer Rahul Sharma placed an order for ₹580",
        "type": "NEW_ORDER",
        "referenceId": "6abda2a4bda84c00216fd4c3",
        "isUnread": true,
        "createdAt": "2026-10-01T13:40:00.000Z"
      }
    ]
  }
}
```

---

## 🛠️ SECTION 3: PRIORITY 3 — LOW (Support & Ticketing)

---

### API 20: Create Support Ticket
* **Screen in Flutter**: `HelpSupportScreen` (`lib/features/profile/presentation/pages/help_support_screen.dart`)
* **Method**: `POST`
* **Path**: `/api/support/tickets/restaurant`
* **Auth**: Required (`Bearer <token>`)

#### Request Body (`application/json`)
```json
{
  "category": "Payout Issue",
  "subject": "Delayed settlement for weekend orders",
  "description": "Settlement amount of ₹8,450 for Saturday has not reflected in bank account yet.",
  "priority": "HIGH"
}
```

#### Success Response (`201 Created`)
```json
{
  "success": true,
  "message": "Support ticket created successfully",
  "data": {
    "ticketNumber": "TCK-202610-8812",
    "status": "OPEN",
    "createdAt": "2026-10-01T17:00:00.000Z"
  }
}
```

---

## 📋 Complete Master Checklist for Backend Team

| # | Priority | Method | Endpoint Path | Feature / Screen |
| :---: | :---: | :---: | :--- | :--- |
| **1** | **P1** | `GET` | `/api/restaurants/me` | Splash Auto-Login & Approval Check |
| **2** | **P1** | `PATCH` | `/api/restaurants/status/toggle-online` | Store Online / Offline Toggle |
| **3** | **P1** | `GET` | `/api/restaurants/orders/history` | Past Delivered / Cancelled Orders Tab |
| **4** | **P1** | `GET` | `/api/restaurants/orders/:orderId` | Single Order Full Line-Item Details |
| **5** | **P1** | `POST` | `/api/restaurants/orders/:orderId/reject` | Reject Order with Reason & Auto-Refund |
| **6** | **P1** | `GET` | `/api/restaurants/menu/categories` | Food Categories List |
| **7** | **P1** | `POST` | `/api/restaurants/menu/categories` | Add Food Category |
| **8** | **P1** | `GET` | `/api/restaurants/menu/categories/:id/items` | Category Dishes Drill-down |
| **9** | **P1** | `POST` | `/api/restaurants/menu/items` | Add Menu Item / Dish |
| **10** | **P1** | `PUT` | `/api/restaurants/menu/items/:id` | Edit Menu Item / Dish |
| **11** | **P1** | `PATCH` | `/api/restaurants/menu/items/:id/toggle-stock` | In-Stock / Out-of-Stock Switch |
| **12** | **P1** | `DELETE` | `/api/restaurants/menu/items/:id` | Delete Menu Item |
| **13** | **P1** | `POST` | `/api/restaurants/notifications/device-token` | ✅ IMPLEMENTED (FCM Device Token for Order Bell Chime) |
| **14** | **P2** | `POST` | `/api/restaurants/orders/:orderId/handover` | Delivery Rider Pickup Handover |
| **15** | **P2** | `PUT` | `/api/restaurants/tiffin-plans/:planId` | Edit / Pause Tiffin Subscription Plan |
| **16** | **P2** | `GET` | `/api/restaurants/tiffin-plans/deliveries/today` | Today's Tiffin Dispatch Schedule |
| **17** | **P2** | `POST` | `/api/restaurants/wallet/withdraw` | Request Balance Payout to Bank |
| **18** | **P2** | `GET, PUT` | `/api/restaurants/profile` | ✅ IMPLEMENTED (`GET /api/restaurants/profile`) |
| **19** | **P2** | `GET, PATCH`| `/api/restaurants/notifications` | ✅ IMPLEMENTED (`GET /api/restaurants/notifications`) |
| **20** | **P3** | `POST` | `/api/support/tickets/restaurant` | Submit Partner Support Issue Ticket |
