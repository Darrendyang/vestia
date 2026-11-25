import 'package:geolocator/geolocator.dart';

import 'api_client.dart';
import 'models.dart';

class WeatherService {
  const WeatherService(this.api);
  final ApiClient api;

  Future<WeatherSnapshot> current() async {
    var latitude = 31.2304;
    var longitude = 121.4737;
    var fallback = false;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      final denied =
          permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever;
      if (!serviceEnabled || denied) {
        fallback = true;
      } else {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 8),
          ),
        );
        latitude = position.latitude;
        longitude = position.longitude;
      }
    } catch (_) {
      fallback = true;
    }
    return api.getWeather(latitude, longitude, isFallbackLocation: fallback);
  }
}
