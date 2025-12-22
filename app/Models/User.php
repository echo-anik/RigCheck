<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     * Updated to match DB_IMPROVED.sql schema
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'is_banned',
        'avatar_url',
        'bio',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password_hash',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'is_banned' => 'boolean',
    ];

    protected $attributes = [
        'role' => 'user',
        'is_banned' => false,
    ];

    /**
     * Get the password attribute name for authentication.
     * Laravel expects 'password' but DB has 'password_hash'
     */
    // Use default password column

    /**
     * Get the builds created by this user.
     */
    public function builds()
    {
        return $this->hasMany(Build::class);
    }

    /**
     * Get the likes made by this user on builds.
     */
    public function buildLikes()
    {
        return $this->hasMany(BuildLike::class);
    }

    /**
     * Get the comments made by this user on builds.
     */
    public function buildComments()
    {
        return $this->hasMany(BuildComment::class);
    }
}
