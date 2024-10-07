import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorProvider with ChangeNotifier {
  List<List<FlSpot>> gyroData = List.generate(3, (_) => [FlSpot(0, 0)]);
  List<List<FlSpot>> accelData = List.generate(3, (_) => [FlSpot(0, 0)]);
  bool isAlertActive = false;

  static const int maxDataPoints = 500;
  static const double alertThreshold = 3.0;
  double currentX = 0;

  void updateGyroData(GyroscopeEvent event) {
    currentX += 1;
    if (currentX > maxDataPoints) {
      for (var axis in gyroData) {
        if (axis.length > 1) {
          axis.removeAt(0);
        }
      }
    }

    gyroData[0].add(FlSpot(currentX, event.x));
    gyroData[1].add(FlSpot(currentX, event.y));
    gyroData[2].add(FlSpot(currentX, event.z));

    checkForAlert([event.x, event.y, event.z]);
    notifyListeners();
  }

  void updateAccelData(AccelerometerEvent event) {
    if (currentX > maxDataPoints) {
      for (var axis in accelData) {
        if (axis.length > 1) {
          axis.removeAt(0);
        }
      }
    }

    accelData[0].add(FlSpot(currentX, event.x));
    accelData[1].add(FlSpot(currentX, event.y));
    accelData[2].add(FlSpot(currentX, event.z));

    notifyListeners();
  }

  void checkForAlert(List<double> values) {
    int highMovementAxes = values.where((v) => v.abs() > alertThreshold).length;
    isAlertActive = highMovementAxes >= 2;
  }
}