# PayPal Payment Integration - Setup Guide

This guide will help you configure PayPal payments for your Task Connect mobile app.

## Overview

The PayPal payment integration allows customers to pay for services after a booking has been accepted by the service provider. The payment flow is:

1. Customer creates a booking
2. Service provider accepts the booking
3. Customer sees a "Pay with PayPal" button
4. Customer completes payment through PayPal
5. Payment status is updated in the backend

## Prerequisites

- PayPal Developer Account
- Laravel backend with database access
- Flutter development environment

## Part 1: PayPal Setup

### Step 1: Create PayPal Developer Account

1. Go to https://developer.paypal.com/
2. Sign up or log in with your PayPal account
3. Navigate to "Dashboard" → "My Apps & Credentials"

### Step 2: Create a PayPal App

1. Click "Create App" button
2. Enter an app name (e.g., "Task Connect Payments")
3. Select "Merchant" as the app type
4. Click "Create App"

### Step 3: Get Your Credentials

After creating the app, you'll see two important credentials:

- **Client ID**: A long string starting with `A...`
- **Secret**: A long string (click "Show" to reveal)

You'll have two sets of credentials:
- **Sandbox** credentials (for testing)
- **Live** credentials (for production)

Start with Sandbox credentials for testing.

### Step 4: Configure Flutter App

1. Open `task_connect_app/lib/services/paypal_service.dart`
2. Replace the placeholder values:

```dart
static const String _clientId = 'YOUR_ACTUAL_CLIENT_ID_HERE';
static const String _secretKey = 'YOUR_ACTUAL_SECRET_KEY_HERE';
```

3. Keep `_environment` as `'sandbox'` for testing:

```dart
static const String _environment = 'sandbox'; // Change to 'production' for live
```

## Part 2: Database Setup

### Step 1: Start Your Database Server

Make sure your MySQL server is running (XAMPP, WAMP, or standalone MySQL).

### Step 2: Run Migrations

Open a terminal in your Laravel project directory and run:

```bash
cd laravel-backend
php artisan migrate
```

This will create the necessary database tables with payment fields.

### Step 3: Set Service Fees (Optional)

You can set service fees for each provider by adding the `service_fee` field to the service providers:

```sql
UPDATE service_providers SET service_fee = 50.00 WHERE id = 1;
```

Or through your admin panel (if you have one).

## Part 3: Flutter Dependencies

### Step 1: Install Dependencies

In your Flutter project directory:

```bash
cd task_connect_app
flutter pub get
```

This will install the PayPal packages added to `pubspec.yaml`.

### Step 2: Test the Integration

1. Start your Laravel backend server
2. Run your Flutter app
3. Log in as a customer
4. Create a booking with a service provider
5. Wait for the provider to accept the booking
6. You should see a "Pay with PayPal" button on the booking card
7. Click the button to test the payment flow

## Part 4: Testing with PayPal Sandbox

### Step 1: Create Test Accounts

1. Go to https://developer.paypal.com/dashboard/
2. Navigate to "Sandbox" → "Accounts"
3. You'll see pre-created test accounts:
   - **Business Account** (for receiving payments)
   - **Personal Account** (for making payments)

### Step 2: Get Test Credentials

Click on the Personal Account and note the email and password. You'll use these to log in during testing.

### Step 3: Test a Payment

1. In your app, click "Pay with PayPal"
2. Log in with your sandbox personal account credentials
3. Complete the payment
4. The payment should be processed and the booking status updated

### Step 4: Verify Payment

Check your PayPal Sandbox dashboard to see the transaction:
1. Go to https://developer.paypal.com/dashboard/
2. Navigate to "Sandbox" → "Accounts"
3. Click on the Business account
4. Click "View/Edit" → "Dashboard"
5. You should see the transaction listed

## Part 5: Going Live (Production)

### Step 1: Get Live Credentials

1. Go to your PayPal Developer Dashboard
2. Switch from "Sandbox" to "Live" mode
3. Get your Live Client ID and Secret

### Step 2: Update Flutter App

In `paypal_service.dart`:

