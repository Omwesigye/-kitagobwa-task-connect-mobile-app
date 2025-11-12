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

            // Convert image paths to full URLs
            // Images can be stored in storage (provider-photos/...) or public/images
            $provider->images = array_map(function ($img) {
                // If it's already a full URL, return as is
                if (filter_var($img, FILTER_VALIDATE_URL)) {
                    return $img;
                }
                
                // Get the base URL from config
                $baseUrl = config('app.url');
                // Fallback to request if config is not set
                if (empty($baseUrl) || $baseUrl === 'http://localhost') {
                    $baseUrl = request()->getSchemeAndHttpHost();
                }
                
                // Check if it's a storage path (starts with provider-photos/)
                if (strpos($img, 'provider-photos/') === 0) {
                    // Storage::url returns /storage/provider-photos/...
                    $storageUrl = Storage::url($img);
                    // Ensure we return a full URL
                    return rtrim($baseUrl, '/') . $storageUrl;
                }
                
                // Legacy support: if it's just a filename, try public/images first
                $publicPath = public_path('images/' . $img);
                if (file_exists($publicPath)) {
                    return rtrim($baseUrl, '/') . '/images/' . $img;
                }
                
                // Try storage (for any other storage path)
                if (Storage::disk('public')->exists($img)) {
                    $storageUrl = Storage::url($img);
                    return rtrim($baseUrl, '/') . $storageUrl;
                }
                
                // Fallback to old API route
                return rtrim($baseUrl, '/') . '/api/image/' . $img;
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