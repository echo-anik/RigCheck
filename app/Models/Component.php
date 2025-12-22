<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Component extends Model
{
    use HasFactory;

    protected $fillable = [
        'product_id',
        'sku',
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
        'featured',
        'slug',
        'data_version',
        'tags',
        'view_count',
        'build_count',
        'popularity_score',
        'release_date',
        'discontinued_date',
        'is_verified'
    ];

    protected $casts = [
        'image_urls' => 'array',
        'lowest_price_usd' => 'decimal:2',
        'lowest_price_bdt' => 'decimal:2',
        'price_last_updated' => 'datetime',
        'featured' => 'boolean',
        'stock_count' => 'integer'
    ];

    public function brand()
    {
        return $this->belongsTo(Brand::class);
    }

    public function specs()
    {
        return $this->hasMany(ComponentSpec::class);
    }

    public function prices()
    {
        return $this->hasMany(ComponentPrice::class);
    }

    public function builds()
    {
        return $this->belongsToMany(Build::class, 'build_components')
            ->withPivot('category', 'quantity', 'price_at_selection_bdt');
    }
}
