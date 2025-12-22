<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Component extends Model
{
    use HasFactory;

    protected $table = 'components';
    protected $primaryKey = 'id';
    public $incrementing = true;

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'product_id',
        'category',
        'name',
        'brand_id',
        'series',
        'model',
        'primary_image_url',
        'image_urls',
        'lowest_price_usd',
        'lowest_price_bdt',
        'price_last_updated',
        'availability_status',
        'stock_count',
        'view_count',
        'build_count',
        'popularity_score',
        'slug',
        'tags',
        'release_date',
        'discontinued_date',
        'featured',
        'is_verified',
        'data_version',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = [
        'image_urls' => 'array',
        'tags' => 'array',
        'lowest_price_usd' => 'decimal:2',
        'lowest_price_bdt' => 'decimal:2',
        'price_last_updated' => 'datetime',
        'release_date' => 'date',
        'discontinued_date' => 'date',
        'featured' => 'boolean',
        'is_verified' => 'boolean',
        'data_version' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'last_modified' => 'datetime',
    ];

    /**
     * Get the brand that owns the component.
     */
    public function brand()
    {
        return $this->belongsTo(Brand::class);
    }

    /**
     * Get the component specifications.
     */
    public function specs()
    {
        return $this->hasMany(ComponentSpec::class, 'component_id');
    }

    /**
     * Get the component prices from different retailers.
     */
    public function prices()
    {
        return $this->hasMany(ComponentPrice::class, 'component_id');
    }

    /**
     * Get the builds that include this component.
     */
    public function builds()
    {
        return $this->belongsToMany(Build::class, 'build_components', 'component_id', 'build_id')
                    ->withPivot('category', 'quantity', 'price_at_selection_bdt')
                    ->withTimestamps();
    }

    /**
     * Scope a query to only include components of a specific category.
     */
    public function scopeCategory($query, $category)
    {
        return $query->where('category', $category);
    }

    /**
     * Scope a query to only include featured components.
     */
    public function scopeFeatured($query)
    {
        return $query->where('featured', true);
    }

    /**
     * Scope a query to only include in-stock components.
     */
    public function scopeInStock($query)
    {
        return $query->where('availability_status', 'in_stock');
    }

    /**
     * Scope a query to search by name or model.
     */
    public function scopeSearch($query, $search)
    {
        return $query->where(function ($q) use ($search) {
            $q->where('name', 'LIKE', "%{$search}%")
              ->orWhere('model', 'LIKE', "%{$search}%")
              ->orWhere('series', 'LIKE', "%{$search}%");
        });
    }

    /**
     * Get the best price for this component.
     */
    public function getBestPriceAttribute()
    {
        return $this->prices()
                    ->where('is_active', true)
                    ->orderBy('price_bdt', 'asc')
                    ->first();
    }

    /**
     * Get a specific spec value.
     */
    public function getSpecValue($key)
    {
        $spec = $this->specs()->where('spec_key', $key)->first();

        if (!$spec) {
            return null;
        }

        return match($spec->spec_type) {
            'text' => $spec->spec_value_text,
            'int' => $spec->spec_value_int,
            'decimal' => $spec->spec_value_decimal,
            'boolean' => (bool) $spec->spec_value_int,
            default => null,
        };
    }

    /**
     * Get all specs as key-value array.
     */
    public function getSpecsArrayAttribute()
    {
        $specs = [];
        foreach ($this->specs as $spec) {
            $specs[$spec->spec_key] = match($spec->spec_type) {
                'text' => $spec->spec_value_text,
                'int' => $spec->spec_value_int,
                'decimal' => (float) $spec->spec_value_decimal,
                'boolean' => (bool) $spec->spec_value_int,
                default => null,
            };
        }
        return $specs;
    }

    /**
     * Increment view count.
     */
    public function incrementViews()
    {
        $this->increment('view_count');
    }

    /**
     * Increment build usage count.
     */
    public function incrementBuildCount()
    {
        $this->increment('build_count');
    }
}
