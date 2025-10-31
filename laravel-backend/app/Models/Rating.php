<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Rating extends Model
{
    use HasFactory;
    
    // ... (Your $fillable array is correct) ...
    protected $fillable = [
        'user_id',
        'provider_id',
        'booking_id',
        'rating',
        'comment',
    ];

    // --- 1. ADD THIS RELATIONSHIP ---
    /**
     * Get the user (customer) who wrote the rating.
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
    // --------------------------------
}
