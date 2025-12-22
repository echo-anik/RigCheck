<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('builds', function (Blueprint $table) {
            if (!Schema::hasColumn('builds', 'share_id')) {
                $table->string('share_id', 8)->unique()->nullable()->after('id');
            }
            if (!Schema::hasColumn('builds', 'is_public')) {
                $table->boolean('is_public')->default(true)->after('compatibility');
            }
            if (!Schema::hasColumn('builds', 'views')) {
                $table->integer('views')->default(0)->after('is_public');
            }
        });
        
        // Generate share_id for existing builds
        DB::table('builds')->whereNull('share_id')->get()->each(function ($build) {
            DB::table('builds')
                ->where('id', $build->id)
                ->update(['share_id' => \Illuminate\Support\Str::random(8)]);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('builds', function (Blueprint $table) {
            //
        });
    }
};
