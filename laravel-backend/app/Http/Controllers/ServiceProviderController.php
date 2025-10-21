<?php

namespace App\Http\Controllers;

use App\Models\ServiceProvider;
use Illuminate\Http\Request;

class ServiceProviderController extends Controller
{
    public function index()
    {
        $serviceProviders = ServiceProvider::with('user')->get();

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

            // Convert filenames to API URLs
            $provider->images = array_map(
                fn($img) => url('api/image/' . $img),
                $images
            );

            return $provider;
        });

        return response()->json([
            'data' => $serviceProviders
        ]);
    }

    /**
     * Serve an image from the public/images folder
     */
    public function showImage($filename)
    {
        $path = public_path('images/' . $filename);

        if (!file_exists($path)) {
            return response()->json(['error' => 'File not found'], 404);
        }

        return response()->file($path);
    }
}