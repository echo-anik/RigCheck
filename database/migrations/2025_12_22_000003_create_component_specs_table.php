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
        Schema::create('component_specs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('component_id')->constrained('components')->onDelete('cascade');
            $table->string('spec_key', 100);
            $table->text('spec_value');
            $table->string('spec_unit', 50)->nullable();
            $table->timestamps();

            $table->index('component_id');
            $table->index('spec_key');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('component_specs');
    }
};
