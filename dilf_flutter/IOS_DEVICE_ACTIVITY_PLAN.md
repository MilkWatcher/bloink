# iOS DeviceActivity / FamilyControls Plan

## Goal
Implement a minimal iOS-side scaffolding for DILF that uses Apples supported Screen Time / Device Activity APIs rather than unsupported OS-level blocking hacks.

This plan is intentionally conservative: it focuses on Appleapproved entitlements and the minimum native extension structure needed to monitor scheduled activity and enforce distraction-reduction behavior during wake-up.

## Required entitlement & capability

- `com.apple.developer.family-controls`
  - This is the Family Controls entitlement required to use Screen Time / FamilyControls APIs.
  - Apple must approve distribution for apps using this entitlement.
  - The entitlement is typically added in Xcode via Signing & Capabilities.

- App extension target(s):
  - A `Device Activity` extension or `Device Activity Report` extension is needed to monitor scheduled app/web activity.
  - The app may also need a custom entitlement file for the extension target.

## iOS architecture proposal

### Main Flutter app
- Provide UI for:
  - requesting DeviceActivity / FamilyControls authorization,
  - defining a wake-up schedule and distraction-control session,
  - showing block status and fallback guidance if authorization is denied.
- Use a Flutter `MethodChannel` to communicate with native iOS code:
  - `requestAuthorization`
  - `startMonitoringSchedule`
  - `stopMonitoringSchedule`
  - `getAuthorizationStatus`

### Native iOS bridge
- Implement a small Swift helper in `ios/Runner` or a custom plugin.
- Use `AuthorizationCenter.shared.requestAuthorization(for:)` to request permission.
- Use `DeviceActivityCenter` to begin monitoring a scheduled session.
- Keep the native logic minimal and on-device.

### DeviceActivity extension
- Create an app extension target with a class such as `DeviceActivityMonitor`.
- The extension receives notifications when scheduled monitoring begins, ends, or thresholds are reached.
- This extension can report activity status back to the main app via shared container, UserDefaults, or app group if needed.

## Minimal extension scaffold

### Swift skeleton for the extension
```swift
import DeviceActivity
import FamilyControls

final class DILFDeviceActivityMonitor: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        // Called when the scheduled session begins.
        // Record state or update a shared status for the main Flutter app.
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        // Called when the scheduled session ends.
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent, activity: DeviceActivityName) {
        // Optional: throttle/report when the session reaches a threshold.
    }
}
```

### Example extension Info.plist
- Add `NSExtension` settings for the Device Activity extension.
- Ensure the extension target is registered as a Device Activity monitor.

## Entitlement request text

Use this draft when requesting approval from Apple for the Family Controls entitlement:

> DILF is a wake-up and focus app that helps users reduce morning distraction by tying a gentle alarm workflow to Screen Time-style app monitoring. During the user-defined wake-up session, DILF monitors selected apps and web activity and encourages the user to complete a goal-driven wake-up routine before those distractions are resumed. We will use `com.apple.developer.family-controls` only to:
>
> - request device authorization for a monitored activity session,
> - observe app and website usage in a privacy-preserving way,
> - enforce a user-approved wake-up session boundary using on-device APIs.
>
> No user activity data leaves the device; the feature is intended only to help the user reduce night-time distraction and complete a morning goal routine.

## Implementation steps

1. Add a new `Device Activity` extension target in Xcode.
2. Add the `Family Controls` capability to the main app target and the extension target.
3. Create an entitlements file with `com.apple.developer.family-controls = true`.
4. Implement `AuthorizationCenter` in native Swift to request authorization and report status.
5. Implement the extension class using `DeviceActivityMonitor`.
6. Expose the native methods to Flutter via `MethodChannel`.
7. Add fallback UX in Flutter for denied permission or unapproved authorization.

## Notes and caveats

- This approach is far more Apple-friendly than trying to use any hidden or unsupported OS-level blocking APIs.
- Apple expects this entitlement to be used in a parental-control / screen-time-style scenario.
- If Apple does not approve the entitlement, the fallback should be a local wake-up routine in Flutter and on-device prompts only.

## Recommended next step

- Create the first native Swift bridge that requests `FamilyControls` authorization and logs the authorization result.
- Then add the Device Activity extension and a schedule start/stop flow.
- Keep the initial prototype limited to monitoring and user-facing session state, then expand to active interruption if Apple approves the entitlement.
