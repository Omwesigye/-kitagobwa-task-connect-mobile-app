<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Message;
use Illuminate\Http\Request;
use App\Models\User; // <-- 1. ADD THIS IMPORT

class ChatController extends Controller
{
    /**
     * Get the conversation history between two users.
     */
    // This is your existing, correct function
    public function getConversation($userId, $contactId)
    {
        $messages = Message::where(function ($query) use ($userId, $contactId) {
            $query->where('sender_id', $userId)
                  ->where('receiver_id', $contactId);
        })->orWhere(function ($query) use ($userId, $contactId) {
            $query->where('sender_id', $contactId)
                  ->where('receiver_id', $userId);
        })
        ->orderBy('created_at', 'asc')
        ->get();

        // Optional: Mark messages as 'read'
        Message::where('sender_id', $contactId)
               ->where('receiver_id', $userId)
               ->whereNull('read_at')
               ->update(['read_at' => now()]);

        return response()->json($messages);
    }

    /**
     * Store a new message in storage.
     */
    // This is your existing, correct function
    public function sendMessage(Request $request)
    {
        $validated = $request->validate([
            'sender_id'   => 'required|exists:users,id',
            'receiver_id' => 'required|exists:users,id',
            'content'     => 'required|string|max:1000',
        ]);

        $message = Message::create([
            'sender_id'   => $validated['sender_id'],
            'receiver_id' => $validated['receiver_id'],
            'content'     => $validated['content'],
        ]);

        return response()->json($message, 201); // 201 = Created
    }

    /**
     * Get all conversations for the logged-in user.
     */
    // --- 2. THIS IS THE NEW, MISSING FUNCTION ---
    public function getConversations(Request $request)
    {
        // 1. Get the authenticated user from the token
        $userId = $request->user()->id;

        // 2. Find all unique user IDs that this user has chatted with
        $sent = Message::where('sender_id', $userId)->pluck('receiver_id');
        $received = Message::where('receiver_id', $userId)->pluck('sender_id');
        
        $contactIds = $sent->merge($received)->unique();

        // 3. Get the user details and the last message for each contact
        $contacts = User::whereIn('id', $contactIds)
            ->get()
            ->map(function ($contact) use ($userId) {
                // Find the last message between these two users
                $lastMessage = Message::where(function ($query) use ($userId, $contact) {
                    $query->where('sender_id', $userId)->where('receiver_id', $contact->id);
                })->orWhere(function ($query) use ($userId, $contact) {
                    $query->where('sender_id', $contact->id)->where('receiver_id', $userId);
                })->orderBy('created_at', 'desc')->first();
                
                return [
                    'id' => $contact->id,
                    'name' => $contact->name,
                    'last_message' => $lastMessage ? $lastMessage->content : null,
                ];
            });

        return response()->json($contacts);
    }
}

