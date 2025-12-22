<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BuildComment extends Model
{
    use HasFactory;

    protected $table = 'build_comments';

    public $timestamps = false;

    protected $fillable = [
        'build_id',
        'user_id',
        'comment_text',
    ];

    protected $casts = [
        'created_at' => 'datetime',
    ];

    /**
     * Get the build that owns the comment
     */
    public function build()
    {
        return $this->belongsTo(Build::class);
    }

    /**
     * Get the user that wrote the comment
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
