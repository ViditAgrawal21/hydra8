import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
// import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class BluetoothHelper with ChangeNotifier {
  final String deviceName = "Hydra8"; // ESP32 device name
  final String serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String characteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _weightCharacteristic;
  StreamSubscription? _scanSubscription;
  bool _isScanning = false;
  bool _isConnected = false;
  bool _scanCompleted = false; // Track if scan completed
  int latestWeight = 0; // Weight from ESP32

  final FlutterBluePlus flutterBlue = FlutterBluePlus();

  BluetoothHelper() {
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: false);
  }

  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  bool get scanCompleted => _scanCompleted;
  int get weight => latestWeight;

  // 🔹 Check Bluetooth and Location Permissions
  Future<bool> checkBluetoothPermissions() async {
    PermissionStatus bluetoothStatus = await Permission.bluetooth.request();
    PermissionStatus locationStatus = await Permission.locationWhenInUse.request();
    return bluetoothStatus.isGranted && locationStatus.isGranted;
  }

  // 🔹 Start Scanning for Hydra8 device
  Future<void> startScan(BuildContext context) async {
    if (_isScanning) return; // Prevent duplicate scans

    bool hasPermission = await checkBluetoothPermissions();
    if (!hasPermission) {
      _showPermissionErrorDialog(context);
      return;
    }

    try {
      stopScan(); // Ensure no duplicate scans
      _isScanning = true;
      _scanCompleted = false;
      notifyListeners();

      FlutterBluePlus.startScan(withNames: [deviceName], timeout: const Duration(seconds: 10));

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) async {
        for (ScanResult result in results) {
          if (result.device.localName == deviceName) {
            stopScan();
            await connectToDevice(result.device, context);
            return;
          }
        }
      });

      await Future.delayed(const Duration(seconds: 10));
      _scanCompleted = true;
      stopScan();

      // If no device was found, prompt user to retry scanning
      if (!_isConnected) {
        _showRetryScanDialog(context);
      }
    } catch (e) {
      print("Scan error: $e");
    }
  }

  // 🔹 Connect to the Hydra8 device
  Future<void> connectToDevice(BluetoothDevice device, BuildContext context) async {
    try {
      await device.connect();
      _connectedDevice = device;
      _isConnected = true;
      notifyListeners();

      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        if (service.uuid.toString() == serviceUuid) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == characteristicUuid) {
              _weightCharacteristic = characteristic;
              await _weightCharacteristic!.setNotifyValue(true);
              _weightCharacteristic!.value.listen((value) {
                if (value.isNotEmpty) {
                  latestWeight = _parseWeightData(value);
                  notifyListeners();
                  print("Received Weight: $latestWeight");
                }
              });
              break;
            }
          }
        }
      }

      _showDeviceConnectedDialog(context);
    } catch (e) {
      print("Connection error: $e");
      _showConnectionErrorDialog(context);
    }
  }

  // 🔹 Parse Weight Data from ESP32
  int _parseWeightData(List<int> value) {
    try {
      String stringValue = String.fromCharCodes(value).trim();
      return int.tryParse(stringValue) ?? 0;
    } catch (e) {
      print("Weight parsing error: $e");
      return 0;
    }
  }

  // 🔹 Stop scanning
  void stopScan() {
    _scanSubscription?.cancel();
    FlutterBluePlus.stopScan();
    _isScanning = false;
    notifyListeners();
  }

  // 🔹 Disconnect BLE
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _isConnected = false;
      _connectedDevice = null;
      notifyListeners();
    }
  }

  // 🔹 Show Permission Error Dialog
  void _showPermissionErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text('Please grant Bluetooth and Location permissions to proceed.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // 🔹 Show Connection Error Dialog
  void _showConnectionErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Connection Failed'),
        content: const Text('Unable to connect to Hydra8 device. Please try again.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // 🔹 Show Device Connected Dialog
  void _showDeviceConnectedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Connected'),
        content: const Text('Successfully connected to Hydra8.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // 🔹 Show Retry Scan Dialog
  void _showRetryScanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('No Device Found'),
        content: const Text('Hydra8 device was not found. Would you like to retry scanning?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              startScan(context); // Retry scanning
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
