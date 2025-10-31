<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\ServiceProvider;
use App\Models\Rating; // --- 1. ADD THIS IMPORT ---
use Illuminate\Support\Facades\Storage; 

class ProviderProfileController extends Controller
{
    /**
     * Get the current provider's profile data.
     */
    public function show(Request $request)
    {
        // Get the logged-in user and their linked provider profile
        $user = $request->user();
        $provider = $user->serviceProvider; // Uses the relationship from User.php

        if (!$provider) {
            return response()->json(['message' => 'Service provider profile not found.'], 404);
        }

        // Return a combined object of user and provider data
        return response()->json([
            'name' => $user->name,
            'email' => $user->email,
            'location' => $provider->location,
            'telnumber' => $provider->telnumber,
            'description' => $provider->description,
        ]);
    }

    /**
     * Update the current provider's profile.
     */
    public function update(Request $request)
    {
        $user = $request->user();
        $provider = $user->serviceProvider;

        if (!$provider) {
            return response()->json(['message' => 'Service provider profile not found.'], 404);
        }

        // Validate the incoming data
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'location' => 'required|string|max:255',
            'telnumber' => 'required|string|max:20',
            'description' => 'required|string|min:10',
        ]);

        // 1. Update the User model (for name)
        $user->update([
            'name' => $validated['name'],
        ]);

        // 2. Update the ServiceProvider model (for other details)
        $provider->update([
            'location' => $validated['location'],
            'telnumber' => $validated['telnumber'],
            'description' => $validated['description'],
        ]);

        return response()->json(['message' => 'Profile updated successfully!']);
    }

    /**
     * Get the provider's current list of photos.
     */
    public function getPhotos(Request $request)
    {
        $provider = $request->user()->serviceProvider;
        if (!$provider) {
            return response()->json(['message' => 'Service provider profile not found.'], 404);
        }
        
        // 'images' is a cast-as-array column from your ServiceProvider model
        return response()->json($provider->images ?? []); 
    }

    /**
     * Upload a new photo for the provider.
     */
    public function uploadPhoto(Request $request)
    {
        $request->validate([
            'photo' => 'required|image|mimes:jpeg,png,jpg|max:2048', // 2MB max
        ]);

        $provider = $request->user()->serviceProvider;
        if (!$provider) {
            return response()->json(['message' => 'Service provider profile not found.'], 404);
        }

        // Store the file in 'storage/app/public/provider-photos'
        // You must run 'php artisan storage:link' for this to be web-accessible
        $path = $request->file('photo')->store('provider-photos', 'public');

        // Add the new photo path to the 'images' JSON array
        // The 'images' attribute is cast to an array in your model
        $images = $provider->images ?? [];
        $images[] = $path;
        $provider->images = $images;
        $provider->save();

        return response()->json([
            'message' => 'Photo uploaded successfully!',
            'path' => $path
        ], 201);
    }

    /**
     * Delete a photo for the provider.
     */
    public function deletePhoto(Request $request)
    {
        $request->validate([
            'filename' => 'required|string',
        ]);

        $provider = $request->user()->serviceProvider;
        if (!$provider) {
            return response()->json(['message' => 'Service provider profile not found.'], 404);
        }

        $filename = $request->filename;

        // 1. Check if the file is in the provider's list
        $images = $provider->images ?? [];
        if (!in_array($filename, $images)) {
            return response()->json(['message' => 'File not found for this provider.'], 404);
        }

        // 2. Remove the file from storage
        Storage::disk('public')->delete($filename);

        // 3. Remove the filename from the 'images' array in the database
        $provider->images = array_values(array_filter($images, function ($image) use ($filename) {
            return $image !== $filename;
        }));
        $provider->save();

        return response()->json(['message' => 'Photo deleted successfully!']);
    }

    // --- 2. ADD THIS NEW FUNCTION ---
    /**
     * Get all ratings and comments for the provider.
     */
    public function getRatings(Request $request)
    {
        $provider = $request->user()->serviceProvider;
        if (!$provider) {
            return response()->json(['message' => 'Service provider profile not found.'], 404);
        }

        // Get all ratings, and also fetch the 'user' (customer) who wrote it
        // We also get the provider's own average rating
        $ratings = Rating::where('provider_id', $provider->id)
                            ->with('user:id,name') // Select only the id and name of the user
                            ->orderBy('created_at', 'desc')
                            ->get();
        
        $averageRating = $provider->rating;

        return response()->json([
            'average_rating' => $averageRating,
            'ratings' => $ratings,
        ]);
    }
}

