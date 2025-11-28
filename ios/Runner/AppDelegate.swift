import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Provide Google Maps API key from Info.plist (key: "GMSApiKey").
    if let gmsApiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String, !gmsApiKey.isEmpty {
      GMSServices.provideAPIKey(gmsApiKey)
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
