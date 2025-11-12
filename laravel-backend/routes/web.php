<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\File;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

// Fallback handler to serve files in storage/app/public when the web server
// cannot follow the public/storage symlink (common on some Windows setups).
Route::get('/storage/{path}', function ($path) {
    $cleanPath = ltrim($path, '/');
    $storagePath = storage_path('app/public/' . $cleanPath);

    if (!File::exists($storagePath)) {
        abort(404);
    }

    return response()->file($storagePath);
})->where('path', '.*');
