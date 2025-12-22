<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ComponentSpec extends Model
{
    use HasFactory;

    protected $table = 'component_specs';

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'component_id',
        'spec_key',
        'spec_value_text',
        'spec_value_int',
        'spec_value_decimal',
        'spec_unit',
        'spec_type',
        'ref_socket_id',
        'ref_form_factor_id',
        'is_primary',
        'display_order',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array
     */
    protected $casts = [
        'spec_value_int' => 'integer',
        'spec_value_decimal' => 'decimal:4',
        'ref_socket_id' => 'integer',
        'ref_form_factor_id' => 'integer',
        'is_primary' => 'boolean',
        'display_order' => 'integer',
        'created_at' => 'datetime',
    ];

    /**
     * Get the component that owns the spec.
     */
    public function component()
    {
        return $this->belongsTo(Component::class);
    }

    /**
     * Get the reference socket if applicable.
     */
    public function socket()
    {
        return $this->belongsTo(RefCpuSocket::class, 'ref_socket_id');
    }

    /**
     * Get the reference form factor if applicable.
     */
    public function formFactor()
    {
        return $this->belongsTo(RefFormFactor::class, 'ref_form_factor_id');
    }

    /**
     * Get the spec value based on type.
     */
    public function getValueAttribute()
    {
        return match($this->spec_type) {
            'text' => $this->spec_value_text,
            'int' => $this->spec_value_int,
            'decimal' => (float) $this->spec_value_decimal,
            'boolean' => (bool) $this->spec_value_int,
            default => null,
        };
    }

    /**
     * Get formatted value with unit.
     */
    public function getFormattedValueAttribute()
    {
        $value = $this->value;

        if ($this->spec_unit) {
            return $value . ' ' . $this->spec_unit;
        }

        return $value;
    }
}
