High-res screenshot / mockup instructions

1) Quick device screenshot (Android/iOS physical device recommended):

- Run the app in release on the device:

```bash
flutter run --release -d <deviceId>
```

- Use platform tooling to capture a screenshot:
  - Android: `adb exec-out screencap -p > screen.png` (requires device connected)
  - iOS/macOS: Use Xcode -> Window -> Devices and Simulators -> take screenshot

- Alternatively, while the app is running you can use Flutter's `screenshot` command (requires a connected device):

```bash
flutter screenshot --out=highres.png
```

2) Programmatic golden / recordable render (for CI or automated renders):

- Create a widget test that pumps the desired screen and writes a PNG using `RepaintBoundary` and `ui.Image.toByteData`.
- From a macOS machine with a simulator or Android emulator, run the test to generate a PNG.

3) Recommended settings for high quality:

- Run on a high-DPI device or emulator (iPhone Pro models or Android devices with xxhdpi) and capture at native resolution.
- Use `--release` mode to remove debug overlays.
- For consistent visuals, lock device orientation and scale fonts via system settings beforehand.

If you want, I can:
- Add an example widget test that renders the `AlarmScreen` to a PNG automatically.
- Or set up a minimal golden-test harness and a sample golden image file.

Tell me which option you prefer and I will implement the test or the automated renderer.