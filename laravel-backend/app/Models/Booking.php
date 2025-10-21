<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Booking extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'provider_id',
        'service',
        'location',
        'time',
        'date',
        'user_status',
        'provider_status'
    ];

    // Booking belongs to a user
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    // Booking belongs to a service provider
    public function provider()
    {
        return $this->belongsTo(ServiceProvider::class, 'provider_id');
    }
}