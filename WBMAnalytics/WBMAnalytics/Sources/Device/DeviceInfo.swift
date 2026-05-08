//
//  DeviceInfo.swift
//  WBMAnalytics
//
//  Copyright © 2026 Wildberries LLC. All rights reserved.
//

public import Foundation
public import UIKit.UIDevice

/// Зеркальная модель UIDevice+Extension. Которой можно пользоваться
/// Не в Main потоке
public final class DeviceInfo: Sendable {
    public static let current: DeviceInfo = {
        func setup() -> DeviceInfo {
            MainActor.assumeIsolated {
                let device = UIDevice.current
                let screen = UIScreen.main
                let screenPixelsSize = screen.nativeBounds.size
                let screenBoundsSize = screen.bounds.size
                let identifierForVendor = device.identifierForVendor
                let userInterfaceIdiom = device.userInterfaceIdiom
                let systemVersion = device.systemVersion

                return DeviceInfo(
                    isIpad: userInterfaceIdiom == .pad,
                    deviceId: identifierForVendor?.uuidString.replacingOccurrences(of: "-", with: ""),
                    screenPixelsSize: screenPixelsSize,
                    screenPixelsScale: screen.nativeScale,
                    screenPointsSize: screenBoundsSize.vertical,
                    screenScale: screen.scale,
                    // FIXME: https://youtrack.wildberries.ru/issue/IOS-60129
                    iOSVersion: (systemVersion as NSString).floatValue,
                    userInterfaceIdiom: userInterfaceIdiom,
                    identifierForVendor: identifierForVendor,
                    name: device.name,
                    systemVersion: systemVersion
                )
            }
        }

        if Thread.isMainThread {
            return setup()
        }

        dispatchPrecondition(condition: .notOnQueue(.main))
        return DispatchQueue.main.sync {
            setup()
        }
    }()

    public let isIpad: Bool
    public let deviceId: String?

    /// Not affected by rotating device
    /// соответствует Points (Standard) или Points (Zoomed) из таблицы:
    /// https://gist.github.com/ricsantos/e7baee6885626b9cb87c021a5097623f
    public let screenPointsSize: CGSize
    /// Отношение Device Resolution к текущим Points (т.е. Standard или Zoomed) из таблицы:
    /// https://gist.github.com/ricsantos/e7baee6885626b9cb87c021a5097623f
    /// == 2 для iPhone XR, 11, 8-, SE (3- gen)
    /// == 2 для iPad
    /// == 3 для остальных устройств
    public let screenScale: CGFloat
    /// соответствует Screen Resolution из таблицы:
    /// https://gist.github.com/ricsantos/e7baee6885626b9cb87c021a5097623f
    public let screenPixelsSize: CGSize
    /// Отношение Screen Resolution к текущим Points (т.е. Standard или Zoomed) из таблицы:
    /// https://gist.github.com/ricsantos/e7baee6885626b9cb87c021a5097623f
    /// Если Zoom выключен, то обычно равен screenScale
    /// Хотя на некоторых устройствах будет меньше, ex: iPhone 12/13 mini, 6/6s/7/8 Plus
    /// Если же Zoom включен, то будет больше screenScale
    /// даже на упомянутых устройствах
    private let screenPixelsScale: CGFloat

    public let iOSVersion: Float
    public let userInterfaceIdiom: UIUserInterfaceIdiom
    public let identifierForVendor: UUID?
    public let name: String
    public let systemVersion: String

