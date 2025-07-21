// Copyright © 2021 Wildberries. All rights reserved.

import UIKit

/// Meta is a typealias for a dictionary with String keys and Any values.
typealias Meta = [String: Any]

/// Extension for Meta to initialize it with various system and user information.
extension Meta {

    /// Initializer for Meta.
    /// - Parameters:
    ///   - networkType: The type of network connection.
    ///   - deviceId: The unique device identifier.
    ///   - isNewUser: A boolean indicating whether the user is new.
    init(networkType: WBMNetworkType, deviceId: String, isNewUser: Bool) {
        let locale = Locale.current.languageCode ?? ""
        let sdkVersion = (Bundle.main.infoDictionary?["DTPlatformVersion"] as? String) ?? ""
        let product = UIDevice.current.systemName
        let osBuild = UIDevice.current.systemVersion
        let timeZoneOffsetSeconds = TimeZone.current.secondsFromGMT()
        let timeZoneOffset = String(format: "%+.2d%.2d", timeZoneOffsetSeconds / 3600, (abs(timeZoneOffsetSeconds) / 60) % 60)
        let timeZoneIdentifier = TimeZone.current.identifier
        let networkType = networkType.rawValue
        let localTime = Date().asString
        let appId = (Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String) ?? ""
        let appVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? ""
        let analyticsSDKVersion = TagVersion.version
        let isNewUser = isNewUser ? 1 : 0
        let screenSize = UIScreen.main.nativeBounds
        let resolutionWidth = screenSize.width
        let resolutionHeight = screenSize.height
        self = [
            "locale": locale,
            "sdk_version": sdkVersion,
            "model": getDeviceModel(),
            "product": product,
            "os-build": osBuild,
            "tz_offset": timeZoneOffset,
            "net_type": networkType,
            "app_id": appId,
            "app_version": appVersion,
            "analytics_sdk_version": analyticsSDKVersion,
            "resolution_width": resolutionWidth,
            "resolution_height": resolutionHeight,
            "device_id": deviceId,
            "local_time": localTime,
            "manufacturer": String.apple,
            "mobile_device_type": getDeviceType(),
            "is_new_user": isNewUser,
            "timezone": timeZoneIdentifier,
        ]
    }
}

/// Function to get the device model.
private func getDeviceModel() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let deviceModel = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
    return deviceModel
}

/// Function to get the device type.
private func getDeviceType() -> String {
#if targetEnvironment(simulator)
    return .DeviceType.computer
#else
    switch UIDevice.current.userInterfaceIdiom {
    case .phone:
        return .DeviceType.phone
    case .pad:
        return .DeviceType.tablet
    default:
        return .DeviceType.other
    }
#endif
}

/// Constants used in this file.
private extension String {

    /// The manufacturer of the device.
    static let apple = "Apple"

    /// The possible types of devices.
    enum DeviceType {
        static let phone = "phone"
        static let tablet = "tablet"
        static let computer = "computer"
        static let other = "other"
    }
}
