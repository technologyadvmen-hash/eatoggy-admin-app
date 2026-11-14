# Eatoggy Restaurant Partner App — Pending Backend APIs & Bug Fixes

> **Target Audience**: Backend Engineering Team  
> **Base URL**: `https://api.eatoggy.in/api`  
> **Scope**: **1 Urgent Route Bug Fix** + **12 Missing Endpoints to Deploy** (Total 13 Action Items)  
> **Mobile App Status**: **All 32 Postman APIs are 100% Implemented in Flutter**  

---

### `GET /api/restaurants/orders/history` (Past Orders History)
* **Screen**: Orders Screen — "History" Tab (`Delivered` & `Cancelled` Orders)
* **Auth**: `Bearer <token>`
* **Current Issue**: The endpoint crashes with a Mongoose `CastError`:
  ```json
  {
    "success": false,
    "message": "Resource not found",
    "stack": "CastError: Cast to ObjectId failed for value \"history\" (type string) at path \"_id\" for model \"Order\""
  }
  ```
* **Root Cause in Express**:  
  In your orders router, `router.get('/orders/:orderId', ...)` is declared **before** `router.get('/orders/history', ...)`.  
  Because of this, Express interprets `"history"` as an `:orderId` parameter and tries to cast it to a MongoDB `ObjectId`.
* **Required Fix**:  
  Move the `/orders/history` route definition **above** `/orders/:orderId`:
  ```javascript
  // ✅ Correct Order in Express Router:
  router.get('/orders/history', authMiddleware, getOrderHistory);
  router.get('/orders/:orderId', authMiddleware, getOrderDetails);
  ```

---

## 🍔 2. Menu Items & Dishes CRUD (5 Endpoints)

In the Postman collection, only `POST /api/restaurants/menu/categories` was provided. The app requires endpoints to fetch, add, edit, and toggle dishes inside those categories.

---

### API 1: Fetch Dishes under Category
* **Method**: `GET`
* **Path**: `/api/restaurants/menu/categories/:categoryId/items` (or `/api/restaurants/menu/items?categoryId=:categoryId`)
* **Auth**: `Bearer <token>`
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Dishes retrieved successfully",
    "data": [
      {
        "id": "item_6190284",
        "categoryId": "6abfd569cf51279401e3e7b5",
        "name": "Paneer Butter Masala",
        "description": "Cottage cheese cubes simmered in creamy tomato gravy",
        "price": 280,
        "isVeg": true,
        "imageUrl": "https://cdn.eatoggy.in/items/paneer.jpg",
        "isAvailable": true,
        "preparationTime": 20
      }
    ]
  }
  ```

---

### API 2: Add Food Item / Dish
* **Method**: `POST`
* **Path**: `/api/restaurants/menu/items`
* **Auth**: `Bearer <token>`
* **Request Body (`application/json`)**:
  ```json
  {
    "categoryId": "6abfd569cf51279401e3e7b5",
    "name": "Paneer Butter Masala",
    "description": "Rich tomato butter gravy with cottage cheese",
    "price": 280.00,
    "isVeg": true,
    "imageUrl": "https://cdn.eatoggy.in/items/paneer.jpg",
    "preparationTime": 20,
    "isAvailable": true
  }
  ```
* **Success Response (`201 Created`)**:
  ```json
  {
    "success": true,
    "message": "Menu item added successfully",
    "data": {
      "id": "item_6190284",
      "name": "Paneer Butter Masala",
      "price": 280.00
    }
  }
  ```

---

### API 3: Edit Food Item / Dish
* **Method**: `PUT`
* **Path**: `/api/restaurants/menu/items/:id`
* **Auth**: `Bearer <token>`
* **Request Body (`application/json`)**:
  ```json
  {
    "name": "Paneer Butter Masala (Special)",
    "price": 299.00,
    "description": "Updated rich gravy description",
    "isAvailable": true
  }
  ```
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Menu item updated successfully"
  }
  ```

---

### API 4: Quick In-Stock / Out-of-Stock Toggle
* **Method**: `PATCH`
* **Path**: `/api/restaurants/menu/items/:id/toggle-stock`
* **Auth**: `Bearer <token>`
* **Request Body (`application/json`)**:
  ```json
  {
    "isAvailable": false
  }
  ```
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Stock status updated",
    "data": {
      "id": "item_6190284",
      "isAvailable": false
    }
  }
  ```

---

### API 5: Delete Food Item
* **Method**: `DELETE`
* **Path**: `/api/restaurants/menu/items/:id`
* **Auth**: `Bearer <token>`
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Menu item deleted successfully"
  }
  ```

