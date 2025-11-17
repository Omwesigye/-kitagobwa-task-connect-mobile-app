<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\BookingController;
use App\Http\Controllers\ServiceProviderController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\RatingController;
use App\Http\Controllers\Api\ChatController;
use App\Http\Controllers\Api\ProviderProfileController;
use App\Http\Controllers\PasswordResetController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Public + Protected Routes for the API
|
*/

// --------------------
// PUBLIC ROUTES
// --------------------
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Password Reset
Route::post('/password/forgot', [PasswordResetController::class, 'requestCode']);
Route::post('/password/verify', [PasswordResetController::class, 'verifyCode']);
Route::post('/password/reset', [PasswordResetController::class, 'resetPassword']);

// Reports & Ratings
Route::post('/reports', [ReportController::class, 'store']);
Route::post('/ratings', [RatingController::class, 'store']);

// Providers
Route::get('/service-providers', [ServiceProviderController::class, 'index']);
Route::get('/providers', [ServiceProviderController::class, 'index']); // Alias

// Image fetch (wildcard path)
Route::get('/image/{path}', [ServiceProviderController::class, 'showImage'])
    ->where('path', '.*');

// Chat Public
Route::post('/chat/send', [ChatController::class, 'sendMessage']);
Route::get('/chat/history/{userId}/{contactId}', [ChatController::class, 'getConversation']);


// --------------------
// PROTECTED ROUTES (auth:sanctum)
// --------------------
Route::middleware('auth:sanctum')->group(function () {

    // Authentication
    Route::post('/logout', [AuthController::class, 'logout']);

    // ADMIN ROUTES
    Route::prefix('admin')->group(function () {
        Route::get('/reports', [ReportController::class, 'index']);

        Route::get('/pending-providers', [AdminController::class, 'pendingProviders']);
        Route::post('/approve-provider/{id}', [AdminController::class, 'approveProvider']);

        Route::get('/users', [AdminController::class, 'users']);
        Route::delete('/users/{id}', [AdminController::class, 'deleteUser']);

        Route::get('/providers', [AdminController::class, 'allProviders']);
        Route::delete('/providers/{id}', [AdminController::class, 'deleteProvider']);

        Route::get('/bookings', [AdminController::class, 'bookings']);
        Route::post('/bookings/{id}/status', [AdminController::class, 'updateBookingStatus']);
    });

    // BOOKING ROUTES
    Route::post('/bookings', [BookingController::class, 'store']);
    Route::get('/bookings', [BookingController::class, 'index']);
    Route::delete('/bookings/{id}', [BookingController::class, 'destroy']);
    Route::get('/provider/bookings', [BookingController::class, 'getProviderBookings']);
    Route::post('/bookings/{id}/accept', [BookingController::class, 'acceptBooking']);
    Route::post('/bookings/{id}/decline', [BookingController::class, 'declineBooking']);
    Route::post('/bookings/{id}/complete', [BookingController::class, 'completeBooking']);


    // --------------------
    // PAYMENT ROUTES
        Route::get('/payments/paypal-config', [PaymentController::class, 'getPayPalConfig']);
    // --------------------
    Route::post('/payments/process', [PaymentController::class, 'processPayment']);
    Route::get('/payments/status/{bookingId}', [PaymentController::class, 'getPaymentStatus']);
    Route::put('/payments/status/{bookingId}', [PaymentController::class, 'updatePaymentStatus']);

    // --------------------

    // PROVIDER PROFILE ROUTES
    Route::get('/provider/profile', [ProviderProfileController::class, 'show']);
    Route::post('/provider/profile', [ProviderProfileController::class, 'update']);

    Route::get('/provider/photos', [ProviderProfileController::class, 'getPhotos']);
    Route::post('/provider/photos', [ProviderProfileController::class, 'uploadPhoto']);
    Route::post('/provider/photos/delete', [ProviderProfileController::class, 'deletePhoto']);

    Route::get('/provider/ratings', [ProviderProfileController::class, 'getRatings']);

    // CHAT ROUTES
    Route::get('/chat/conversations', [ChatController::class, 'getConversations']);
});