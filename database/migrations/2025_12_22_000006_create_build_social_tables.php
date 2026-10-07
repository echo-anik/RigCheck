<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('build_likes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('build_id')->constrained('builds')->onDelete('cascade');
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->timestamp('created_at')->useCurrent();
            
            $table->unique(['build_id', 'user_id']);
        });

        Schema::create('build_comments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('build_id')->constrained('builds')->onDelete('cascade');
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->text('comment'); // Controller uses 'comment', model uses 'comment_text'. Will use 'comment' to match controller.
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('build_comments');
        Schema::dropIfExists('build_likes');
    }
};
