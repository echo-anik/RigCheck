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
        Schema::create('component_prices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('component_id')->constrained('components')->onDelete('cascade');
            $table->string('retailer', 100);
            $table->decimal('price', 10, 2);
            $table->text('url')->nullable();
            $table->boolean('in_stock')->default(true);
            $table->timestamps();

            $table->index('component_id');
            $table->index('retailer');
            $table->index('price');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('component_prices');
    }
};
