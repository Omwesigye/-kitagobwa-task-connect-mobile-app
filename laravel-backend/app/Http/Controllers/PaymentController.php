<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Booking;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class PaymentController extends Controller
{
    /**
     * Get PayPal configuration
     */
    public function getPayPalConfig()
    {
        return response()->json([
            'client_id' => env('PAYPAL_SANDBOX_CLIENT_ID'),
            'mode' => env('PAYPAL_MODE', 'sandbox'),
            'currency' => env('PAYPAL_CURRENCY', 'USD'),
        ]);
    }

    /**
     * Process a payment for a booking
     */
    public function processPayment(Request $request)
    {
        $request->validate([
            'booking_id' => 'required|exists:bookings,id',
            'amount' => 'required|numeric|min:0',
            'payment_method' => 'required|string',
            'paypal_order_id' => 'nullable|string',
            'paypal_payer_id' => 'nullable|string',
        ]);

        try {
            $booking = Booking::findOrFail($request->booking_id);

            // Update booking with payment information
            $booking->update([
                'amount' => $request->amount,
                'payment_status' => 'completed',
                'payment_method' => $request->payment_method,
                'paypal_order_id' => $request->paypal_order_id,
                'paypal_payer_id' => $request->paypal_payer_id,
                'paid_at' => Carbon::now(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Payment processed successfully',
                'data' => $booking
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to process payment',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get payment status for a booking
     */
    public function getPaymentStatus($bookingId)
    {
        try {
            $booking = Booking::findOrFail($bookingId);

            return response()->json([
                'success' => true,
                'data' => [
                    'booking_id' => $booking->id,
                    'amount' => $booking->amount,
                    'payment_status' => $booking->payment_status,
                    'payment_method' => $booking->payment_method,
                    'paid_at' => $booking->paid_at,
                ]
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Booking not found',
                'error' => $e->getMessage()
            ], 404);
        }
    }

    /**
     * Update payment status (for webhook or manual updates)
     */
    public function updatePaymentStatus(Request $request, $bookingId)
    {
        $request->validate([
            'payment_status' => 'required|in:pending,completed,failed',
        ]);

        try {
            $booking = Booking::findOrFail($bookingId);
            
            $booking->update([
                'payment_status' => $request->payment_status,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Payment status updated successfully',
                'data' => $booking
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to update payment status',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
