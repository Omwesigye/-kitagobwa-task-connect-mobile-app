<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Report;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage; // For handling file uploads

class ReportController extends Controller
{
    /**
<<<<<<< HEAD
=======
     * List reports for admin review.
     */
    public function index()
    {
        $reports = Report::with('user')->orderByDesc('created_at')->get();
        return response()->json($reports);
    }

    /**
>>>>>>> 442766b (Add admin home and reports screens + backend models for messages, ratings, and reports)
     * Store a newly created report in storage.
     */
    public function store(Request $request)
    {
        // 1. Validate the incoming data from the Flutter app
        $validated = $request->validate([
            'user_id'     => 'required|exists:users,id',
            'category'    => 'required|string|max:255',
            'urgency'     => 'required|string|max:255',
            'description' => 'required|string|min:10',
            'image'       => 'nullable|image|mimes:jpeg,png,jpg|max:2048', // 2MB max
        ]);

        $imagePath = null;
        
        // 2. Check if an image was uploaded
        if ($request->hasFile('image')) {
            // 3. Store the image and get its path
            // The file will be saved in 'storage/app/public/reports'
            $imagePath = $request->file('image')->store('reports', 'public');
        }

        // 4. Create the report in the database
        $report = Report::create([
            'user_id'     => $validated['user_id'],
            'category'    => $validated['category'],
            'urgency'     => $validated['urgency'],
            'description' => $validated['description'],
            'image_path'  => $imagePath, // Save the path (or null if no image)
            'status'      => 'pending',
        ]);

        // 5. Send a success response back to Flutter
        return response()->json([
            'message' => 'Report submitted successfully!',
            'data'    => $report,
        ], 201); // 201 means "Created"
    }
}