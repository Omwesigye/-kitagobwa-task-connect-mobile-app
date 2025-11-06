<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Location;
use App\Models\ServiceProvider;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class LocationController extends Controller
{
    /**
     * Upsert the user's latest location.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
        ]);

        $location = Location::updateOrCreate(
            ['user_id' => $validated['user_id']],
            ['latitude' => $validated['latitude'], 'longitude' => $validated['longitude']]
        );

        return response()->json(['message' => 'ok', 'data' => $location]);
    }

    /**
     * Get all users' latest locations.
     */
    public function index()
    {
        $locations = Location::query()
            ->with('user:id,name,role')
            ->orderByDesc('updated_at')
            ->get(['id', 'user_id', 'latitude', 'longitude', 'updated_at']);

        return response()->json($locations);
    }

    /**
     * Nearby service providers within radius (km) using Haversine.
     * Query params: lat, lng, radius (default 5km)
     */
    public function nearbyProviders(Request $request)
    {
        $request->validate([
            'lat' => 'required|numeric',
            'lng' => 'required|numeric',
            'radius' => 'nullable|numeric',
        ]);

        $lat = (float) $request->query('lat');
        $lng = (float) $request->query('lng');
        $radius = (float) ($request->query('radius', 5));

        // Haversine distance in km
        $haversine = "(6371 * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude))))";

        $rows = DB::table('locations as l')
            ->join('users as u', 'u.id', '=', 'l.user_id')
            ->join('service_providers as sp', 'sp.user_id', '=', 'u.id')
            ->select(
                'u.id as user_id',
                'u.name',
                'sp.service',
                'sp.telnumber',
                'l.latitude',
                'l.longitude',
                DB::raw("$haversine as distance_km")
            )
            ->where('u.role', 'service_provider')
            ->where('u.is_approved', true)
            ->having('distance_km', '<=', $radius)
            ->orderBy('distance_km')
            ->setBindings([$lat, $lng, $lat])
            ->get();

        return response()->json($rows);
    }
}



