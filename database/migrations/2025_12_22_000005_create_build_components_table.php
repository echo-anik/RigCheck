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
        // Check if table already exists (for environments that may have created it manually)
        if (!Schema::hasTable('build_components')) {
            Schema::create('build_components', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('build_id');
                $table->unsignedBigInteger('component_id');
                $table->enum('category', ['cpu', 'motherboard', 'gpu', 'ram', 'storage', 'psu', 'case', 'cooler'])->nullable();
                $table->integer('quantity')->default(1);
                $table->decimal('price_at_selection_bdt', 10, 2)->nullable();
                $table->timestamps();

                // Indexes
                $table->unique(['build_id', 'category', 'component_id'], 'unique_build_category');
                $table->index('build_id');
                $table->index('component_id');

                // Foreign keys
                $table->foreign('build_id')
                    ->references('id')
                    ->on('builds')
                    ->onDelete('cascade');

                $table->foreign('component_id')
                    ->references('id')
                    ->on('components')
                    ->onDelete('restrict');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('build_components');
    }
};
