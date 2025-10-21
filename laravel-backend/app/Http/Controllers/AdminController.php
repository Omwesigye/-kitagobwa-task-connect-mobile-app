<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Mail;

class AdminController extends Controller
{
    // List all pending service providers
    public function pendingProviders()
    {
        $providers = User::where('role', 'service_provider')
                         ->where('is_approved', false)
                         ->with('serviceProvider')
                         ->get();

        return response()->json($providers);
    }

    // Approve service provider & send login code
    public function approveProvider($id)
    {
        $user = User::where('role', 'service_provider')->findOrFail($id);

        $code = rand(100000, 999999); // 6-digit code
        $user->is_approved = true;
        $user->login_code = $code;
        $user->save();

        // Send email
        Mail::raw("Hello {$user->name}, your account has been approved! Use this code to log in: {$code}", function($message) use ($user) {
            $message->to($user->email)
                    ->subject("Service Provider Login Code");
        });

        return response()->json([
            'message' => "Service provider '{$user->name}' approved and login code sent via email."
        ]);
    }
}