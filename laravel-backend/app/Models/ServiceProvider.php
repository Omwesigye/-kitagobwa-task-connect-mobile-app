<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ServiceProvider extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'location',
        'nin',
        'telnumber',
        'service',
        'description',
        'rating',
        'images',
    ];

    protected $casts = [
        'images' => 'array', // Cast JSON column to array automatically
    ];

    // Provider belongs to a single user via user_id
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Optional: bookings for this provider
    public function bookings()
    {
        return $this->hasMany(Booking::class, 'provider_id');
    }
}