<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\ServiceProvider;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    // Register user or service provider
    public function register(Request $request)
    {
        // --- THIS IS YOUR CORRECT, EXISTING CODE ---
        $validator = Validator::make($request->all(), [
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
            // Optional images list (filenames/paths) provided at registration time
            'images' => 'nullable|array',
            'images.*' => 'string',
        ]);

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
            // 'is_approved' will be 0 by default
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

            // Set images after create to avoid mass-assignment issues
            if (is_array($request->images) && !empty($request->images)) {
                $provider->images = $request->images;
                $provider->save();
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Registration successful. Service providers must await admin approval.',
            'user' => $user
        ], 201);
    }

    // Login endpoint (handles both user & service provider)
    public function login(Request $request)
    {
        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json(['message' => 'User not found'], 404);
        }

        if ($user->role === 'user') {
            // Normal email + password login
            if (!Hash::check($request->password, $user->password)) {
                return response()->json(['message' => 'Invalid credentials'], 401);
            }
        }

        if ($user->role === 'service_provider') {
            // Service provider login with code
            if (!$user->is_approved) {
                return response()->json(['message' => 'Your account is not yet approved'], 403);
            }

            if (!isset($request->login_code) || $user->login_code !== $request->login_code) {
                return response()->json(['message' => 'Invalid login code'], 401);
            }

            // --- 
            // --- THIS IS THE FIX: We comment out these two lines ---
            // Clear login code after use
            // $user->login_code = null;
            // $user->save();
            // ---
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login successful',
            'token' => $token,
            'role' => $user->role,
            'user' => $user,
        ]);
    }

    // Optional logout
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logged out successfully.']);
    }
}

