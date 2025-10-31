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
        Schema::create('reports', function (Blueprint $table) {
            $table->id();
            
            // This 'user_id' will link to the 'id' in your 'users' table
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            
            $table->string('category'); // 'power', 'water', etc.
            $table->string('urgency'); // 'low', 'medium', 'high'
            $table->text('description');
            $table->string('image_path')->nullable(); // To store the photo path
            $table->string('status')->default('pending'); // 'pending', 'resolved'
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reports');
    }
};