---

## 🛵 3. Order Handover & Kitchen Online Switch (2 Endpoints)

---

### API 6: Handover Order to Delivery Rider
* **Screen**: Kitchen Screen — When packed food is handed to rider
* **Method**: `POST`
* **Path**: `/api/restaurants/orders/:orderId/handover`
* **Auth**: `Bearer <token>`
* **Request Body (`application/json`)**:
  ```json
  {
    "riderOtp": "4921",
    "notes": "All items verified and sealed"
  }
  ```
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Order successfully handed over to delivery partner",
    "data": {
      "orderId": "6abda2a4bda84c00216fd4c6",
      "status": "PICKED_UP",
      "pickedUpAt": "2026-10-02T18:30:00.000Z"
    }
  }
  ```

---

### API 7: Store Online / Offline Toggle
* **Screen**: Home Screen & Profile Screen — Accept Orders Switch
* **Method**: `PATCH`
* **Path**: `/api/restaurants/status/toggle-online`
* **Auth**: `Bearer <token>`
* **Request Body (`application/json`)**:
  ```json
  {
    "isOnline": false,
    "reason": "Kitchen rush / Break"
  }
  ```
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Store status updated successfully",
    "data": {
      "isOnline": false,
      "updatedAt": "2026-10-02T18:30:00.000Z"
    }
  }
  ```

---

## 🏪 4. Kitchen Profile & Operating Hours (1 Endpoint)

---

### API 8: Update Kitchen Profile & Timings
* **Screen**: Kitchen Profile (`lib/features/profile/presentation/pages/kitchen_profile_screen.dart`)
* **Method**: `PUT`
* **Path**: `/api/restaurants/profile`
* **Auth**: `Bearer <token>`
* **Request Body (`application/json`)**:
  ```json
  {
    "restaurantName": "The Great Kitchen",
    "ownerName": "John Doe",
    "cuisines": ["Italian", "North Indian"],
    "operatingHours": {
      "open": "09:00",
      "close": "23:00"
    },
    "bannerUrl": "https://cdn.eatoggy.in/banners/kitchen1.jpg"
  }
  ```
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Kitchen profile updated successfully"
  }
  ```

---

## 🍱 5. Tiffin Daily Operations (2 Endpoints)

---

### API 9: Today's Tiffin Dispatch Schedule
* **Screen**: Subscriptions Screen — Today's Dispatch Tab
* **Method**: `GET`
* **Path**: `/api/restaurants/tiffin-plans/deliveries/today`
* **Auth**: `Bearer <token>`
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
          "planName": "Deluxe Daily Thali",
          "mealType": "LUNCH",
          "address": "Flat 302, Green Glen Layout, Bellandur",
          "dispatchTime": "12:30 PM",
          "status": "SCHEDULED"
        }
      ]
    }
  }
  ```

---

### API 10: Edit / Pause Tiffin Subscription Plan
* **Screen**: Subscriptions Screen — Edit / Pause Plan
* **Method**: `PUT`
* **Path**: `/api/restaurants/tiffin-plans/:planId`
* **Auth**: `Bearer <token>`
* **Request Body (`application/json`)**:
  ```json
  {
    "pricePerMeal": 160,
    "isActive": false,
    "description": "Updated menu description"
  }
  ```
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Tiffin plan updated successfully"
  }
  ```

---

## 💰 6. Direct Wallet Bank Payout (1 Endpoint)

---

### API 11: Request Wallet Balance Withdrawal to Bank
* **Screen**: Wallet Screen (`lib/features/wallet/presentation/pages/wallet_screen.dart`)
* **Method**: `POST`
* **Path**: `/api/restaurants/wallet/withdraw`
* **Auth**: `Bearer <token>`
* **Request Body (`application/json`)**:
  ```json
  {
    "amount": 5000.00
  }
  ```
* **Success Response (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "Withdrawal request submitted for bank transfer",
    "data": {
      "transactionId": "TXN_WTH_902183",
      "amount": 5000.00,
      "status": "PROCESSING",
      "estimatedSettlementDate": "2026-10-03"
    }
  }
  ```

---

## 🔔 7. Notifications Read Status (1 Endpoint)

### API 12: Mark Notifications as Read
* **Screen**: Notifications Screen (`lib/features/notifications/presentation/pages/notifications_screen.dart`)
* **Method**: `PATCH`
* **Path**: `/api/restaurants/notifications/mark-read`
* **Auth**: Required (`Bearer <token>`)
* **Content-Type**: `application/json`

