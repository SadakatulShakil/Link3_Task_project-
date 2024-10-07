import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../controller/sensor_provider.dart';


class SensorTrackingView extends StatefulWidget {
  const SensorTrackingView({Key? key}) : super(key: key);

  @override
  _SensorTrackingViewState createState() => _SensorTrackingViewState();
}

class _SensorTrackingViewState extends State<SensorTrackingView> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    final sensorProvider = Provider.of<SensorProvider>(context, listen: false);

    gyroscopeEvents.listen((GyroscopeEvent event) {
      sensorProvider.updateGyroData(event);
    });

    accelerometerEvents.listen((AccelerometerEvent event) {
      sensorProvider.updateAccelData(event);
    });

    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SensorTitle(title: 'Gyro Data'),
            const SensorGraph(isGyro: true),
            const SizedBox(height: 20),
            const SensorTitle(title: 'Accelerometer Data'),
            const SensorGraph(isGyro: false),
            Consumer<SensorProvider>(
              builder: (context, provider, _) {
                return provider.isAlertActive
                    ? const AlertWidget()
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SensorTitle extends StatelessWidget {
  final String title;

  const SensorTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class SensorGraph extends StatelessWidget {
  final bool isGyro;

  const SensorGraph({Key? key, required this.isGyro}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorProvider>(
      builder: (context, provider, _) {
        final data = isGyro ? provider.gyroData : provider.accelData;

        return Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8),
          child: Container(
            height: 200,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: data[0],
                    color: Colors.blue,
                    dotData: FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: data[1],
                    color: Colors.red,
                    dotData: FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: data[2],
                    color: Colors.green,
                    dotData: FlDotData(show: false),
                  ),
                ],
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(
                  show: true,  // Enables border
                  border: Border.all(
                    color: Colors.black, // Sets the border color to black
                    width: 1,  // Adjust the width of the border
                  ),
                ),
                gridData: FlGridData(show: true),
              ),
            ),
          ),
        );

      },
    );
  }
}

class AlertWidget extends StatelessWidget {
  const AlertWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Text(
        'ALERT',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}