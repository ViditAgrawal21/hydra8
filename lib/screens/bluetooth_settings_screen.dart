import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/helpers/bluetooth_helper.dart';

class BluetoothSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Settings'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<BluetoothHelper>(
          builder: (context, bluetoothProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Section title
                Text(
                  "Connect to Your Device",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                        fontSize: 22,
                      ),
                ),
                const SizedBox(height: 16),

                // 🔹 Show error message if no connection and not scanning
                if (!bluetoothProvider.isConnected && !bluetoothProvider.isScanning) ...[
                  Center(
                    child: Text(
                      "No device connected. Please start scanning.",
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 🔹 Show connection status if device is connected
                if (bluetoothProvider.isConnected) ...[
                  ListTile(
                    leading: const Icon(Icons.bluetooth_connected, color: Colors.green),
                    title: Text('Connected to: ${bluetoothProvider.deviceName}'),
                    subtitle: const Text("Tap to disconnect"),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        bluetoothProvider.disconnect();
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🔹 Show latest weight if available
                  Center(
                    child: Column(
                      children: [
                        const Text("Latest Weight:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          "${bluetoothProvider.weight} g",
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // 🔹 Show scan button if not connected
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: Colors.blue.shade700, // Darker blue for better visibility
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: bluetoothProvider.isScanning
                        ? null
                        : () async {
                            // Start scanning process
                            await bluetoothProvider.startScan(context); // Pass context here
                          },
                    child: bluetoothProvider.isScanning
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              ),
                              SizedBox(width: 10),
                              Text("Scanning..."),
                            ],
                          ) // Show scanning loader and text
                        : const Text('Start Scanning'),
                  ),
                  const SizedBox(height: 16),

                  // 🔹 Show scanning indicator
                  if (bluetoothProvider.isScanning) ...[
                    const Center(child: CircularProgressIndicator()), // Show a loader during scanning
                    const SizedBox(height: 16),
                    // 🔹 Scan in progress text
                    Center(
                      child: Text(
                        "Scanning for nearby devices...",
                        style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                      ),
                    ),
                  ],

                  // 🔹 Show available devices list or no device found message
                  if (!bluetoothProvider.isScanning) ...[
                    // If no device found after scanning
                    if (!bluetoothProvider.isConnected) ...[
                      const SizedBox(height: 16),
                      // 🔹 Retry scan button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: Colors.orange.shade700, // Darker orange for better visibility
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: bluetoothProvider.isScanning
                            ? null
                            : () async {
                                // Retry scanning if no device is found
                                await bluetoothProvider.startScan(context);
                              },
                        child: const Text('Retry Scan'),
                      ),
                    ] else ...[
                      // 🔹 If a device is found, show connected message
                      Center(
                        child: Text(
                          "Device Connected: ${bluetoothProvider.deviceName}",
                          style: TextStyle(fontSize: 18, color: Colors.green),
                        ),
                      ),
                    ]
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