#### 📌 Purpose & Flow
In the mobile app, notifications display an unread gold dot and an unread badge counter in the top bar.
1. **Single Notification Click**: When a restaurant partner taps an unread notification card, the app sends that notification's ID to mark it as read.
2. **"Mark All Read" Button**: When the partner taps the "Mark all read" button in the AppBar, the app sends an empty array to mark all notifications for that restaurant as read simultaneously.

---

#### 📥 Request Body (`application/json`)

**Option A: Mark Specific Notification(s) as Read**
```json
{
  "notificationIds": [
    "6ac12984bda84c00216fd991"
  ]
}
```

**Option B: Mark ALL Notifications as Read**
```json
{
  "notificationIds": []
}
```
*(Passing an empty array `[]` or omitting `notificationIds` entirely marks ALL notifications for the authenticated restaurant partner as read).*

---

#### 📤 Success Response (`200 OK`)
```json
{
  "success": true,
  "message": "Notifications marked as read successfully",
  "data": {
    "markedCount": 3,
    "unreadCount": 0
  }
}
```

---

#### 🔴 Error Responses

**401 Unauthorized:**
```json
{
  "success": false,
  "message": "Authentication token missing or expired"
}
```

**500 Internal Server Error:**
```json
{
  "success": false,
  "message": "Failed to update notification status"
}
```

---

#### 💻 Ready-to-Use Express.js Controller Code (Copy & Paste for Backend Devs)

```javascript
// controllers/notificationController.js
import Notification from '../models/Notification.js';

export const markNotificationsAsRead = async (req, res) => {
  try {
    const restaurantId = req.restaurant?.id || req.user?.restaurantId || req.user?.id;
    if (!restaurantId) {
      return res.status(401).json({ success: false, message: "Unauthorized" });
    }

    const { notificationIds } = req.body;

    // Build filter: default to all unread notifications of this restaurant
    const query = { restaurantId, isRead: false };

    // If specific notification IDs are provided, target only those
    if (Array.isArray(notificationIds) && notificationIds.length > 0) {
      query._id = { $in: notificationIds };
    }

    // Update matched notifications
    const updateResult = await Notification.updateMany(query, {
      $set: { isRead: true, readAt: new Date() }
    });

    // Count remaining unread notifications for badge
    const remainingUnread = await Notification.countDocuments({
      restaurantId,
      isRead: false
    });

    return res.status(200).json({
      success: true,
      message: "Notifications marked as read successfully",
      data: {
        markedCount: updateResult.modifiedCount,
        unreadCount: remainingUnread
      }
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || "Internal server error"
    });
  }
};

// routes/notificationRoutes.js
// router.patch('/notifications/mark-read', authMiddleware, markNotificationsAsRead);
```


---

## 📋 Master Summary Table for Backend Team

| # | Priority | Method | Endpoint Path | Action Needed | Feature Area |
|:---:|:---:|:---:|:---|:---:|:---|
| **1** | 🔥 **URGENT** | `GET` | `/api/restaurants/orders/history` | **Bug Fix**: Move route above `/:orderId` in Express | Orders History Tab |
| **2** | **P1** | `GET` | `/api/restaurants/menu/categories/:categoryId/items` | New Route | Dish List under Category |
| **3** | **P1** | `POST` | `/api/restaurants/menu/items` | New Route | Add Food Item / Dish |
| **4** | **P1** | `PUT` | `/api/restaurants/menu/items/:id` | New Route | Edit Food Item / Dish |
| **5** | **P1** | `PATCH` | `/api/restaurants/menu/items/:id/toggle-stock` | New Route | Instant Stock In/Out Switch |
| **6** | **P1** | `DELETE` | `/api/restaurants/menu/items/:id` | New Route | Delete Menu Item |
| **7** | **P1** | `POST` | `/api/restaurants/orders/:orderId/handover` | New Route | Rider Pickup Handover |
| **8** | **P1** | `PATCH` | `/api/restaurants/status/toggle-online` | New Route | Store Online / Offline Toggle |
| **9** | **P2** | `PUT` | `/api/restaurants/profile` | New Route | Update Profile & Timings |
| **10** | **P2** | `GET` | `/api/restaurants/tiffin-plans/deliveries/today` | New Route | Daily Tiffin Dispatch List |
| **11** | **P2** | `PUT` | `/api/restaurants/tiffin-plans/:planId` | New Route | Edit / Pause Tiffin Plan |
| **12** | **P2** | `POST` | `/api/restaurants/wallet/withdraw` | New Route | Balance Payout to Bank |
| **13** | **P2** | `PATCH` | `/api/restaurants/notifications/mark-read` | New Route | Mark Notifications Read |

