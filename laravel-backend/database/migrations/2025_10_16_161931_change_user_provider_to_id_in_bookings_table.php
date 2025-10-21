<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            // Add new ID columns first (nullable to avoid breaking existing rows)
            $table->unsignedBigInteger('user_id')->nullable()->after('id');
            $table->unsignedBigInteger('provider_id')->nullable()->after('user_id');
        });

        // Populate the new ID columns based on existing names
        DB::table('bookings')->get()->each(function ($booking) {
            // Find user ID from user_name
            $user = DB::table('users')->where('name', $booking->user_name)->first();
            $provider = DB::table('service_providers')->where('name', $booking->provider_name)->first();

            DB::table('bookings')->where('id', $booking->id)->update([
                'user_id' => $user?->id,
                'provider_id' => $provider?->id,
            ]);
        });

        Schema::table('bookings', function (Blueprint $table) {
            // Make new ID columns non-nullable
            $table->unsignedBigInteger('user_id')->nullable(false)->change();
            $table->unsignedBigInteger('provider_id')->nullable(false)->change();

            // Optional: add foreign keys
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('provider_id')->references('id')->on('service_providers')->onDelete('cascade');

            // Drop the old name columns
            $table->dropColumn(['user_name', 'provider_name']);
        });
    }

    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            // Add back the old name columns
            $table->string('user_name')->after('id');
            $table->string('provider_name')->after('user_name');
        });

        // Optional: copy back names from IDs
        DB::table('bookings')->get()->each(function ($booking) {
            $user = DB::table('users')->where('id', $booking->user_id)->first();
            $provider = DB::table('service_providers')->where('id', $booking->provider_id)->first();

            DB::table('bookings')->where('id', $booking->id)->update([
                'user_name' => $user?->name,
                'provider_name' => $provider?->name,
            ]);
        });

        Schema::table('bookings', function (Blueprint $table) {
            $table->dropForeign(['user_id']);
            $table->dropForeign(['provider_id']);
            $table->dropColumn(['user_id', 'provider_id']);
        });
    }
};