    @MainActor
    public var orientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }

    @MainActor
    public var isBatteryMonitoringEnabled: Bool {
        get {
            UIDevice.current.isBatteryMonitoringEnabled
        }

        set {
            UIDevice.current.isBatteryMonitoringEnabled = newValue
        }
    }

    @MainActor
    public var batteryState: UIDevice.BatteryState {
        UIDevice.current.batteryState
    }

    public static var orientationDidChangeNotification: NSNotification.Name {
        UIDevice.orientationDidChangeNotification
    }

    public static var batteryStateDidChangeNotification: NSNotification.Name {
        UIDevice.batteryStateDidChangeNotification
    }

    /// Возвращает тип устройства как строку (например, "iPhone", "iPad", "iPod")
    public var deviceType: String {
        switch userInterfaceIdiom {
        case .phone:
            return "iPhone"
        case .pad:
            return "iPad"
        case .tv:
            return "appleTV"
        case .carPlay:
            return "CarPlay"
        case .mac:
            return "Mac"
        case .vision:
            return "Vision"
        case .unspecified:
            return "unknown"
        @unknown default:
            return "unknown"
        }
    }

    public static let modelID: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }()

    public static let modelName: String = {
        convertIdentifierToModelName(modelID)
    }()

    public static func modelName(identifier: String) -> String {
        convertIdentifierToModelName(identifier)
    }

    /// Объем физически доступной памяти на устройстве в MB
    public static let availableRAM: UInt64 = {
        /// Available RAM in GBs
        let bytesPerGigabyte: UInt64 = 1024 * 1024 * 1024
        let availableRAM: UInt64 = ProcessInfo.processInfo.physicalMemory / bytesPerGigabyte

        return availableRAM
    }()

    // Получает версию билда OS
    public static let osBuildIdentifier: String = {
        let versionString = ProcessInfo.processInfo.operatingSystemVersionString
        if let buildIdRange = versionString.range(of: String.osBuildNumberRegExPattern, options: .regularExpression) {
            return String(versionString[buildIdRange])
        } else {
            return .buildIdNotFoundString
        }
    }()

    // MARK: - private

    private init(
        isIpad: Bool,
        deviceId: String?,
        screenPixelsSize: CGSize,
        screenPixelsScale: CGFloat,
        screenPointsSize: CGSize,
        screenScale: CGFloat,
        iOSVersion: Float,
        userInterfaceIdiom: UIUserInterfaceIdiom,
        identifierForVendor: UUID?,
        name: String,
        systemVersion: String
    ) {
        self.isIpad = isIpad
        self.deviceId = deviceId
        self.screenPixelsSize = screenPixelsSize
        self.screenPixelsScale = screenPixelsScale
        self.screenPointsSize = screenPointsSize
        self.screenScale = screenScale
        self.iOSVersion = iOSVersion
        self.userInterfaceIdiom = userInterfaceIdiom
        self.identifierForVendor = identifierForVendor
        self.name = name
        self.systemVersion = systemVersion
    }

    // swiftlint:disable cyclomatic_complexity
    private static func convertIdentifierToModelName(_ identifier: String) -> String {
        switch identifier {
        case "iPod9,1":                                  return "iPod Touch 7"

        case "iPhone8,1":                                return "iPhone 6s"
        case "iPhone8,2":                                return "iPhone 6s Plus"
        case "iPhone8,4":                                return "iPhone SE"
        case "iPhone9,1", "iPhone9,3":                   return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                   return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":                 return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                 return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                 return "iPhone X"
        case "iPhone11,2":                               return "iPhone XS"
        case "iPhone11,4", "iPhone11,6":                 return "iPhone XS Max"
        case "iPhone11,8":                               return "iPhone XR"
        case "iPhone12,1":                               return "iPhone 11"
        case "iPhone12,3":                               return "iPhone 11 Pro"
        case "iPhone12,5":                               return "iPhone 11 Pro Max"
        case "iPhone12,8":                               return "iPhone SE 2nd Gen"
        case "iPhone13,1":                               return "iPhone 12 Mini"
        case "iPhone13,2":                               return "iPhone 12"
        case "iPhone13,3":                               return "iPhone 12 Pro"
        case "iPhone13,4":                               return "iPhone 12 Pro Max"
        case "iPhone14,2":                               return "iPhone 13 Pro"
        case "iPhone14,3":                               return "iPhone 13 Pro Max"
        case "iPhone14,4":                               return "iPhone 13 Mini"
        case "iPhone14,5":                               return "iPhone 13"
        case "iPhone14,6":                               return "iPhone SE 3rd Gen"
        case "iPhone14,7":                               return "iPhone 14"
        case "iPhone14,8":                               return "iPhone 14 Plus"
        case "iPhone15,2":                               return "iPhone 14 Pro"
        case "iPhone15,3":                               return "iPhone 14 Pro Max"
        case "iPhone15,4":                               return "iPhone 15"
        case "iPhone15,5":                               return "iPhone 15 Plus"
        case "iPhone16,1":                               return "iPhone 15 Pro"
        case "iPhone16,2":                               return "iPhone 15 Pro Max"
        case "iPhone17,1":                               return "iPhone 16 Pro"
        case "iPhone17,2":                               return "iPhone 16 Pro Max"
        case "iPhone17,3":                               return "iPhone 16"
        case "iPhone17,4":                               return "iPhone 16 Plus"
        case "iPhone17,5":                               return "iPhone 16e"
        case "iPhone18,1":                               return "iPhone 17 Pro"
        case "iPhone18,2":                               return "iPhone 17 Pro Max"
        case "iPhone18,3":                               return "iPhone 17"
        case "iPhone18,4":                               return "iPhone Air"
        case "iPhone18,5":                               return "iPhone 17e"

        case "iPad5,1", "iPad5,2":                       return "iPad Mini 4"
        case "iPad5,3", "iPad5,4":                       return "iPad Air 2"
        case "iPad6,3", "iPad6,4":                       return "iPad Pro 9.7 Inch"
        case "iPad6,7", "iPad6,8":                       return "iPad Pro 12.9 Inch"
        case "iPad6,11", "iPad6,12":                     return "iPad 5"
        case "iPad7,1", "iPad7,2":                       return "iPad Pro 12.9 Inch 2nd Generation"
        case "iPad7,3", "iPad7,4":                       return "iPad Pro 10.5 Inch"
        case "iPad7,5", "iPad7,6":                       return "iPad 6"
        case "iPad7,11", "iPad7,12":                     return "iPad 7"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": return "iPad Pro 11 Inch 3rd Generation"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": return "iPad Pro 12.9 Inch 3rd Generation"
        case "iPad8,9", "iPad8,10":                      return "iPad Pro 11 Inch 4th Generation"
        case "iPad8,11", "iPad8,12":                     return "iPad Pro 12.9 inch 4th Generation"
        case "iPad11,1", "iPad11,2":                     return "iPad mini 5"
        case "iPad11,3", "iPad11,4":                     return "iPad Air 3"
        case "iPad11,6", "iPad11,7":                     return "iPad 8"
        case "iPad12,1", "iPad12,2":                     return "iPad 9"
        case "iPad14,1", "iPad14,2":                     return "iPad Mini 6"
        case "iPad13,1", "iPad13,2":                     return "iPad Air 4"
        case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7": return "iPad Pro 11 Inch 5th Generation"
        case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11": return "iPad Pro 12.9 Inch 5th Generation"
        case "iPad13,16", "iPad13,17":                   return "iPad Air 5"
        case "iPad13,18", "iPad13,19":                   return "iPad 10"
        case "iPad14,3", "iPad14,4":                     return "iPad Pro 11 Inch 4th Gen"
        case "iPad14,5", "iPad14,6":                     return "iPad Pro 12.9 Inch 6th Gen"
        case "iPad14,8", "iPad14,9":                     return "iPad Air 6"
        case "iPad14,10", "iPad14,11":                   return "iPad Air 7"
        case "iPad16,1", "iPad16,2":                     return "iPad Mini 7"
        case "iPad16,3", "iPad16,4":                     return "iPad Pro 11-Inch 5"
        case "iPad16,5", "iPad16,6":                     return "iPad Pro 12.9-Inch 7"
        case "iPad16,8", "iPad16,9":                     return "iPad Air 11 Inch (M4)"
        case "iPad16,10", "iPad16,11":                   return "iPad Air 13 Inch (M4)"
        case "iPad15,7", "iPad15,8":                     return "iPad 11"
        case "iPad15,3", "iPad15,4":                     return "iPad Air 11 Inch 7th Gen"
        case "iPad15,5", "iPad15,6":                     return "iPad Air 13 Inch 7th Gen"
        case "iPad17,1", "iPad17,2":                     return "iPad Pro 11 Inch 8th Gen"
        case "iPad17,3", "iPad17,4":                     return "iPad Pro 13 Inch 8th Gen"

        case "Mac15,14":                                 return "Mac Studio (M3 Ultra, 2025)"
        case "Mac16,2", "Mac16,3":                       return "iMac 24-inch (M4, 2024)"
        case "Mac16,9":                                  return "Mac Studio (M4 Max, 2025)"
        case "Mac16,10", "Mac16,11":                     return "Mac mini (2024)"
        case "Mac16,12":                                 return "MacBook Air 13-inch (M4)"
        case "Mac16,13":                                 return "MacBook Air 15-inch (M4)"
        case "Mac17,2":                                  return "MacBook Pro 14-inch (M5)"
        case "Mac17,3":                                  return "MacBook Air 13-inch (M5)"
        case "Mac17,4":                                  return "MacBook Air 15-inch (M5)"
        case "Mac17,6", "Mac17,8":                       return "MacBook Pro 16-inch (M5 Pro/Max)"
        case "Mac17,7", "Mac17,9":                       return "MacBook Pro 14-inch (M5 Pro/Max)"

        case "Watch7,1", "Watch7,2", "Watch7,3", "Watch7,4":
            return "Apple Watch Series 9"
        case "Watch7,5":
            return "Apple Watch Ultra 2"
        case "Watch7,8", "Watch7,9", "Watch7,10", "Watch7,11":
            return "Apple Watch Series 10"
        case "Watch7,12":
            return "Apple Watch Ultra 3"
        case "Watch7,13", "Watch7,14", "Watch7,15", "Watch7,16":
            return "Apple Watch SE 3"
        case "Watch7,17", "Watch7,18", "Watch7,19", "Watch7,20":
            return "Apple Watch Series 11"
        case "Watch6,10", "Watch6,11", "Watch6,12", "Watch6,13", "Watch6,14", "Watch6,15", "Watch6,16", "Watch6,17", "Watch6,18":
            return "Apple Watch Series 8 / SE 2 / Ultra 1"

        case "RealityDevice17,1":                        return "Apple Vision Pro (M5)"

        case "AppleTV5,3":                               return "Apple TV"
        case "AppleTV6,2", "AppleTV11,1", "AppleTV14,1": return "Apple TV 4K"
        case "AppleTV16,1":                              return "Apple TV 4K (2026)"

        case "AudioAccessory1,1",
             "AudioAccessory1,2",
             "AudioAccessory5,1",
             "AudioAccessory6,1":                        return "HomePod"

        case "i386", "x86_64", "arm64":                  return .simulatorModelName
        default:                                         return identifier
        }
    }
}

// MARK: - Constants

private extension String {
    static let simulatorModelName = "Simulator"
    static let osBuildNumberRegExPattern = #"(?<=Build )\S+(?=\))"#
    static let buildIdNotFoundString = "OS build identifier could not be found"
}

private extension CGSize {
    var vertical: Self {
        Self(width: min(width, height), height: max(width, height))
    }
}
