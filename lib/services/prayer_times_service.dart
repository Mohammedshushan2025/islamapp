import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

class PrayerTimesService {

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('خدمات الموقع معطلة.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('تم رفض أذونات الموقع.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'أذونات الموقع مرفوضة بشكل دائم، لا يمكننا طلب الأذونات.');
    }
    return await Geolocator.getCurrentPosition();
  }


  Future<PrayerTimes> getPrayerTimes() async {
    final position = await _determinePosition();
    final myCoordinates = Coordinates(position.latitude, position.longitude);
    final params = CalculationMethod.egyptian.getParameters();
    params.madhab = Madhab.shafi;
    final prayerTimes = PrayerTimes.today(myCoordinates, params);

    return prayerTimes;
  }
}