import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var storageChannel: FlutterMethodChannel?
  private var timeZoneChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "namu/storage",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "getRootPath" else {
        result(FlutterMethodNotImplemented)
        return
      }

      do {
        result(try AppStorage.rootPath())
      } catch {
        result(
          FlutterError(
            code: "storage_unavailable",
            message: "Could not prepare app storage.",
            details: nil
          )
        )
      }
    }
    storageChannel = channel

    let zoneChannel = FlutterMethodChannel(
      name: "namu/time_zone",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    zoneChannel.setMethodCallHandler { call, result in
      guard call.method == "getTimeZoneId" else {
        result(FlutterMethodNotImplemented)
        return
      }

      let identifier = TimeZone.current.identifier
      guard !identifier.isEmpty else {
        result(
          FlutterError(
            code: "time_zone_unavailable",
            message: "Could not resolve the system time zone.",
            details: nil
          )
        )
        return
      }
      result(identifier)
    }
    timeZoneChannel = zoneChannel
  }
}

private enum AppStorage {
  static func rootPath() throws -> String {
    let fileManager = FileManager.default
    let applicationSupport = try fileManager.url(
      for: .applicationSupportDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    )
    var root = applicationSupport.appendingPathComponent("Namu", isDirectory: true)
    try fileManager.createDirectory(
      at: root,
      withIntermediateDirectories: true,
      attributes: nil
    )

    var resourceValues = URLResourceValues()
    resourceValues.isExcludedFromBackup = true
    try root.setResourceValues(resourceValues)
    return root.path
  }
}
