# PayPal Payment Integration - Quick Start Guide

## 🚀 Quick Start (3 Steps)

### Step 1: Run Database Migrations
```bash
cd laravel-backend
php artisan migrate
```

### Step 2: (Optional) Set Service Fees
You can set fees through SQL or let it use the default $50:
```sql
UPDATE service_providers SET service_fee = 75.00 WHERE id = 1;
```

### Step 3: Test It!
1. Start Laravel: `php artisan serve`
2. Run Flutter app
3. Book a service → Provider accepts → Click "Pay with PayPal"

---

## 📱 User Experience Flow

```
┌─────────────────────────────────────────────────────────────┐
│ CUSTOMER VIEW                                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  My Bookings                                                │
│  ┌───────────────────────────────────────────────────────┐ │
│  │ 👤 John's Plumbing                                    │ │
│  │ Service: Pipe Repair                                  │ │
│  │ Date: Nov 18, 2025   Time: 10:00 AM                  │ │
│  │ Status: Pending                                       │ │
│  │                                                       │ │
│  │ ⏳ Waiting for provider to accept...                 │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘

                        ⬇️ Provider Accepts

┌─────────────────────────────────────────────────────────────┐
│ CUSTOMER VIEW (After Acceptance)                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  My Bookings                                                │
│  ┌───────────────────────────────────────────────────────┐ │
│  │ 👤 John's Plumbing                                    │ │
│  │ Service: Pipe Repair                                  │ │
│  │ Date: Nov 18, 2025   Time: 10:00 AM                  │ │
│  │ Status: Accepted ✅                                   │ │
│  │                                                       │ │
│  │ Amount: $75.00                                        │ │
│  │ ┌─────────────────────────────────────────┐          │ │
│  │ │  💳 Pay with PayPal                     │          │ │
│  │ └─────────────────────────────────────────┘          │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘

                        ⬇️ Click Pay Button

┌─────────────────────────────────────────────────────────────┐
│ PAYPAL CHECKOUT SCREEN                                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   🅿️ PayPal                                                │
│                                                             │
│   Log in to your PayPal account                            │
│   ┌─────────────────────────────────────┐                  │
│   │ Email: buyer@example.com            │                  │
│   └─────────────────────────────────────┘                  │
│   ┌─────────────────────────────────────┐                  │
│   │ Password: ••••••••••                │                  │
│   └─────────────────────────────────────┘                  │
│                                                             │
│   Order Details:                                           │
│   Pipe Repair - John's Plumbing                            │
│   Amount: $75.00 USD                                       │
│                                                             │
│   [Pay Now]  [Cancel]                                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘

                        ⬇️ Payment Successful

┌─────────────────────────────────────────────────────────────┐
│ CUSTOMER VIEW (After Payment)                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ✅ Payment successful!                                     │
│                                                             │
│  My Bookings                                                │
│  ┌───────────────────────────────────────────────────────┐ │
│  │ 👤 John's Plumbing                                    │ │
│  │ Service: Pipe Repair                                  │ │
│  │ Date: Nov 18, 2025   Time: 10:00 AM                  │ │
│  │ Status: Accepted ✅                                   │ │
│  │ Payment: Completed ✅                                 │ │
│  │ Paid: $75.00 via PayPal                               │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔑 PayPal Sandbox Test Accounts

For testing, use these PayPal sandbox accounts:

### Personal Account (Buyer - for customers):
- Find in: https://developer.paypal.com/dashboard/
- Go to: Sandbox → Accounts
- Look for: Personal Account
- Use the email and password shown there to log in during payment

### Business Account (Seller - to receive payments):
- Same location as above
- This is where the money goes (in test mode)

---

## 💡 Key Features

✅ **Automatic Amount Calculation**: Booking amount is set from provider's service fee  
✅ **Payment Button**: Only shows when booking is accepted  
✅ **Real-time Updates**: Payment status updates immediately  
✅ **PayPal Integration**: Full PayPal checkout experience  
✅ **Payment Tracking**: Stores PayPal order ID and payer ID  
✅ **Secure**: All endpoints require authentication  

---

## 🎨 Payment Status Colors

- 🟡 **Pending** (Yellow/Orange): Waiting for payment
- 🟢 **Completed** (Green): Payment successful
- 🔴 **Failed** (Red): Payment failed

---

## 📊 Database Tables

### Bookings Table
```
id | user_id | provider_id | service | amount | payment_status | paypal_order_id
---|---------|-------------|---------|--------|----------------|----------------
1  | 5       | 3           | Plumber | 75.00  | completed      | ORDER-123...
2  | 7       | 3           | Plumber | 75.00  | pending        | null
```

### Service Providers Table
```
id | user_id | service | service_fee
---|---------|---------|------------
1  | 10      | Plumber | 75.00
2  | 15      | Painter | 60.00
```

---

## 🐛 Troubleshooting

### Payment button not showing?
- Check booking status is 'accepted'
- Check payment_status is 'pending'
- Verify amount is set in database

### PayPal error?
- Verify credentials in `paypal_service.dart`
- Check internet connection
- Make sure using sandbox credentials with sandbox environment

### Database error?
- Run migrations: `php artisan migrate`
- Check database connection in `.env`

---

## 📚 Documentation Files

1. **`PAYMENT_IMPLEMENTATION_SUMMARY.md`** - Complete technical details
2. **`PAYPAL_SETUP_GUIDE.md`** - Detailed setup instructions
3. **This file** - Quick reference and visual guide

---

## 🎯 Ready to Test!

Everything is set up and ready. Just run the migrations and start testing!

```bash
# Start backend
cd laravel-backend
php artisan serve

# In another terminal, run Flutter app
cd task_connect_app
flutter run
```

Happy testing! 🚀
