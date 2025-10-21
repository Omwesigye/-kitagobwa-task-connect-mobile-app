<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'is_approved',
        'login_code',
    ];

    protected $hidden = [
        'password',
        'remember_token',
        'login_code',
    ];

    // Many-to-many: user can have multiple service providers
    public function serviceProviders()
    {
        return $this->belongsToMany(
            ServiceProvider::class,     // Related model
            'user_service_provider',    // Pivot table
            'user_id',                  // Foreign key on pivot table for this model
            'service_provider_id'       // Foreign key on pivot table for related model
        );
    }

    // Optional: bookings made by the user
    public function bookings()
    {
        return $this->hasMany(Booking::class, 'user_id');
    }
}