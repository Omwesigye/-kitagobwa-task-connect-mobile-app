<?php

// --- THIS LINE IS NOW FIXED ---
namespace App\Http\Controllers\Api;
// ------------------------------

use App\Http\Controllers\Controller;
use App\Models\Rating;
use App\Models\ServiceProvider; // Make sure this path is correct
use Illuminate\Http\Request;

class RatingController extends Controller
{
    /**
     * Store a newly created rating in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        // 1. Validate the data from Flutter
        $validated = $request->validate([
            'user_id'     => 'required|exists:users,id',
            'provider_id' => 'required|exists:service_providers,id',
            'booking_id'  => 'required|exists:bookings,id|unique:ratings,booking_id',
            'rating'      => 'required|integer|min:1|max:5',
            'comment'     => 'nullable|string',
        ]);

        // 2. Create the new rating in the 'ratings' table
        $rating = Rating::create([
            'user_id'     => $validated['user_id'],
            'provider_id' => $validated['provider_id'],
            'booking_id'  => $validated['booking_id'],
            'rating'      => $validated['rating'],
            'comment'     => $validated['comment'],
        ]);

        // 3. Recalculate the provider's new average rating
        $newAverage = Rating::where('provider_id', $validated['provider_id'])
                            ->avg('rating');

        // 4. Find the provider and update their 'rating' column
        $provider = ServiceProvider::findOrFail($validated['provider_id']);
        $provider->rating = $newAverage;
        $provider->save();

        // 5. Send a success response
        return response()->json([
            'message' => 'Thank you for your review!',
            'data'    => $rating,
        ], 201); // 201 = "Created"
    }
}

