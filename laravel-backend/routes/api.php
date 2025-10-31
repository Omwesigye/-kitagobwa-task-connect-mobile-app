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
<<<<<<< HEAD
use App\Http\Controllers\Api\ProviderProfileController; // --- 1. ADD THIS IMPORT ---
=======
use App\Http\Controllers\Api\ProviderProfileController;
>>>>>>> 442766b (Add admin home and reports screens + backend models for messages, ratings, and reports)

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
<<<<<<< HEAD
*/

// --- PUBLIC ROUTES ---
=======
|
| Here is where you can register API routes for your application. 
| These routes are loaded by the RouteServiceProvider within a group 
| which is assigned the "api" middleware group. Enjoy building your API!
|
*/

// --------------------
// PUBLIC ROUTES
// --------------------
>>>>>>> 442766b (Add admin home and reports screens + backend models for messages, ratings, and reports)
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

<<<<<<< HEAD

// --- PROTECTED ROUTES (User must be logged in) ---
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);

    // Admin routes
    Route::get('/admin/pending-providers', [AdminController::class, 'pendingProviders']);
    Route::post('/admin/approve-provider/{id}', [AdminController::class, 'approveProvider']);
    
    // --- CHAT (Get Conversations) ---
    Route::get('/chat/conversations', [ChatController::class, 'getConversations']);

    // --- BOOKING ROUTES ---
=======
Route::post('/reports', [ReportController::class, 'store']);
Route::post('/ratings', [RatingController::class, 'store']);

Route::get('/service-providers', [ServiceProviderController::class, 'index']);
Route::get('/providers', [ServiceProviderController::class, 'index']); // Alias
Route::get('/image/{filename}', [ServiceProviderController::class, 'showImage']);

// Chat routes
Route::post('/chat/send', [ChatController::class, 'sendMessage']);
Route::get('/chat/history/{userId}/{contactId}', [ChatController::class, 'getConversation']);


// --------------------
// PROTECTED ROUTES (Authenticated Users)
// --------------------
Route::middleware('auth:sanctum')->group(function () {

    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);

    // --------------------
    // ADMIN ROUTES
    // --------------------
    Route::prefix('admin')->group(function () {
            // Reports
            Route::get('/reports', [ReportController::class, 'index']);
        // Pending service providers
        Route::get('/pending-providers', [AdminController::class, 'pendingProviders']);
        // Approve a provider
        Route::post('/approve-provider/{id}', [AdminController::class, 'approveProvider']);
        // Users management
        Route::get('/users', [AdminController::class, 'users']);
        Route::delete('/users/{id}', [AdminController::class, 'deleteUser']);
        // Providers management
        Route::get('/providers', [AdminController::class, 'allProviders']);
        Route::delete('/providers/{id}', [AdminController::class, 'deleteProvider']);
        // Bookings management
        Route::get('/bookings', [AdminController::class, 'bookings']);
        Route::post('/bookings/{id}/status', [AdminController::class, 'updateBookingStatus']); // custom method
    });

    // --------------------
    // BOOKING ROUTES
    // --------------------
>>>>>>> 442766b (Add admin home and reports screens + backend models for messages, ratings, and reports)
    Route::post('/bookings', [BookingController::class, 'store']); 
    Route::get('/bookings', [BookingController::class, 'index']); 
    Route::delete('/bookings/{id}', [BookingController::class, 'destroy']); 
    Route::get('/provider/bookings', [BookingController::class, 'getProviderBookings']);
    Route::post('/bookings/{id}/accept', [BookingController::class, 'acceptBooking']);
    Route::post('/bookings/{id}/decline', [BookingController::class, 'declineBooking']);
    Route::post('/bookings/{id}/complete', [BookingController::class, 'completeBooking']);

<<<<<<< HEAD
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

=======
    // --------------------
    // PROVIDER PROFILE ROUTES
    // --------------------
    Route::get('/provider/profile', [ProviderProfileController::class, 'show']);
    Route::post('/provider/profile', [ProviderProfileController::class, 'update']);
    
    // Provider photos
    Route::get('/provider/photos', [ProviderProfileController::class, 'getPhotos']);
    Route::post('/provider/photos', [ProviderProfileController::class, 'uploadPhoto']);
    Route::post('/provider/photos/delete', [ProviderProfileController::class, 'deletePhoto']);

    // Provider ratings
    Route::get('/provider/ratings', [ProviderProfileController::class, 'getRatings']);

    // --------------------
    // CHAT ROUTES
    // --------------------
    Route::get('/chat/conversations', [ChatController::class, 'getConversations']);
});
>>>>>>> 442766b (Add admin home and reports screens + backend models for messages, ratings, and reports)
