<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BuildLike extends Model
{
    use HasFactory;

    protected $table = 'build_likes';

    public $timestamps = false; // Uses only created_at

    protected $fillable = [
        'build_id',
        'user_id',
    ];

    const CREATED_AT = 'created_at';
    const UPDATED_AT = null;

    public function build()
    {
        return $this->belongsTo(Build::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
