<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            // Remove the old column
            $table->dropColumn('is_confirmed');

            // Add the new columns
            $table->string('user_status')->default('pending');
            $table->string('provider_status')->default('pending');
        });
    }

    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            // Revert changes
            $table->boolean('is_confirmed')->default(false);
            $table->dropColumn(['user_status', 'provider_status']);
        });
    }
};