package dev.joshi.raw_gnss;

import android.location.*;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.RequiresApi;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;

import io.flutter.plugin.common.EventChannel;

public class GnssStatusHandlerImpl implements EventChannel.StreamHandler {
    private static final String TAG = "GNSS_STATUS";

    LocationManager locationManager;
    GnssStatus.Callback listener;
    private final Handler uiThreadHandler = new Handler(Looper.getMainLooper());

    // Dummy location listener to force the GPS hardware receiver ON
    private android.location.LocationListener dummyLocationListener;

    GnssStatusHandlerImpl(LocationManager manager) {
        locationManager = manager;
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        Log.d(TAG, "onListen");
        listener = createSensorEventListener(events);
        locationManager.registerGnssStatusCallback(listener, uiThreadHandler);

        // Force the GPS hardware to turn on by requesting raw GPS updates.
        // Without this, the Fused Location Provider may use WiFi/cell towers
        // and never activate the GNSS receiver on real devices.
        try {
            dummyLocationListener = new android.location.LocationListener() {
                @Override
                public void onLocationChanged(android.location.Location location) {
                    // We don't need these — Geolocator handles position.
                    // This listener exists solely to keep the GPS chip powered on.
                }
            };
            locationManager.requestLocationUpdates(
                LocationManager.GPS_PROVIDER,
                1000,  // 1 second interval
                0,     // 0 meter distance filter
                dummyLocationListener,
                Looper.getMainLooper()
            );
            Log.d(TAG, "GPS_PROVIDER location updates requested to force hardware on");
        } catch (SecurityException e) {
            Log.e(TAG, "Missing location permission for GPS_PROVIDER: " + e.getMessage());
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    @Override
    public void onCancel(Object arguments) {
        Log.d(TAG, "onCancel");
        locationManager.unregisterGnssStatusCallback(listener);
        if (dummyLocationListener != null) {
            locationManager.removeUpdates(dummyLocationListener);
            dummyLocationListener = null;
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    GnssStatus.Callback createSensorEventListener(final EventChannel.EventSink events) {
        return new GnssStatus.Callback() {
            @Override
            public void onSatelliteStatusChanged(GnssStatus eventArgs) {
                Log.d(TAG, "onGnssStatusReceived: " + eventArgs.toString());
                super.onSatelliteStatusChanged(eventArgs);

                HashMap<String, Object> resultMap = new HashMap<>();
                resultMap.put("satelliteCount", eventArgs.getSatelliteCount());
                resultMap.put("hashCode", eventArgs.hashCode());

                ArrayList<HashMap<String, Object>> statusMapList = new ArrayList<>();

                for (int i = 0; i < eventArgs.getSatelliteCount(); ++i) {
                    HashMap<String, Object> map = new HashMap<>();
                    map.put("azimuthDegrees", eventArgs.getAzimuthDegrees(i));
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                        map.put("carrierFrequencyHz", eventArgs.getCarrierFrequencyHz(i));
                    }
                    map.put("cn0DbHz", eventArgs.getCn0DbHz(i));
                    map.put("constellationType", eventArgs.getConstellationType(i));
                    map.put("elevationDegrees", eventArgs.getElevationDegrees(i));
                    map.put("svid", eventArgs.getSvid(i));
                    map.put("hasAlmanacData", eventArgs.hasAlmanacData(i));
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                       map.put("hasCarrierFrequencyHz", eventArgs.hasCarrierFrequencyHz(i));
                    }
                    map.put("hasEphemerisData", eventArgs.hasEphemerisData(i));
                    map.put("usedInFix", eventArgs.usedInFix(i));
                    statusMapList.add(map);
                }

                resultMap.put("status", statusMapList);
                uiThreadHandler.post(() -> events.success(resultMap));
            }
        };
    }
}
