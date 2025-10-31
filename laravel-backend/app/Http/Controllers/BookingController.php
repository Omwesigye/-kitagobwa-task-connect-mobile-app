<?php

namespace App\Http\Controllers;

use App\Models\Booking; // Make sure Booking is imported
use Illuminate\Http\Request;
// Make sure your User model is imported
use App\Models\User; 

class BookingController extends Controller
{
    /**
     * Store a new booking (for customers).
     */
    public function store(Request $request)
    {
        // Validate input
        $validated = $request->validate([
            // 'user_id' will come from the authenticated user
            'provider_id' => 'required|integer|exists:service_providers,id',
            'service' => 'required|string|max:255',
            'location' => 'required|string|max:255',
            'time' => 'required',
            'date' => 'required|date',
            'provider_name' => 'required|string',
            'provider_image_url' => 'nullable|string',
        ]);

        // Create booking with default statuses
        $booking = Booking::create([
            'user_id' => auth()->id(), // Get the logged-in user's ID
            'provider_id' => $validated['provider_id'],
            'service' => $validated['service'],
            'location' => $validated['location'],
            'time' => $validated['time'],
            'date' => $validated['date'],
            'provider_name' => $validated['provider_name'],
            'provider_image_url' => $validated['provider_image_url'],
            'user_status' => 'pending',
            'provider_status' => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Booking created successfully',
            'booking' => $booking,
        ], 201); // 201 = "Created"
    }

    /**
     * List all bookings for the logged-in CUSTOMER.
     */
    public function index(Request $request)
    {
        // Get the logged-in user
        $user = $request->user();

        // Start query
        $query = Booking::query();

        // This is your 'My Bookings' page logic (for customers)
        $query->where('user_id', $user->id);
        
        $bookings = $query->orderBy('created_at', 'desc')->get();

        return response()->json($bookings);
    }

    /**
     * Delete a booking (for customers).
     */
    public function destroy(Request $request, $id)
    {
        $booking = Booking::findOrFail($id);
        
        // Security check: Make sure the logged-in user owns this booking
        if ($booking->user_id !== $request->user()->id) {
             return response()->json(['message' => 'Unauthorized'], 403);
        }
        
        $booking->delete();

        return response()->json([
            'success' => true,
            'message' => 'Booking deleted successfully',
        ]);
    }
    
    // -----------------------------------------------------------------
    // --- NEW PROVIDER FUNCTIONS START HERE ---
    // -----------------------------------------------------------------

    /**
     * Get all bookings for the currently logged-in PROVIDER.
     */
    public function getProviderBookings(Request $request)
    {
        // Get the logged-in user's provider profile
        $provider = $request->user()->serviceProvider;

        if (!$provider) {
            return response()->json(['message' => 'You are not a service provider'], 403);
        }

        // Find all bookings for this provider
        // We use 'with('user')' to also get the customer's name
        $bookings = Booking::where('provider_id', $provider->id)
                            ->with('user') // ⇐ This gets the customer details
                            ->orderBy('created_at', 'desc')
                            ->get();
        
        return response()->json($bookings);
    }

    /**
     * Provider accepts a booking.
     */
    public function acceptBooking(Request $request, $id)
    {
        $booking = Booking::findOrFail($id);
        $provider = $request->user()->serviceProvider;

        // Security check: Is this booking for this provider?
        if (!$provider || $booking->provider_id !== $provider->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $booking->provider_status = 'accepted';
        $booking->save();

        // You would add a notification here later
        return response()->json(['message' => 'Booking accepted', 'data' => $booking]);
    }

    /**
     * Provider declines a booking.
     */
    public function declineBooking(Request $request, $id)
    {
        $booking = Booking::findOrFail($id);
        $provider = $request->user()->serviceProvider;

        if (!$provider || $booking->provider_id !== $provider->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $booking->provider_status = 'declined';
        $booking->user_status = 'declined'; // Also notify the user
        $booking->save();

        return response()->json(['message' => 'Booking declined', 'data' => $booking]);
    }

    /**
     * Provider marks a booking as complete.
     */
    public function completeBooking(Request $request, $id)
    {
        $booking = Booking::findOrFail($id);
        $provider = $request->user()->serviceProvider;

        if (!$provider || $booking->provider_id !== $provider->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $booking->provider_status = 'completed';
        $booking->user_status = 'completed'; // Also notify the user
        $booking->save();

        return response()->json(['message' => 'Booking marked as complete', 'data' => $booking]);
    }
}

