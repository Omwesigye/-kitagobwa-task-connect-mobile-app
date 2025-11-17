<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ServiceProvider extends Model
{
    use HasFactory;
    
    // ... (Your existing $fillable array is here)
    protected $fillable = [
        'user_id',
        'location',
        'nin',
        'telnumber',
        'service',
        'description',
        'service_fee',
        'rating',
        'latitude',
        'longitude'
        // 'images' is handled by $casts, no need to be fillable
    ];

    // --- ADD THIS PROPERTY ---
    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = [
        'images' => 'array',
    ];
    // -------------------------

    /**
     * Get the user that owns the service provider profile.
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
