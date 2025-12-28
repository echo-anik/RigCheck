<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ComponentPrice extends Model
{
    use HasFactory;

    protected $fillable = [
        'component_id',
        'retailer_id',
        'price_bdt',
        'price_usd',
        'stock_status',
        'retailer_url',
        'scraped_at'
    ];

    protected $casts = [
        'price_bdt' => 'decimal:2',
        'price_usd' => 'decimal:2',
        'scraped_at' => 'datetime'
    ];

    public function component()
    {
        return $this->belongsTo(Component::class);
    }

    public function retailer()
    {
        return $this->belongsTo(Retailer::class);
    }
}
