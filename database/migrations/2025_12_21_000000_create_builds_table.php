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
        Schema::create('builds', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users')->onDelete('cascade');
            $table->string('build_name');
            $table->text('description')->nullable();
            $table->string('use_case')->nullable(); // gaming, workstation, content_creation, budget, other
            $table->decimal('budget_min_bdt', 10, 2)->nullable();
            $table->decimal('budget_max_bdt', 10, 2)->nullable();
            $table->decimal('total_cost_bdt', 10, 2)->default(0);
            $table->integer('total_tdp_w')->nullable();
            $table->string('compatibility_status')->default('valid'); // valid, warnings, errors
            $table->json('compatibility_issues')->nullable();
            $table->string('visibility')->default('private'); // private, public
            $table->string('share_token', 16)->unique()->nullable();
            $table->string('share_url')->nullable();
            $table->integer('view_count')->default(0);
            $table->integer('like_count')->default(0);
            $table->integer('comment_count')->default(0);
            $table->boolean('is_complete')->default(false);
            $table->string('sync_token')->nullable();
            $table->timestamp('last_synced_at')->nullable();

            // Legacy fields for backward compatibility
            $table->json('components')->nullable();
            $table->decimal('total_price', 10, 2)->default(0);
            $table->string('compatibility')->nullable();

            $table->timestamps();

            $table->index('user_id');
            $table->index('visibility');
            $table->index('use_case');
            $table->index('compatibility_status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('builds');
    }
};
