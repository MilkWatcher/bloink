import Foundation
import Flutter
import UIKit
import FamilyControls
import DeviceActivity

@available(iOS 15.0, *)
final class DeviceActivityBridge {
  private let eventMap: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]
  private let activityName = DeviceActivityName("dilf_wake_up")

  func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getAuthorizationStatus":
      result(getAuthorizationStatus())
    case "requestAuthorization":
      requestAuthorization(result: result)
    case "startMonitoringSchedule":
      startMonitoringSchedule(arguments: call.arguments, result: result)
    case "stopMonitoringSchedule":
      stopMonitoringSchedule(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getAuthorizationStatus() -> String {
    guard #available(iOS 15.0, *) else {
      return "unsupported"
    }

    let status = AuthorizationCenter.shared.authorizationStatus
    switch status {
    case .approved:
      return "approved"
    case .approvedWithDataAccess:
      return "approvedWithDataAccess"
    case .denied:
      return "denied"
    case .notDetermined:
      return "notDetermined"
    @unknown default:
      return "unknown"
    }
  }

  private func requestAuthorization(result: @escaping FlutterResult) {
    guard #available(iOS 15.0, *) else {
      result(FlutterError(code: "unsupported", message: "iOS 15+ required", details: nil))
      return
    }

    Task {
      do {
        try await AuthorizationCenter.shared.requestAuthorization(for: FamilyControlsMember.individual)
        result(getAuthorizationStatus())
      } catch {
        result(FlutterError(code: "authorization_failed", message: error.localizedDescription, details: nil))
      }
    }
  }

  private func startMonitoringSchedule(arguments: Any?, result: @escaping FlutterResult) {
    guard #available(iOS 15.0, *) else {
      result(FlutterError(code: "unsupported", message: "iOS 15+ required", details: nil))
      return
    }

    let startComponents = DateComponents(hour: 6, minute: 0)
    let endComponents = DateComponents(hour: 8, minute: 0)
    let schedule = DeviceActivitySchedule(intervalStart: startComponents, intervalEnd: endComponents, repeats: true)
    let center = DeviceActivityCenter()

    do {
      try center.startMonitoring(activityName, during: schedule, events: eventMap)
      result(["status": "started"])
    } catch {
      result(FlutterError(code: "monitoring_failed", message: error.localizedDescription, details: nil))
    }
  }

  private func stopMonitoringSchedule(result: @escaping FlutterResult) {
    guard #available(iOS 15.0, *) else {
      result(FlutterError(code: "unsupported", message: "iOS 15+ required", details: nil))
      return
    }

    let center = DeviceActivityCenter()
    center.stopMonitoring([activityName])
    result(["status": "stopped"])
  }
}
