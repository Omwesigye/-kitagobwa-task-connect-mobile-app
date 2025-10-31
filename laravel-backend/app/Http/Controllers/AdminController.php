<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\ServiceProvider;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use App\Mail\ProviderOTPMail;

class AdminController extends Controller
{
    // ---------------- Users ----------------
    public function users() {
        return response()->json(User::all());
    }

    public function deleteUser($id) {
        $user = User::findOrFail($id);
        $user->delete();
        return response()->json(['message' => 'User deleted']);
    }

    // ---------------- Bookings ----------------
    public function bookings() {
        return response()->json(\App\Models\Booking::with('user', 'serviceProvider')->get());
    }

    public function updateBookingStatus(Request $request, $id) {
        $booking = \App\Models\Booking::findOrFail($id);
        $request->validate(['status' => 'required|string']);
        $booking->status = $request->status;
        $booking->save();
        return response()->json(['message' => 'Booking updated', 'booking' => $booking]);
    }

    // ---------------- Service Providers ----------------
    // List all service providers
    public function allProviders() {
        $providers = ServiceProvider::with('user')->get();
        return response()->json($providers);
    }

    // List pending providers only
    public function pendingProviders() {
        $providers = ServiceProvider::with('user')->whereHas('user', function($q){
            $q->where('is_approved', 0);
        })->get();

        return response()->json($providers);
    }

public function approveProvider($id)
{
    // Find the provider
    $provider = ServiceProvider::with('user')->findOrFail($id);
    $user = $provider->user;

    if (!$user) {
        return response()->json(['message' => 'User not found for this provider'], 404);
    }

    // Update provider and user as approved
    $user->is_approved = 1;
    $user->save();

    // Generate a login OTP if not already set
    if (!$user->login_code) {
        $user->login_code = rand(100000, 999999);
        $user->save();
    }

    // Send OTP email inline (no Blade)
    \Mail::to($user->email)->send(new \App\Mail\ProviderOTPMail($user->login_code));

    return response()->json([
        'message' => 'Provider approved and OTP sent',
        'provider' => $provider,
        'otp' => $user->login_code // optional: for testing in Flutter
    ]);
}



    // Add a provider
    public function addProvider(Request $request) {
        $request->validate([
            'name' => 'required|string',
            'email' => 'required|email|unique:users,email',
            'location' => 'required|string',
            'nin' => 'required|string',
            'telnumber' => 'required|string',
            'service' => 'required|string',
            'description' => 'nullable|string',
            'images' => 'nullable|array',
        ]);

        // Generate OTP
        $otp = rand(100000, 999999);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'role' => 'provider',
            'login_code' => $otp,
            'is_approved' => 0, // Pending approval
            'password' => Hash::make(''), // provider sets later
        ]);

        $provider = ServiceProvider::create([
            'user_id' => $user->id,
            'location' => $request->location,
            'nin' => $request->nin,
            'telnumber' => $request->telnumber,
            'service' => $request->service,
            'description' => $request->description,
            'images' => $request->images ?? [],
        ]);

        // Send OTP email
        Mail::to($user->email)->send(new ProviderOTPMail($otp));

        return response()->json([
            'user' => $user,
            'provider' => $provider,
            'message' => 'Provider added and OTP sent'
        ]);
    }

    // Delete a provider
    public function deleteProvider($id) {
        $provider = ServiceProvider::findOrFail($id);
        $provider->user()->delete(); // Delete linked user first
        $provider->delete();
        return response()->json(['message' => 'Provider deleted']);
    }
}