<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Build extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'build_name', // Matches DB schema
        'description',
        'use_case', // ENUM: gaming, workstation, content_creation, budget, other
        'budget_min_bdt',
        'budget_max_bdt',
        'total_cost_bdt', // Matches DB schema (denormalized)
        'total_tdp_w', // Matches DB schema
        'compatibility_status', // ENUM: valid, warnings, errors
        'compatibility_issues', // JSON field
        'visibility', // ENUM: private, public
        'share_token', // Unique share code
        'share_id', // Alternative share identifier
        'share_url', // Full share URL
        'view_count', // Denormalized
        'like_count', // Denormalized
        'comment_count', // Denormalized
        'is_complete', // Boolean
        'sync_token', // For mobile app sync
        'last_synced_at', // Timestamp
    ];

    protected $casts = [
        'use_case' => 'string',
        'budget_min_bdt' => 'decimal:2',
        'budget_max_bdt' => 'decimal:2',
        'total_cost_bdt' => 'decimal:2',
        'total_tdp_w' => 'integer',
        'compatibility_issues' => 'array',
        'view_count' => 'integer',
        'like_count' => 'integer',
        'comment_count' => 'integer',
        'is_complete' => 'boolean',
        'last_synced_at' => 'datetime',
    ];

    protected $attributes = [
        'visibility' => 'private',
        'compatibility_status' => 'valid',
        'view_count' => 0,
        'like_count' => 0,
        'comment_count' => 0,
        'is_complete' => false,
    ];

    protected static function boot()
    {
        parent::boot();

        // Generate unique share_token on creation
        static::creating(function ($build) {
            if (empty($build->share_token)) {
                $build->share_token = Str::random(16);
            }
        });
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Components attached to this build
     */
    public function components()
    {
        return $this->belongsToMany(Component::class, 'build_components')
            ->withPivot('category', 'quantity', 'price_at_selection_bdt')
            ->withTimestamps();
    }

    /**
     * Likes on this build
     */
    public function likes()
    {
        return $this->hasMany(BuildLike::class);
    }

    /**
     * Comments on this build
     */
    public function comments()
    {
        return $this->hasMany(BuildComment::class);
    }

    /**
     * Check if user has liked this build
     */
    public function isLikedBy($userId)
    {
        return $this->likes()->where('user_id', $userId)->exists();
    }
}
