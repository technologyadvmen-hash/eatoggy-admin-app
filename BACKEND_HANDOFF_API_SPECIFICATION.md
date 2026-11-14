# Eatoggy Restaurant Partner App — Backend API Handoff Specification

> **Target Audience**: Backend Engineering Team  
> **Base URL**: `https://api.eatoggy.in/api`  
> **Auth Header**: `Authorization: Bearer <JWT_TOKEN>`  
> **Mobile App Status**: UI, Models, State Management, and Repositories are 100% prepared in Flutter.  
> **Scope**: **1 Urgent Express Bug Fix** + **12 Missing Production Endpoints** + **WebSocket Events**.

---

## 📑 Quick Navigation

1. [Authentication & Common Standards](#1-authentication--common-standards)
2. [🔥 URGENT BUG FIX: Route Collision in Express](#2--urgent-bug-fix-route-collision-in-express)
3. [🍔 Menu Management Endpoints (CRUD + Stock Toggle)](#3--menu-management-endpoints)
4. [🛵 Order Execution, Detail & Handover Endpoints](#4--order-execution-detail--handover-endpoints)
5. [🏪 Store Online / Offline & Dynamic Auto-Login](#5--store-online--offline--dynamic-auto-login)
6. [🍱 Subscriptions & Tiffin Dispatch Operations](#6--subscriptions--tiffin-dispatch-operations)
7. [💰 Wallet Bank Payout / Withdrawal](#7--wallet-bank-payout--withdrawal)
8. [🔔 Notifications & Push Device Token Registration](#8--notifications--push-device-token-registration)
9. [⚡ WebSocket Real-Time Events (Incoming Order Siren)](#9--websocket-real-time-events)
10. [📋 Master Summary Table for Backend Team](#10--master-summary-table-for-backend-team)

---

## 1. Authentication & Common Standards

### 1.1 Bearer Token
All endpoints in this document require the JWT Bearer token obtained from `/api/restaurant-auth/verify-otp`.
```http
Authorization: Bearer <JWT_TOKEN>
Accept: application/json
```

The authentication middleware must decode the JWT and inject `restaurantId` (or `restaurant._id`) into `req.restaurant` or `req.user`:
```javascript
// Middleware extraction pattern:
const restaurantId = req.restaurant?._id || req.restaurant?.id || req.user?.restaurantId || req.user?.id;
```

### 1.2 Standard JSON Envelope
**Success (`200 OK` / `201 Created`):**
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {}
}
```

**Error (`400` / `401` / `404` / `500`):**
```json
{
  "success": false,
  "message": "Human-readable explanation of failure"
}
```

---

## 2. 🔥 URGENT BUG FIX: Route Collision in Express

### Route: `GET /api/restaurants/orders/history`
* **Target Screen**: Orders Screen — "Past Orders / Completed" Tab (`lib/features/orders/presentation/pages/orders_screen.dart`)
* **Current Error**:
  ```json
  {
    "success": false,
    "message": "Resource not found",
    "stack": "CastError: Cast to ObjectId failed for value \"history\" (type string) at path \"_id\" for model \"Order\""
  }
  ```
* **Root Cause**:
  In your Express orders router, `router.get('/orders/:orderId', ...)` is placed **above** `router.get('/orders/history', ...)`.  
  Express matches `/orders/history` with parameter `:orderId = "history"` and attempts to convert the string `"history"` into a MongoDB `ObjectId`.

* **Required Solution in Code**:
  Move `/orders/history` **above** `/orders/:orderId`:
  ```javascript
  // ❌ WRONG ORDER (Crashes):
  router.get('/orders/:orderId', authMiddleware, getOrderDetails);
  router.get('/orders/history', authMiddleware, getOrderHistory);

  // ✅ CORRECT ORDER:
  router.get('/orders/history', authMiddleware, getOrderHistory);
  router.get('/orders/:orderId', authMiddleware, getOrderDetails);
  ```

---

## 3. 🍔 Menu Management Endpoints

The mobile app currently allows partners to view categories, but cannot fetch, add, edit, or toggle items without these endpoints.

---

### 3.1 Fetch Dishes under Category
* **Method**: `GET`
* **Path**: `/api/restaurants/menu/categories/:categoryId/items`
* **Auth**: `Bearer <token>`
* **Query Params (Optional)**: `?isAvailable=true&page=1&limit=50`
* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "message": "Category dishes retrieved successfully",
  "data": [
    {
      "_id": "65b4c901df51279401e3e8a1",
      "categoryId": "65b4c109df51279401e3e7b5",
      "itemName": "Paneer Butter Masala",
      "description": "Cottage cheese cubes simmered in rich creamy tomato butter gravy",
      "price": 280,
      "isVeg": true,
      "prepTimeMinutes": 20,
      "isAvailableImmediately": true,
      "imageUrl": "https://cdn.eatoggy.in/uploads/menu/paneer.jpg",
      "sizeVariants": [
        { "title": "Half", "price": 160 },
        { "title": "Full", "price": 280 }
      ],
      "addons": [
        { "title": "Extra Butter", "price": 25 },
        { "title": "Extra Paneer Cubes", "price": 40 }
      ]
    }
  ]
}
```

---

### 3.2 Add Menu Item / Dish (Multipart)
* **Method**: `POST`
* **Path**: `/api/restaurants/menu/items`
* **Auth**: `Bearer <token>`
* **Content-Type**: `multipart/form-data`
* **Screen**: `AddMenuItemScreen` (`lib/features/menu/presentation/pages/add_menu_item_screen.dart`)

#### Form Fields:
| Field | Type | Required | Description |
|:---|:---:|:---:|:---|
| `categoryId` | String (ObjectId) | **Yes** | 24-character ObjectId of the category |
| `itemName` | String | **Yes** | Name of the dish (e.g., "Dal Makhani") |
| `price` | Number | **Yes** | Selling price in INR (e.g., `240`) |
| `prepTimeMinutes` | Number | **Yes** | Kitchen preparation time in minutes (e.g., `20`) |
| `isVeg` | Boolean | **Yes** | `true` for Vegetarian, `false` for Non-Veg |
| `description` | String | No | Detailed description / ingredients |
| `isAvailableImmediately`| Boolean | No | Default `true` |
| `sizeVariants` | JSON Array / String | No | `[{"title":"Half","price":130},{"title":"Full","price":240}]` |
| `addons` | JSON Array / String | No | `[{"title":"Extra Butter","price":20}]` |
| `image` | File (Binary) | No | Dish image file (JPG / PNG / WebP) |

#### Success Response (`201 Created`):
```json
{
  "success": true,
  "message": "Menu item created successfully",
  "data": {
    "_id": "65b4c901df51279401e3e8a1",
    "restaurantId": "65b3cc6f96d118c6b8704eb9",
    "categoryId": "65b4c109df51279401e3e7b5",
    "itemName": "Dal Makhani",
    "price": 240,
    "isVeg": true,
    "prepTimeMinutes": 20,
    "isAvailableImmediately": true,
    "imageUrl": "https://cdn.eatoggy.in/uploads/menu/dal_makhani.jpg"
  }
}
```

---

### 3.3 Edit Menu Item / Dish
* **Method**: `PUT`
* **Path**: `/api/restaurants/menu/items/:itemId`
* **Auth**: `Bearer <token>`
* **Content-Type**: `application/json` (or `multipart/form-data` if image updated)

#### Request Body (`application/json`):
```json
{
  "itemName": "Dal Makhani (Special)",
  "price": 260,
  "prepTimeMinutes": 25,
  "description": "Slow cooked black lentils with churned butter and cream",
  "isAvailableImmediately": true,
  "sizeVariants": [
    { "title": "Half", "price": 140 },
    { "title": "Full", "price": 260 }
  ]
}
```

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "message": "Menu item updated successfully",
  "data": {
    "_id": "65b4c901df51279401e3e8a1",
    "itemName": "Dal Makhani (Special)",
    "price": 260
  }
}
```

---

### 3.4 Quick In-Stock / Out-of-Stock Toggle
* **Method**: `PATCH`
* **Path**: `/api/restaurants/menu/items/:itemId/toggle-stock`
* **Auth**: `Bearer <token>`
* **Content-Type**: `application/json`
* **Purpose**: Kitchen switches a dish off in real-time when an ingredient runs out during rush hour.

#### Request Body:
```json
{
  "isAvailable": false
}
```

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "message": "Stock status updated successfully",
  "data": {
    "itemId": "65b4c901df51279401e3e8a1",
    "isAvailable": false,
    "updatedAt": "2026-10-16T12:30:00.000Z"
  }
}
```

---

### 3.5 Delete Menu Item
* **Method**: `DELETE`
* **Path**: `/api/restaurants/menu/items/:itemId`
* **Auth**: `Bearer <token>`
* **Success Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Menu item deleted successfully"
}
```

---

## 4. 🛵 Order Execution, Detail & Handover Endpoints

---

### 4.1 Get Single Order Details
* **Method**: `GET`
* **Path**: `/api/restaurants/orders/:orderId`
* **Auth**: `Bearer <token>`
* **Screen**: `OrderDetailScreen` (`lib/features/orders/presentation/pages/order_detail_screen.dart`)
* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "message": "Order details retrieved",
  "data": {
    "_id": "65c19284df51279401e3e110",
    "orderNumber": "EAT-9102",
    "orderStatus": "ACCEPTED",
    "customer": {
      "name": "Aakash Verma",
      "mobile": "+919876543210",
      "deliveryAddress": "Flat 402, Tower B, Supertech Eco Village, Sector 1, Noida"
    },
    "items": [
      {
        "itemId": "65b4c901df51279401e3e8a1",
        "name": "Paneer Butter Masala",
        "quantity": 2,
        "variant": "Full",
        "price": 280,
        "total": 560,
        "addons": ["Extra Butter"]
      },
      {
        "itemId": "65b4c901df51279401e3e999",
        "name": "Butter Naan",
        "quantity": 4,
        "price": 45,
        "total": 180
      }
    ],
    "specialInstructions": "Please make it spicy and deliver extra cutlery",
    "pricing": {
      "itemTotal": 740,
      "taxes": 37.00,
      "packagingCharge": 25.00,
      "deliveryFee": 30.00,
      "restaurantEarnings": 720.00,
      "grandTotal": 832.00
    },
    "paymentMethod": "UPI_ONLINE",
    "paymentStatus": "PAID",
    "createdAt": "2026-10-16T12:15:00.000Z"
  }
}
```

---

### 4.2 Handover Order to Delivery Rider
* **Method**: `POST`
* **Path**: `/api/restaurants/orders/:orderId/handover`
* **Auth**: `Bearer <token>`
* **Content-Type**: `application/json`
* **Screen**: `HandoverOrderScreen` (`lib/features/orders/presentation/pages/handover_order_screen.dart`)
* **Purpose**: Verifies that the packed order has been given to the correct delivery partner using the rider's pickup code/OTP.

#### Request Body:
```json
{
  "riderOtp": "4921",
  "notes": "Packed in thermal bag, all 6 items verified"
}
```

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "message": "Order successfully handed over to delivery partner",
  "data": {
    "orderId": "65c19284df51279401e3e110",
    "status": "PICKED_UP",
    "pickedUpAt": "2026-10-16T12:45:00.000Z",
    "rider": {
      "name": "Ravi Kumar",
      "mobile": "+919811223344",
      "vehicleNumber": "UP16-BW-4819"
    }
  }
}
```

---

### 4.3 Reject Incoming Order
* **Method**: `POST`
* **Path**: `/api/restaurants/orders/:orderId/reject`
* **Auth**: `Bearer <token>`
* **Content-Type**: `application/json`

#### Request Body:
```json
{
  "reasonCode": "OUT_OF_STOCK",
  "reasonNote": "Main ingredients out of stock for this dish"
}
```
*Allowed `reasonCode` values*: `OUT_OF_STOCK`, `KITCHEN_BUSY`, `CLOSING_SOON`, `OTHER`.

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "message": "Order rejected successfully. Customer refund initiated."
}
```

---

## 5. 🏪 Store Online / Offline & Dynamic Auto-Login

---

### 5.1 Store Online / Offline Status Toggle
* **Method**: `PATCH`
* **Path**: `/api/restaurants/status/toggle-online`
* **Auth**: `Bearer <token>`
* **Content-Type**: `application/json`
* **Screens**: Header switch on `HomeScreen` & `KitchenScreen`

#### Request Body:
```json
{
  "isOnline": false,
  "reason": "Kitchen rush / Peak load break",
  "autoResumeMinutes": 30
}
```
*(Passing `isOnline: true` turns the store active immediately; `autoResumeMinutes` is optional).*

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "message": "Restaurant operational status updated",
  "data": {
    "isOnline": false,
    "reason": "Kitchen rush / Peak load break",
    "updatedAt": "2026-10-16T12:50:00.000Z"
  }
}
```

---

### 5.2 Dynamic Profile & Approval Status Check (`/restaurants/me`)
* **Method**: `GET`
* **Path**: `/api/restaurants/me`
* **Auth**: `Bearer <token>`
* **Screen**: `SplashScreen` (`lib/features/splash/presentation/pages/splash_screen.dart`)
* **Purpose**: Validates Bearer token on app launch and routes partner based on current approval state:
  * If `onboardingStatus === "APPROVED"` $\rightarrow$ Open Main Dashboard.
  * If `onboardingStatus === "PENDING_REVIEW"` $\rightarrow$ Open Application Submitted Screen.
  * If `onboardingStatus === "REJECTED"` $\rightarrow$ Show rejection reason & re-upload documents.
  * If `onboardingStatus === "PENDING_DOCS"` $\rightarrow$ Resume onboarding step.

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "message": "Restaurant profile retrieved successfully",
  "data": {
    "restaurantId": "65b3cc6f96d118c6b8704eb9",
    "restaurantName": "The Royal Spice Kitchen",
    "ownerName": "Rajesh Sharma",
    "mobile": "9999999999",
    "email": "rajesh@royalspice.com",
    "restaurantType": "Cloud Kitchen",
    "cuisine": "North Indian, Thali",
    "onboardingStatus": "APPROVED",
    "currentStep": "COMPLETED",
    "isOnline": true,
    "operatingHours": {
      "open": "10:00",
      "close": "23:00"
    },
    "address": {
      "fullAddress": "Shop 14, Sector 62, Noida, UP, 201301",
      "latitude": 28.6280,
      "longitude": 77.3649
    },
    "bannerUrl": "https://cdn.eatoggy.in/banners/kitchen1.jpg"
  }
}
```

---

## 6. 🍱 Subscriptions & Tiffin Dispatch Operations

---

### 6.1 Today's Tiffin Dispatch Schedule
* **Method**: `GET`
* **Path**: `/api/restaurants/tiffin-plans/deliveries/today`
* **Auth**: `Bearer <token>`
* **Screen**: `TiffinDeliveriesScreen` (`lib/features/subscriptions/presentation/pages/tiffin_deliveries_screen.dart`)
* **Success Response (`200 OK`)**:
```json
{
  "success": true,
  "message": "Today's deliveries retrieved",
  "data": {
    "lunchCount": 14,
    "dinnerCount": 9,
    "deliveries": [
      {
        "subscriptionId": "sub_819284",
        "customerName": "Ramesh Kumar",
        "customerMobile": "+919876543210",
        "planName": "Deluxe Daily Thali",
        "mealType": "LUNCH",
        "address": "Flat 302, Green Glen Layout, Bellandur",
        "dispatchTime": "12:30 PM",
        "items": ["4 Roti", "Dal Makhani", "Paneer Butter Masala", "Jeera Rice"],
        "status": "SCHEDULED"
      }
    ]
  }
}
```

---

### 6.2 Update / Pause Tiffin Plan
* **Method**: `PUT`
* **Path**: `/api/restaurants/tiffin-plans/:planId`
* **Auth**: `Bearer <token>`
* **Content-Type**: `application/json`

#### Request Body:
```json
{
  "pricePerMeal": 160,
  "isActive": false,
  "description": "Updated weekly meal plan with fresh seasonal vegetables"
}
```

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "message": "Tiffin plan updated successfully"
}
```

---

## 7. 💰 Wallet Bank Payout / Withdrawal

---

### 7.1 Request Wallet Balance Withdrawal to Bank
* **Method**: `POST`
* **Path**: `/api/restaurants/wallet/withdraw`
* **Auth**: `Bearer <token>`
* **Content-Type**: `application/json`
* **Screen**: `WalletScreen` (`lib/features/wallet/presentation/pages/wallet_screen.dart`)

#### Request Body:
```json
{
  "amount": 5000.00
}
```

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "message": "Withdrawal request submitted for bank transfer",
  "data": {
    "transactionId": "TXN_WTH_902183",
    "amount": 5000.00,
    "bankAccountMasked": "•••• •••• 4819",
    "status": "PROCESSING",
    "estimatedSettlementDate": "2026-10-17"
  }
}
```

---

## 8. 🔔 Notifications & Push Device Token Registration

---

### 8.1 Register Device FCM Push Token
* **Method**: `POST`
* **Path**: `/api/restaurants/notifications/device-token`
* **Auth**: `Bearer <token>`
* **Content-Type**: `application/json`

#### Request Body:
```json
{
  "fcmToken": "eAbCdEf1234567890:APA91bH...",
  "platform": "android",
  "devicePlatform": "ANDROID",
  "appVersion": "1.0.0"
}
```

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "message": "Device token synchronized successfully"
}
```

---

### 8.2 Mark Notifications as Read
* **Method**: `PATCH`
* **Path**: `/api/restaurants/notifications/mark-read`
* **Auth**: `Bearer <token>`
* **Content-Type**: `application/json`

#### Request Body (Option A — Mark Specific IDs):
```json
{
  "notificationIds": ["65c19284df51279401e3e991"]
}
```

#### Request Body (Option B — Mark ALL as Read):
```json
{
  "notificationIds": []
}
```

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "message": "Notifications marked as read",
  "data": {
    "markedCount": 3,
    "unreadCount": 0
  }
}
```

---

## 9. ⚡ WebSocket Real-Time Events

The restaurant partner app must receive **instant live events** so kitchen staff hear the order siren ring immediately when an order is created.

### 9.1 Connection URL & Auth
* **Socket URL**: `https://api.eatoggy.in`
* **Transports**: `['websocket', 'polling']`
* **Auth**: Pass Bearer token in extra headers or query:
  ```javascript
  const socket = io('https://api.eatoggy.in', {
    auth: { token: 'Bearer <JWT_TOKEN>' },
    query: { token: '<JWT_TOKEN>' }
  });
  ```

### 9.2 Events Backend Must Emit to Restaurant Room (`restaurant_<id>`)

#### Event 1: `order:new` (Triggers High Volume Kitchen Bell Siren)
```json
{
  "event": "order:new",
  "data": {
    "orderId": "65c19284df51279401e3e110",
    "orderNumber": "EAT-9102",
    "customerName": "Aakash Verma",
    "itemCount": 3,
    "grandTotal": 832.00,
    "items": ["2x Paneer Butter Masala", "4x Butter Naan"],
    "createdAt": "2026-10-16T12:15:00.000Z"
  }
}
```

#### Event 2: `order:cancelled` (Stops Kitchen Cooking & Shows Alert)
```json
{
  "event": "order:cancelled",
  "data": {
    "orderId": "65c19284df51279401e3e110",
    "orderNumber": "EAT-9102",
    "reason": "Customer cancelled within grace period"
  }
}
```

#### Event 3: `rider:arrived` (Updates Kitchen Handover Card)
```json
{
  "event": "rider:arrived",
  "data": {
    "orderId": "65c19284df51279401e3e110",
    "riderName": "Ravi Kumar",
    "riderPhone": "+919811223344"
  }
}
```

---

## 10. 📋 Master Summary Table for Backend Team

| # | Priority | Method | Endpoint Path | Action Needed | Feature Area |
|:---:|:---:|:---:|:---|:---:|:---|
| **1** | 🔥 **URGENT** | `GET` | `/api/restaurants/orders/history` | **Bug Fix**: Move route above `/:orderId` in Express router | Past Orders History Tab |
| **2** | **P1 (Core)** | `GET` | `/api/restaurants/me` | New Route | Splash auto-login & approval check |
| **3** | **P1 (Core)** | `PATCH` | `/api/restaurants/status/toggle-online` | New Route | Header Online / Offline switch |
| **4** | **P1 (Core)** | `GET` | `/api/restaurants/orders/:orderId` | New Route | Single order line-items & notes |
| **5** | **P1 (Core)** | `POST` | `/api/restaurants/orders/:orderId/handover` | New Route | Delivery partner OTP handover |
| **6** | **P1 (Core)** | `POST` | `/api/restaurants/orders/:orderId/reject` | New Route | Reject order with reason & auto-refund |
| **7** | **P1 (Core)** | `GET` | `/api/restaurants/menu/categories/:id/items`| New Route | Category dishes drilldown |
| **8** | **P1 (Core)** | `POST` | `/api/restaurants/menu/items` | New Route | **Add Dish (Multipart with image & variants)** |
| **9** | **P1 (Core)** | `PUT` | `/api/restaurants/menu/items/:id` | New Route | Edit Dish details & pricing |
| **10**| **P1 (Core)** | `PATCH` | `/api/restaurants/menu/items/:id/toggle-stock` | New Route | Instant In-Stock / Out-of-Stock switch |
| **11**| **P1 (Core)** | `DELETE`| `/api/restaurants/menu/items/:id` | New Route | Delete discontinued dish |
| **12**| **P1 (Core)** | `POST` | `/api/restaurants/notifications/device-token` | New Route | Sync FCM device token for order alerts |
| **13**| **P2 (High)** | `GET` | `/api/restaurants/tiffin-plans/deliveries/today`| New Route | Today's Lunch & Dinner dispatch batches |
| **14**| **P2 (High)** | `PUT` | `/api/restaurants/tiffin-plans/:planId` | New Route | Pause / resume / edit tiffin plan |
| **15**| **P2 (High)** | `POST` | `/api/restaurants/wallet/withdraw` | New Route | Bank payout withdrawal request |
| **16**| **P2** | `PATCH` | `/api/restaurants/notifications/mark-read` | New Route | Clear unread notification badges |
| **17**| **P2** | `PUT` | `/api/restaurants/profile` | New Route | Update kitchen bio & operating timings |