```dart
static const String _clientId = 'YOUR_LIVE_CLIENT_ID';
static const String _secretKey = 'YOUR_LIVE_SECRET_KEY';
static const String _environment = 'production';
```

### Step 3: Test Thoroughly

Before going live:
- Test all payment scenarios
- Test error handling
- Test refunds (if applicable)
- Verify database updates

## Troubleshooting

### Payment Button Not Showing

**Issue**: The "Pay with PayPal" button doesn't appear

**Solutions**:
1. Check that the booking status is 'accepted' by the provider
2. Verify the payment_status is 'pending'
3. Check that the amount field is set in the database

### PayPal Configuration Error

**Issue**: "PayPal is not configured" message

**Solutions**:
1. Verify you've replaced the placeholder credentials in `paypal_service.dart`
2. Make sure the credentials don't contain any extra spaces
3. Rebuild your Flutter app after making changes

### Payment Processing Error

**Issue**: Payment fails or returns an error

**Solutions**:
1. Check your internet connection
2. Verify your PayPal credentials are correct
3. Check if you're using Sandbox credentials with Sandbox accounts
4. Look at the Flutter console for detailed error messages

### Database Migration Error

**Issue**: `php artisan migrate` fails

**Solutions**:
1. Ensure your database server is running
2. Check `.env` file for correct database credentials
3. Verify the database exists
4. Try: `php artisan migrate:fresh` (WARNING: This will delete all data)

## API Endpoints

The following endpoints are available for payment processing:

### Process Payment
```
POST /api/payments/process
```
Body:
```json
{
  "booking_id": 1,
  "amount": 50.00,
  "payment_method": "paypal",
  "paypal_order_id": "ORDER_ID_FROM_PAYPAL",
  "paypal_payer_id": "PAYER_ID_FROM_PAYPAL"
}
```

### Get Payment Status
```
GET /api/payments/status/{bookingId}
```

### Update Payment Status
```
PUT /api/payments/status/{bookingId}
```
Body:
```json
{
  "payment_status": "completed"
}
```

## Database Schema

### Bookings Table (New Fields)
- `amount` (decimal) - The payment amount
- `payment_status` (string) - pending, completed, or failed
- `payment_method` (string) - paypal, card, etc.
- `paypal_order_id` (string) - PayPal transaction ID
- `paypal_payer_id` (string) - PayPal payer ID
- `paid_at` (timestamp) - When payment was completed

### Service Providers Table (New Field)
- `service_fee` (decimal) - The service fee for this provider

## Security Notes

1. **Never commit your PayPal credentials** to version control
2. Store credentials in environment variables for production
3. Always use HTTPS in production
4. Validate payment amounts on the backend
5. Implement proper error handling
6. Log all payment transactions

## Currency Support

Currently, the system uses USD. To change the currency:

1. Open `task_connect_app/lib/util/booking_card.dart`
2. Find the `_handlePayment` method
3. Change the `currency` parameter:

```dart
final result = await PayPalService.makePayment(
  context: context,
  amount: amount,
  currency: 'EUR', // Change to your currency code
  description: '${widget.service} - ${widget.providerName}',
);
```

Supported currency codes: USD, EUR, GBP, CAD, AUD, etc.

## Support

For PayPal-specific issues:
- PayPal Developer Support: https://developer.paypal.com/support/

For app-specific issues:
- Check the Flutter console for errors
- Review Laravel logs: `storage/logs/laravel.log`

## Additional Features to Consider

1. **Refunds**: Implement refund functionality for cancelled bookings
2. **Payment History**: Add a screen to view payment history
3. **Multiple Payment Methods**: Add support for credit cards, etc.
4. **Email Receipts**: Send email receipts after successful payment
5. **Admin Dashboard**: Allow admins to view all payments

## Next Steps

1. Complete PayPal setup with your credentials
2. Run database migrations
3. Test the payment flow in Sandbox mode
4. Once confirmed working, prepare for production deployment
5. Consider implementing additional features listed above

---

**Note**: Remember to run `flutter pub get` after any changes to `pubspec.yaml` and restart your app after updating PayPal credentials.
