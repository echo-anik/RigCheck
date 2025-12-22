<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Build extends Model
{
    use HasFactory;

    protected $table = 'builds';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'user_id',
        'build_name',
        'description',
        'use_case',
        'budget_min_bdt',
        'budget_max_bdt',
        'total_cost_bdt',
        'total_tdp_w',
        'compatibility_status',
        'compatibility_issues',
        'visibility',
        'share_token',
        'share_url',
        'view_count',
        'like_count',
        'comment_count',
        'is_complete',
        'sync_token',
        'last_synced_at',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = [
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
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * The "booted" method of the model.
     */
    protected static function booted()
    {
        static::creating(function ($build) {
            if (empty($build->share_token)) {
                $build->share_token = strtoupper(Str::random(8));
            }
            if (empty($build->share_url)) {
                $build->share_url = config('app.url') . '/build/' . $build->share_token;
            }
        });
    }

    /**
     * Get the user that owns the build.
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the components in this build.
     */
    public function components()
    {
        return $this->belongsToMany(Component::class, 'build_components', 'build_id', 'component_id')
                    ->withPivot('category', 'quantity', 'price_at_selection_bdt')
                    ->withTimestamps();
    }

    /**
     * Get the build components (pivot records).
     */
    public function buildComponents()
    {
        return $this->hasMany(BuildComponent::class, 'build_id');
    }

    /**
     * Get the likes for the build.
     */
    public function likes()
    {
        return $this->hasMany(BuildLike::class, 'build_id');
    }

    /**
     * Get the comments for the build.
     */
    public function comments()
    {
        return $this->hasMany(BuildComment::class, 'build_id');
    }

    /**
     * Check if user has liked this build.
     */
    public function isLikedBy($userId)
    {
        return $this->likes()->where('user_id', $userId)->exists();
    }

    /**
     * Scope a query to only include public builds.
     */
    public function scopePublic($query)
    {
        return $query->where('visibility', 'public');
    }

    /**
     * Scope a query to only include private builds.
     */
    public function scopePrivate($query)
    {
        return $query->where('visibility', 'private');
    }

    /**
     * Scope a query to filter by use case.
     */
    public function scopeUseCase($query, $useCase)
    {
        return $query->where('use_case', $useCase);
    }

    /**
     * Scope a query to filter by budget range.
     */
    public function scopeBudgetRange($query, $min, $max)
    {
        return $query->whereBetween('total_cost_bdt', [$min, $max]);
    }

    /**
     * Scope a query to order by popularity.
     */
    public function scopePopular($query)
    {
        return $query->orderByDesc('like_count')
                     ->orderByDesc('view_count');
    }

    /**
     * Increment view count.
     */
    public function incrementViews()
    {
        $this->increment('view_count');
    }

    /**
     * Get component by category.
     */
    public function getComponentByCategory($category)
    {
        return $this->buildComponents()
                    ->where('category', $category)
                    ->with('component')
                    ->first();
    }

    /**
     * Check if build has a specific category filled.
     */
    public function hasCategory($category)
    {
        return $this->buildComponents()->where('category', $category)->exists();
    }

    /**
     * Calculate total cost from components.
     */
    public function calculateTotalCost()
    {
        $total = $this->buildComponents()
                     ->sum('price_at_selection_bdt');

        $this->update(['total_cost_bdt' => $total]);

        return $total;
    }

    /**
     * Check if build is complete (has all required components).
     */
    public function checkCompleteness()
    {
        $requiredCategories = ['cpu', 'motherboard', 'ram', 'storage', 'psu', 'case'];
        $filledCategories = $this->buildComponents()->pluck('category')->unique();

        $isComplete = count(array_intersect($requiredCategories, $filledCategories->toArray())) === count($requiredCategories);

        $this->update(['is_complete' => $isComplete]);

        return $isComplete;
    }
}
