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
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users',
            'password' => 'required|min:6',
            'role' => 'required|in:user,service_provider',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => $request->role,
        ]);

        if ($request->role === 'service_provider') {
            $providerValidator = Validator::make($request->all(), [
                'location' => 'required|string',
                'nin' => 'required|string',
                'telnumber' => 'required|string',
                'service' => 'required|string',
                'description' => 'nullable|string',
            ]);

            if ($providerValidator->fails()) {
                $user->delete();
                return response()->json(['errors' => $providerValidator->errors()], 422);
            }

            ServiceProvider::create([
                'user_id' => $user->id,
                'location' => $request->location,
                'nin' => $request->nin,
                'telnumber' => $request->telnumber,
                'service' => $request->service,
                'description' => $request->description,
            ]);
        }

        return response()->json([
            'message' => 'Registration successful. Service providers must await admin approval.'
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

            // Clear login code after use
            $user->login_code = null;
            $user->save();
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