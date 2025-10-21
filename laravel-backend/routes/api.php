<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\BookingController;
use App\Http\Controllers\ServiceProviderController;

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected routes (need Sanctum token)
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);

    // Admin routes
    Route::get('/admin/pending-providers', [AdminController::class, 'pendingProviders']);
    Route::post('/admin/approve-provider/{id}', [AdminController::class, 'approveProvider']);
});


Route::post('/bookings', [BookingController::class, 'store']); // Create booking
Route::get('/bookings', [BookingController::class, 'index']); // List bookings
Route::post('/bookings/{id}/confirm', [BookingController::class, 'confirm']); // Provider confirms
Route::delete('/bookings/{id}', [BookingController::class, 'destroy']); // Delete booking

// Service providers listing (public)
Route::get('/service-providers', [ServiceProviderController::class, 'index']);
Route::get('/providers', [ServiceProviderController::class, 'index']);

// Serve provider images
Route::get('/image/{filename}', [ServiceProviderController::class, 'showImage']);


// images URL handling in ServiceProviderController
Route::get('/image/{filename}', function ($filename) {
    $path = public_path('images/' . $filename);

    if (!file_exists($path)) {
        return response()->json(['error' => 'File not found'], 404);
    }

    return response()->file($path);
});