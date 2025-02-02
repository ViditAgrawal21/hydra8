import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class BluetoothHelper extends ChangeNotifier {
  BluetoothDevice? _connectedDevice;
  StreamSubscription? _scanSubscription;
  List<ScanResult> availableDevices = [];
  String? errorMessage;
  bool _isScanning = false;
  bool _isConnected = false;

  final FlutterBluePlus flutterBlue = FlutterBluePlus();

  BluetoothHelper() {
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: false);
  }

  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isScanning => _isScanning;
  String? get getErrorMessage => errorMessage;

  // Start scanning for devices
  Future<void> startScan() async {
    try {
      _isScanning = true;
      errorMessage = null;
      notifyListeners();

      stopScan();
      availableDevices.clear();
      notifyListeners();

      await FlutterBluePlus.startScan(
        withNames: ["Hydra8"], // Change this to the unique name or part of the name of your device
        timeout: Duration(seconds: 10),
      );

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        availableDevices = results;
        notifyListeners();
      });

      await Future.delayed(Duration(seconds: 10));
      stopScan();
    } catch (e) {
      errorMessage = "Error occurred during scan: $e";
      _isScanning = false;
      notifyListeners();
    }
  }

  // Connect to a selected device
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;
      _isConnected = true;
      notifyListeners();
    } catch (e) {
      errorMessage = "Failed to connect to the device: $e";
      notifyListeners();
    }
  }

  // Stop scanning and disconnect device
  void stopScan() {
    _scanSubscription?.cancel();
    FlutterBluePlus.stopScan();
    _isScanning = false;
    notifyListeners();
  }

  bool isConnected() => _isConnected && _connectedDevice != null;
}
