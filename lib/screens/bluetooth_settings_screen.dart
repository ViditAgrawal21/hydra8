import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/helpers/bluetooth_helper.dart'; // import your BluetoothHelper

class BluetoothSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bluetooth Device')),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding around the body
        child: Consumer<BluetoothHelper>(
          builder: (context, bluetoothProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section title
                Text(
                  "Bluetooth Device",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                SizedBox(height: 16), // Spacing after title

                // Display error message if any
                if (bluetoothProvider.getErrorMessage != null) ...[
                  SnackBar(
                    content: Text(bluetoothProvider.getErrorMessage!),
                    backgroundColor: Colors.red,
                  ),
                ],

                // Show connection status if connected
                if (bluetoothProvider.isConnected()) ...[
                  ListTile(
                    leading: Icon(Icons.bluetooth_connected, color: Colors.blue),
                    title: Text('Connected to: ${bluetoothProvider.connectedDevice?.name ?? "Unknown"}'),
                    subtitle: Text("Tap to disconnect"),
                    trailing: IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        bluetoothProvider.stopScan(); // Disconnect from the device
                      },
                    ),
                  ),
                  SizedBox(height: 16), // Add space after ListTile
                ] else ...[
                  // Show "Start Scan" button if not connected
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      minimumSize: Size(double.infinity, 48),
                    ),
                    onPressed: bluetoothProvider.isScanning
                        ? null
                        : () async {
                            await bluetoothProvider.startScan();
                          },
                    child: bluetoothProvider.isScanning
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Start Scan', style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(height: 16), // Add space after button

                  // Show loading indicator while scanning
                  if (bluetoothProvider.isScanning) ...[
                    Center(child: CircularProgressIndicator()),
                    SizedBox(height: 16),
                  ],

                  // Show available devices list if found
                  if (bluetoothProvider.availableDevices.isNotEmpty) ...[
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: bluetoothProvider.availableDevices.length,
                        itemBuilder: (context, index) {
                          final device = bluetoothProvider.availableDevices[index].device;
                          return Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              leading: Icon(Icons.bluetooth, color: Theme.of(context).primaryColor),
                              title: Text(
                                device.name.isNotEmpty ? device.name : 'Unknown Device',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(device.remoteId.toString()),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                                ),
                                onPressed: () {
                                  bluetoothProvider.connectToDevice(device);
                                },
                                child: const Text("Connect", style: TextStyle(fontSize: 14)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    // Show message if no devices found
                    Center(
                      child: Text(
                        "No devices found.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
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
