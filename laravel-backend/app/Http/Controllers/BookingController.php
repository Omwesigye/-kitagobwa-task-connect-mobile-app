<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Booking;

class BookingController extends Controller
{
    /**
     * Store a new booking.
     */
    public function store(Request $request)
    {
        // Validate input
        $validated = $request->validate([
            'user_id' => 'required|integer|exists:users,id',
            'provider_id' => 'required|integer|exists:service_providers,id',
            'service' => 'required|string|max:255',
            'location' => 'required|string|max:255',
            'time' => 'required',
            'date' => 'required|date',
        ]);

        // Create booking with default statuses
        $booking = Booking::create([
            'user_id' => $validated['user_id'],
            'provider_id' => $validated['provider_id'],
            'service' => $validated['service'],
            'location' => $validated['location'],
            'time' => $validated['time'],
            'date' => $validated['date'],
            'user_status' => 'completed',
            'provider_status' => 'accepted',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Booking created successfully',
            'booking' => $booking,
        ]);
    }

    /**
     * List all bookings, optionally filtered by user or provider.
     */
    public function index(Request $request)
    {
        $query = Booking::with('provider', 'user');

        if ($request->has('user_id')) {
            $query->where('user_id', $request->user_id);
        }

        if ($request->has('provider_id')) {
            $query->where('provider_id', $request->provider_id);
        }

        $bookings = $query->get();

        return response()->json($bookings);
    }

    /**
     * Provider confirms the booking.
     */
    public function confirm($id)
    {
        $booking = Booking::findOrFail($id);
        $booking->provider_status = 'confirmed';
        $booking->save();

        return response()->json([
            'success' => true,
            'message' => 'Booking confirmed by provider',
            'booking' => $booking,
        ]);
    }

    /**
     * Delete a booking
     */
    public function destroy($id)
    {
        $booking = Booking::findOrFail($id);
        $booking->delete();

        return response()->json([
            'success' => true,
            'message' => 'Booking deleted successfully',
        ]);
    }
}