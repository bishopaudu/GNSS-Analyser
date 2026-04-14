package dev.joshi.raw_gnss;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorManager;
import android.location.GnssMeasurement;
import android.location.GnssMeasurementsEvent;
import android.location.GnssNavigationMessage;
import android.location.LocationManager;
import android.location.OnNmeaMessageListener;
import android.location.GnssStatus;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** RawGnssPlugin */
public class RawGnssPlugin implements FlutterPlugin {

  private static final String GNSS_MEASUREMENT_CHANNEL_NAME =
          "dev.joshi.raw_gnss/gnss_measurement";
  private static final String GNSS_NAVIGATION_MESSAGE_CHANNEL_NAME = "dev.joshi.raw_gnss/gnss_navigation_message";
  private static final String GNSS_STATUS_CHANNEL_NAME = "dev.joshi.raw_gnss/gnss_status";

  private EventChannel gnssMeasurementChannel;
  private EventChannel gnssNavigationMessageChannel;
  private EventChannel gnssStatusChannel;
  private LocationManager locationManager;
  private Context context;

  @RequiresApi(api = Build.VERSION_CODES.N)
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    context = flutterPluginBinding.getApplicationContext();
    setupEventChannels(context, flutterPluginBinding.getBinaryMessenger());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    teardownEventChannels();
  }

  @RequiresApi(api = Build.VERSION_CODES.N)
  private void setupEventChannels(Context context, BinaryMessenger messenger) {
    locationManager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
    gnssMeasurementChannel = new EventChannel(messenger, GNSS_MEASUREMENT_CHANNEL_NAME);
    gnssNavigationMessageChannel = new EventChannel(messenger, GNSS_NAVIGATION_MESSAGE_CHANNEL_NAME);
    gnssStatusChannel = new EventChannel(messenger, GNSS_STATUS_CHANNEL_NAME);

    final GnssMeasurementHandlerImpl gnssMeasurementStreamHandler =
            new GnssMeasurementHandlerImpl(locationManager);
    gnssMeasurementChannel.setStreamHandler(gnssMeasurementStreamHandler);

    final GnssNavigationMessageHandlerImpl gnssNavigationMessageHandler =
            new GnssNavigationMessageHandlerImpl(locationManager);
    gnssNavigationMessageChannel.setStreamHandler(gnssNavigationMessageHandler);

    final GnssStatusHandlerImpl gnssStatusStreamHandler =
            new GnssStatusHandlerImpl(locationManager);
    gnssStatusChannel.setStreamHandler(gnssStatusStreamHandler);
  }

  private void teardownEventChannels() {
    gnssMeasurementChannel.setStreamHandler(null);
    gnssNavigationMessageChannel.setStreamHandler(null);
    gnssStatusChannel.setStreamHandler(null);
  }
}
