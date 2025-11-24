<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\ServiceProvider;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;
// --- 1. ADD THESE IMPORTS ---
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Mail;
use App\Mail\ProviderOTPMail;
// ----------------------------

class AuthController extends Controller
{
    // --- 2. KEEPING YOUR TEAM'S register FUNCTION ---
    // Register user or service provider
    public function register(Request $request)
    {
        // Determine validation rules based on whether files are being uploaded
        $hasFiles = $request->hasFile('images');
        
        $rules = [
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users',
            'password' => 'required|min:6',
            'role' => 'required|in:user,service_provider',
            
            // Provider-specific rules
            'location' => 'required_if:role,service_provider|string',
            'nin' => 'required_if:role,service_provider|string|unique:service_providers',
            'telnumber' => 'required_if:role,service_provider|string',
            'service' => 'required_if:role,service_provider|string',
            'description' => 'nullable|string',
        ];

        // Require images for service providers
        if ($request->role === 'service_provider') {
            if ($hasFiles) {
                // If files are being uploaded, validate them
                $rules['images'] = 'required|array|min:1';
                $rules['images.*'] = 'required|image|mimes:jpeg,png,jpg,gif|max:2048'; // 2MB max per image
            } else {
                // For service providers, require at least one image (legacy support)
                $rules['images'] = 'required|array|min:1';
                $rules['images.*'] = 'required|string';
            }
        } else {
            // Regular users don't need images
            $rules['images'] = 'nullable|array';
            $rules['images.*'] = 'nullable|string';
        }

        $validator = Validator::make($request->all(), $rules);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => $request->role,
            // 'is_approved' will be 0 by default for provider, 1 for user (from migration)
            'is_approved' => $request->role == 'user' ? 1 : 0, 
        ]);

        if ($request->role === 'service_provider') {
            $provider = ServiceProvider::create([
                'user_id' => $user->id,
                'location' => $request->location,
                'nin' => $request->nin,
                'telnumber' => $request->telnumber,
                'service' => $request->service,
                'description' => $request->description,
            ]);

            // Handle image uploads
            $imagePaths = [];
            
            if ($hasFiles && $request->hasFile('images')) {
                // Handle file uploads
                foreach ($request->file('images') as $image) {
                    // Store in storage/app/public/provider-photos
                    $path = $image->store('provider-photos', 'public');
                    $imagePaths[] = $path;
                }
            } elseif (is_array($request->images) && !empty($request->images)) {
                // Legacy support: if images are provided as array of strings (filenames)
                $imagePaths = $request->images;
            }

            // Save image paths to database
            if (!empty($imagePaths)) {
                $provider->images = $imagePaths;
                $provider->save();
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Registration successful. Service providers must await admin approval.',
            'user' => $user
        ], 201);
    }
    // --- END OF YOUR register FUNCTION ---


    // --- 3. REPLACING WITH THE CORRECTED login FUNCTION ---
    /**
     * Log in a user.
     */
    public function login(Request $request)
    {
        // This validation checks the 'role' from Flutter
        $fields = $request->validate([
            'email' => 'required|string|email',
            'password' => 'required_if:role,user,admin|string|nullable',
            'login_code' => 'required_if:role,service_provider|string|nullable',
            'role' => 'required|string|in:user,service_provider,admin', // Add 'admin'
        ]);

        // Find the user by email
        $user = User::where('email', $fields['email'])->first();

        // Check if user exists AND if their database role matches the role they are logging in as
        if (!$user || $user->role !== $fields['role']) {
            return response(['message' => 'Invalid credentials or role mismatch'], 401);
        }

        // Check credentials based on role
        if ($fields['role'] == 'user' || $fields['role'] == 'admin') {
            // User or Admin: Check password
            if (!Hash::check($fields['password'], $user->password)) {
                return response(['message' => 'Invalid credentials'], 401);
            }
        } else if ($fields['role'] == 'service_provider') {
            // Service Provider: Check login code
            if (!$user->login_code || $user->login_code !== $fields['login_code']) {
                return response(['message' => 'Invalid login code'], 401);
            }
            
            // Check if provider is approved
            if ($user->is_approved == 0) {
                return response(['message' => 'Your account is not yet approved'], 401);
            }
        }

        // Credentials are correct, create token
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login successful',
            'token' => $token,
            'role' => $user->role, // Send the role back
            'user' => $user,
        ], 200);
    }
    // --- END OF CORRECTED login FUNCTION ---


    // --- 4. KEEPING YOUR TEAM'S logout FUNCTION ---
    // Optional logout
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logged out successfully.']);
    }
}