<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\BookingController;
use App\Http\Controllers\ServiceProviderController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\RatingController;
use App\Http\Controllers\Api\ChatController;
use App\Http\Controllers\Api\ProviderProfileController; // --- 1. ADD THIS IMPORT ---

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// --- PUBLIC ROUTES ---
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/reports', [ReportController::class, 'store']);
Route::post('/ratings', [RatingController::class, 'store']);
Route::get('/service-providers', [ServiceProviderController::class, 'index']);
Route::get('/providers', [ServiceProviderController::class, 'index']);
Route::get('/image/{filename}', [ServiceProviderController::class, 'showImage']);
// Chat routes
Route::post('/chat/send', [ChatController::class, 'sendMessage']);
Route::get('/chat/history/{userId}/{contactId}', [ChatController::class, 'getConversation']);


// --- PROTECTED ROUTES (User must be logged in) ---
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);

    // Admin routes
    Route::get('/admin/pending-providers', [AdminController::class, 'pendingProviders']);
    Route::post('/admin/approve-provider/{id}', [AdminController::class, 'approveProvider']);
    
    // --- CHAT (Get Conversations) ---
    Route::get('/chat/conversations', [ChatController::class, 'getConversations']);

    // --- BOOKING ROUTES ---
    Route::post('/bookings', [BookingController::class, 'store']); 
    Route::get('/bookings', [BookingController::class, 'index']); 
    Route::delete('/bookings/{id}', [BookingController::class, 'destroy']); 
    Route::get('/provider/bookings', [BookingController::class, 'getProviderBookings']);
    Route::post('/bookings/{id}/accept', [BookingController::class, 'acceptBooking']);
    Route::post('/bookings/{id}/decline', [BookingController::class, 'declineBooking']);
    Route::post('/bookings/{id}/complete', [BookingController::class, 'completeBooking']);

    // --- Provider Profile Routes ---
    Route::get('/provider/profile', [ProviderProfileController::class, 'show']);
    Route::post('/provider/profile', [ProviderProfileController::class, 'update']);

    // --- 2. ADD THESE NEW PHOTO ROUTES ---
    // Get all photos for the provider
    Route::get('/provider/photos', [ProviderProfileController::class, 'getPhotos']);
    // Upload a new photo
    Route::post('/provider/photos', [ProviderProfileController::class, 'uploadPhoto']);
    // Delete a photo (using POST for simplicity, as HTML forms don't support DELETE for files)
    Route::post('/provider/photos/delete', [ProviderProfileController::class, 'deletePhoto']);
    Route::get('/provider/ratings', [ProviderProfileController::class, 'getRatings']);
    // ------------------------------------
});

