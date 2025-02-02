import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Required for ChangeNotifier

class BluetoothHelper extends ChangeNotifier {  // Extend ChangeNotifier
  BluetoothDevice? _connectedDevice;
  StreamSubscription? _scanSubscription;
  double waterWeight = 0.0;
  List<ScanResult> availableDevices = [];
  String? errorMessage; // To store error messages
  bool _isScanning = false; // To track scanning status

  final FlutterBluePlus flutterBlue = FlutterBluePlus();

  BluetoothHelper() {
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: false);
  }

  // Getter for connected device (needed in settings screen)
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // Getter for scanning status
  bool get isScanning => _isScanning;

  // Getter for error message
  String? get getErrorMessage => errorMessage;

  // Start scanning for devices
  Future<void> startScan() async {
    try {
      _isScanning = true;
      errorMessage = null; // Clear previous error messages
      notifyListeners();  // Notify UI to update scanning status

      stopScan(); // Stop any previous scans before starting a new one

      availableDevices.clear();
      notifyListeners();  // Notify UI to update the device list

      // Start scan with a 10-second timeout
      await FlutterBluePlus.startScan(
        withNames: ["Hydra8"], 
        timeout: Duration(seconds: 10),
      );

      // Listen for scan results
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        availableDevices = results;
        notifyListeners();  // Notify UI when new devices are found
      });

      // Stop scanning after the timeout period
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
      notifyListeners();  // Update UI with connection status
    } catch (e) {
      errorMessage = "Failed to connect to the device: $e";
      notifyListeners();  // Notify UI about the connection error
    }
  }

  // Stop scanning and disconnect device
  void stopScan() {
    _scanSubscription?.cancel();
    FlutterBluePlus.stopScan();
    _isScanning = false;
    notifyListeners();
  }

  // Check if a device is connected
  bool isConnected() => _connectedDevice != null;
}
