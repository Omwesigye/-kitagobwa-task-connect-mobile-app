<?php

namespace App\Http\Controllers;

use App\Mail\PasswordResetCodeMail;
use App\Models\PasswordReset;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;

class PasswordResetController extends Controller
{
    /**
     * Handle the initial forgot password request.
     */
    public function requestCode(Request $request)
    {
        $data = $request->validate([
            'email' => 'required|email',
        ]);

        $user = User::where('email', $data['email'])->first();

        // Return generic response to avoid user enumeration
        if (!$user) {
            return response()->json([
                'message' => 'If that email is registered, a reset code has been sent.',
            ]);
        }

        $code = (string) random_int(100000, 999999);

        PasswordReset::updateOrCreate(
            ['email' => $data['email']],
            [
                'token' => Str::random(64),
                'code' => $code,
                'expires_at' => Carbon::now()->addMinutes(15),
            ]
        );

        Mail::to($data['email'])->send(new PasswordResetCodeMail($code));

        return response()->json([
            'message' => 'If that email is registered, a reset code has been sent.',
        ]);
    }

    /**
     * Verify a reset code.
     */
    public function verifyCode(Request $request)
    {
        $data = $request->validate([
            'email' => 'required|email',
            'code' => 'required|string',
        ]);

        $reset = PasswordReset::where('email', $data['email'])
            ->where('code', $data['code'])
            ->first();

        if (!$reset || Carbon::now()->greaterThan($reset->expires_at)) {
            return response()->json([
                'message' => 'Invalid or expired code.',
            ], 422);
        }

        return response()->json([
            'message' => 'Code verified.',
        ]);
    }

    /**
     * Reset the password using a verified code.
     */
    public function resetPassword(Request $request)
    {
        $data = $request->validate([
            'email' => 'required|email',
            'code' => 'required|string',
            'password' => 'required|min:6|confirmed',
        ]);

        $reset = PasswordReset::where('email', $data['email'])
            ->where('code', $data['code'])
            ->first();

        if (!$reset || Carbon::now()->greaterThan($reset->expires_at)) {
            return response()->json([
                'message' => 'Invalid or expired code.',
            ], 422);
        }

        $user = User::where('email', $data['email'])->first();

        if (!$user) {
            return response()->json([
                'message' => 'User not found.',
            ], 404);
        }

        $user->password = Hash::make($data['password']);
        $user->save();

        $reset->delete();

        return response()->json([
            'message' => 'Password updated successfully.',
        ]);
    }
}

