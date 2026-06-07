import Flutter
import UIKit
import FamilyControls
import DeviceActivity

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let channelName = "dilf_flutter/device_activity"
  private let deviceActivityBridge = DeviceActivityBridge()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: engineBridge.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      self?.deviceActivityBridge.handleMethodCall(call, result: result)
    }
  }
}
