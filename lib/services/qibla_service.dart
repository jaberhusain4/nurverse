import 'dart:math';

class QiblaService {
  static const double _kaabaLatitude = 21.422487;

  static const double _kaabaLongitude = 39.826206;

  double getQiblaDirection(double latitude, double longitude) {
    final userLat = _degreeToRadian(latitude);

    final userLng = _degreeToRadian(longitude);

    final kaabaLat = _degreeToRadian(_kaabaLatitude);

    final kaabaLng = _degreeToRadian(_kaabaLongitude);

    final longitudeDifference = kaabaLng - userLng;

    final y = sin(longitudeDifference) * cos(kaabaLat);

    final x =
        (cos(userLat) * sin(kaabaLat)) -
        (sin(userLat) * cos(kaabaLat) * cos(longitudeDifference));

    double direction = atan2(y, x);

    direction = _radianToDegree(direction);

    return (direction + 360) % 360;
  }

  double _degreeToRadian(double degree) {
    return degree * pi / 180;
  }

  double _radianToDegree(double radian) {
    return radian * 180 / pi;
  }
}
