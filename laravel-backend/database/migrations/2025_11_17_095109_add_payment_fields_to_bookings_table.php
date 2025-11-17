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
        Schema::table('bookings', function (Blueprint $table) {
            $table->decimal('amount', 10, 2)->nullable()->after('location');
            $table->string('payment_status')->default('pending')->after('amount'); // pending, completed, failed
            $table->string('payment_method')->nullable()->after('payment_status'); // paypal, card, etc
            $table->string('paypal_order_id')->nullable()->after('payment_method');
            $table->string('paypal_payer_id')->nullable()->after('paypal_order_id');
            $table->timestamp('paid_at')->nullable()->after('paypal_payer_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('bookings', function (Blueprint $table) {
            $table->dropColumn(['amount', 'payment_status', 'payment_method', 'paypal_order_id', 'paypal_payer_id', 'paid_at']);
        });
    }
};
