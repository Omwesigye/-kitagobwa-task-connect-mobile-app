<?php

namespace App\Http\Controllers;

use App\Models\ServiceProvider;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ServiceProviderController extends Controller
{
    public function index()
    {
        // Only get approved service providers
        $serviceProviders = ServiceProvider::with('user')
            ->whereHas('user', function($query) {
                $query->where('role', 'service_provider')
                      ->where('is_approved', true);
            })
            ->get();

        $serviceProviders->transform(function ($provider) {
            $images = [];

            // Safely handle images: JSON string or array
            if (is_string($provider->images)) {
                $decoded = json_decode($provider->images, true);
                if (is_array($decoded)) {
                    $images = $decoded;
                }
            } elseif (is_array($provider->images)) {
                $images = $provider->images;
            }

            // ✅ FIXED: Return RELATIVE paths only, let Flutter handle the base URL
            $provider->images = array_map(function ($img) {
                // If it's already a full URL, strip it to relative path
                if (filter_var($img, FILTER_VALIDATE_URL)) {
                    // Extract just the path part after the domain
                    $parsed = parse_url($img);
                    $path = $parsed['path'] ?? '';
                    // Remove leading slash if present
                    return ltrim($path, '/');
                }
                
                // If it starts with /storage/, remove the leading slash
                if (strpos($img, '/storage/') === 0) {
                    return ltrim($img, '/');
                }
                
                // Check 1: New system images (e.g., "provider-photos/new.jpg")
                if (strpos($img, 'provider-photos/') === 0) {
                    return 'storage/' . $img;
                }
                
                // Check 2: Old system images (e.g., "plumber.jpg")
                if (file_exists(public_path('images/' . $img))) {
                    return 'images/' . $img;
                }
                
                // Fallback for any other path in storage
                if (Storage::disk('public')->exists($img)) {
                    return 'storage/' . $img;
                }
                
                // If file is not found, return as-is
                return $img;

            }, $images);

            return $provider;
        });

        return response()->json([
            'data' => $serviceProviders
        ]);
    }

    /**
     * Serve an image from storage or public/images folder
     */
    public function showImage($path)
    {
        $sanitized = ltrim($path, '/');

        // Try storage first (for provider-photos)
        if (Storage::disk('public')->exists($sanitized)) {
            $fullPath = Storage::disk('public')->path($sanitized);
            return response()->file($fullPath);
        }
        
        // Try public/images (legacy support)
        $publicPath = public_path('images/' . basename($sanitized));
        if (file_exists($publicPath)) {
            return response()->file($publicPath);
        }

        return response()->json(['error' => 'File not found'], 404);
    }
}