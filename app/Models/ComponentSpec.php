<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ComponentSpec extends Model
{
    use HasFactory;

    protected $fillable = [
        'component_id',
        'spec_key',
        'spec_value',
        'spec_unit',
        'spec_category'
    ];

    public $timestamps = false;

    public function component()
    {
        return $this->belongsTo(Component::class);
    }
}
