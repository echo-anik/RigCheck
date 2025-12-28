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
        Schema::create('components', function (Blueprint $table) {
            $table->id();
            $table->string('product_id')->unique();
            $table->string('sku')->unique();
            $table->string('category', 50);
            $table->string('name', 500);
            $table->foreignId('brand_id')->nullable()->constrained('brands')->onDelete('set null');
            $table->string('series')->nullable();
            $table->string('model')->nullable();
            $table->string('primary_image_url')->nullable();
            $table->json('image_urls')->nullable();
            $table->decimal('lowest_price_usd', 10, 2)->nullable();
            $table->decimal('lowest_price_bdt', 10, 2)->nullable();
            $table->timestamp('price_last_updated')->nullable();
            $table->string('availability_status', 50)->default('in_stock');
            $table->integer('stock_count')->default(0);
            $table->boolean('featured')->default(false);
            $table->string('slug')->unique();
            $table->integer('data_version')->default(1);
            $table->json('tags')->nullable();
            $table->integer('view_count')->default(0);
            $table->integer('build_count')->default(0);
            $table->decimal('popularity_score', 8, 2)->default(0);
            $table->date('release_date')->nullable();
            $table->date('discontinued_date')->nullable();
            $table->boolean('is_verified')->default(false);
            $table->timestamps();

            $table->index('category');
            $table->index('brand_id');
            $table->index('slug');
            $table->index('featured');
            $table->index('availability_status');
            $table->index('popularity_score');
            $table->fullText('name');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('components');
    }
};
