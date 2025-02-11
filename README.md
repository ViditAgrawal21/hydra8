# Hydra8 - Smart Hydration Tracker

Hydra8 is a smart hydration tracking app that helps users monitor their daily water intake and optimize their hydration based on various factors such as weather conditions and physical activity. The app integrates with a smart water bottle via Bluetooth to provide real-time tracking and insights.

## Features

- **Smart Water Tracking**: Automatically logs water intake from a connected smart bottle.
- **Bluetooth Integration**: Connects to a Bluetooth-enabled water bottle to track real-time weight changes.
- **Personalized Hydration Goals**: Adjusts daily water intake recommendations based on user activity and weather conditions.
- **Activity & Weather Adjustments**: Dynamically modifies water intake goals depending on physical activity and weather.
- **Historical Data & Analytics**: Provides insights on past hydration trends.
- **Reminders & Notifications**: Alerts users to stay hydrated throughout the day.

## Tech Stack

- **Frontend**: Flutter (Dart)
- **State Management**: Provider
- **Backend**: Firebase (for user data storage)
- **Bluetooth Integration**: flutter_blue package
- **Local Storage**: SharedPreferences

## Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/ViditAgrawal21/Hydra8.git
   ```
2. Navigate to the project directory:
   ```sh
   cd my_app
   ```
3. Install dependencies:
   ```sh
   flutter pub get
   ```
4. Connect a physical device or start an emulator.
5. Run the app:
   ```sh
   flutter run
   ```

## Bluetooth Setup

To enable Bluetooth tracking with your smart bottle:
1. Ensure Bluetooth is enabled on your device.
2. Navigate to the settings screen in the app.
3. Search for available devices and pair with your smart bottle.
4. The app will automatically detect weight changes and update your intake.

## Configuration

- Ensure that Firebase is properly set up with your app.
- Update `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in the respective platform directories.
- Modify `bluetooth_helper.dart` if using a different Bluetooth module.

## Usage

- **Track Water Intake**: View daily intake and set custom goals.
- **Modify Preferences**: Adjust hydration goals based on activity and weather.
- **Check Hydration Stats**: Analyze past trends and get insights.
- **Enable Reminders**: Get notified when it's time to drink water.

## Contributing

1. Fork the repository.
2. Create a new branch:
   ```sh
   git checkout -b feature-branch
   ```
3. Make your changes and commit:
   ```sh
   git commit -m "Add new feature"
   ```
4. Push to your fork:
   ```sh
   git push origin feature-branch
   ```
5. Submit a pull request.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Contact

For support or inquiries, reach out to:
- Email: agrawalvidit656@gmail.com
- GitHub Issues: [Create an issue](https://github.com/ViditAgrawal21/Hydra88/issues)

