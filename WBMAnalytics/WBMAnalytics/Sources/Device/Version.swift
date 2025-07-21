//
//  Version.swift
//  WBMAnalytics
//
//  Copyright © 2025 Wildberries LLC. All rights reserved.
//

import CoreGraphics

// swiftlint:disable identifier_name
public enum Version: String {
    /*** iPhone ***/
    case iPhone2G
    case iPhone3G
    case iPhone3GS
    case iPhone4
    case iPhone4S
    case iPhone5
    case iPhone5C
    case iPhone5S
    case iPhone6
    case iPhone6Plus
    case iPhone6S
    case iPhone6SPlus
    case iPhoneSE
    case iPhone7
    case iPhone7Plus
    case iPhone8
    case iPhone8Plus
    case iPhoneX
    case iPhoneXS
    case iPhoneXS_Max
    case iPhoneXR
    case iPhone11
    case iPhone11Pro
    case iPhone11Pro_Max
    case iPhoneSE2
    case iPhone12Mini
    case iPhone12
    case iPhone12Pro
    case iPhone12Pro_Max
    case iPhone13Mini
    case iPhone13
    case iPhone13Pro
    case iPhone13Pro_Max
    case iPhoneSE3
    case iPhone14
    case iPhone14Plus
    case iPhone14Pro
    case iPhone14Pro_Max
    case iPhone15
    case iPhone15Plus
    case iPhone15Pro
    case iPhone15Pro_Max
    case iPhone16
    case iPhone16Plus
    case iPhone16Pro
    case iPhone16Pro_Max
    case iPhone16e

    /*** iPad ***/
    case iPad1
    case iPad2
    case iPad3
    case iPad4
    case iPad5
    case iPad6
    case iPad7
    case iPad8
    case iPad9
    case iPad10
    case iPadA16
    case iPadAir
    case iPadAir2
    case iPadAir3
    case iPadAir4
    case iPadAir5
    case iPadMini
    case iPadMini2
    case iPadMini3
    case iPadMini4
    case iPadMini5
    case iPadMini6
    case iPadMini7
    case iPadAirM2_11Inch
    case iPadAirM2_13Inch
    case iPadAirM3_11Inch
    case iPadAirM3_13Inch

    /*** iPadPro ***/
    case iPadPro9_7Inch
    case iPadPro12_9Inch
    case iPadPro10_5Inch
    case iPadPro12_9Inch2
    case iPadPro11_0Inch
    case iPadPro12_9Inch3
    case iPadPro11_0Inch2
    case iPadPro11_0Inch3
    case iPadPro11_0Inch4
    case iPadPro12_9Inch4
    case iPadPro12_9Inch5
    case iPadPro12_9Inch6
    case iPadProM4_11Inch
    case iPadProM4_13Inch

    /*** iPod ***/
    case iPodTouch1Gen
    case iPodTouch2Gen
    case iPodTouch3Gen
    case iPodTouch4Gen
    case iPodTouch5Gen
    case iPodTouch6Gen
    case iPodTouch7Gen

    /*** simulator ***/
    case simulator

    /*** unknown ***/
    case unknown
}

// MARK: - Physical Size
extension Version {
    /// Physical screen size in pixels
    public var physicalSize: CGSize {
        switch self {
        // iPhone models
        case .iPhone2G:
            return CGSize(width: 320, height: 480)
        case .iPhone3G:
            return CGSize(width: 320, height: 480)
        case .iPhone3GS:
            return CGSize(width: 320, height: 480)
        case .iPhone4:
            return CGSize(width: 640, height: 960)
        case .iPhone4S:
            return CGSize(width: 640, height: 960)
        case .iPhone5:
            return CGSize(width: 640, height: 1136)
        case .iPhone5C:
            return CGSize(width: 640, height: 1136)
        case .iPhone5S:
            return CGSize(width: 640, height: 1136)
        case .iPhone6:
            return CGSize(width: 750, height: 1334)
        case .iPhone6Plus:
            return CGSize(width: 1080, height: 1920)
        case .iPhone6S:
            return CGSize(width: 750, height: 1334)
        case .iPhone6SPlus:
            return CGSize(width: 1080, height: 1920)
        case .iPhoneSE:
            return CGSize(width: 640, height: 1136)
        case .iPhone7:
            return CGSize(width: 750, height: 1334)
        case .iPhone7Plus:
            return CGSize(width: 1080, height: 1920)
        case .iPhone8:
            return CGSize(width: 750, height: 1334)
        case .iPhone8Plus:
            return CGSize(width: 1080, height: 1920)
        case .iPhoneX:
            return CGSize(width: 1125, height: 2436)
        case .iPhoneXS:
            return CGSize(width: 1125, height: 2436)
        case .iPhoneXS_Max:
            return CGSize(width: 1242, height: 2688)
        case .iPhoneXR:
            return CGSize(width: 828, height: 1792)
        case .iPhone11:
            return CGSize(width: 828, height: 1792)
        case .iPhone11Pro:
            return CGSize(width: 1125, height: 2436)
        case .iPhone11Pro_Max:
            return CGSize(width: 1242, height: 2688)
        case .iPhoneSE2:
            return CGSize(width: 750, height: 1334)
        case .iPhone12Mini:
            return CGSize(width: 1080, height: 2340)
        case .iPhone12:
            return CGSize(width: 1170, height: 2532)
        case .iPhone12Pro:
            return CGSize(width: 1170, height: 2532)
        case .iPhone12Pro_Max:
            return CGSize(width: 1284, height: 2778)
        case .iPhone13Mini:
            return CGSize(width: 1080, height: 2340)
        case .iPhone13:
            return CGSize(width: 1170, height: 2532)
        case .iPhone13Pro:
            return CGSize(width: 1170, height: 2532)
        case .iPhone13Pro_Max:
            return CGSize(width: 1284, height: 2778)
        case .iPhoneSE3:
            return CGSize(width: 750, height: 1334)
        case .iPhone14:
            return CGSize(width: 1170, height: 2532)
        case .iPhone14Plus:
            return CGSize(width: 1284, height: 2778)
        case .iPhone14Pro:
            return CGSize(width: 1179, height: 2556)
        case .iPhone14Pro_Max:
            return CGSize(width: 1290, height: 2796)
        case .iPhone15:
            return CGSize(width: 1179, height: 2556)
        case .iPhone15Plus:
            return CGSize(width: 1290, height: 2796)
        case .iPhone15Pro:
            return CGSize(width: 1179, height: 2556)
        case .iPhone15Pro_Max:
            return CGSize(width: 1290, height: 2796)
        case .iPhone16:
            return CGSize(width: 1179, height: 2556)
        case .iPhone16Plus:
            return CGSize(width: 1290, height: 2796)
        case .iPhone16Pro:
            return CGSize(width: 1206, height: 2622)
        case .iPhone16Pro_Max:
            return CGSize(width: 1320, height: 2868)
        case .iPhone16e:
            return CGSize(width: 1179, height: 2556) // Fallback to iPhone 16 size
        // iPad models
        case .iPad1:
            return CGSize(width: 768, height: 1024)
        case .iPad2:
            return CGSize(width: 768, height: 1024)
        case .iPad3:
            return CGSize(width: 1536, height: 2048)
        case .iPad4:
            return CGSize(width: 1536, height: 2048)
        case .iPad5:
            return CGSize(width: 1536, height: 2048)
        case .iPad6:
            return CGSize(width: 1536, height: 2048)
        case .iPad7:
            return CGSize(width: 1620, height: 2160)
        case .iPad8:
            return CGSize(width: 1620, height: 2160)
        case .iPad9:
            return CGSize(width: 1620, height: 2160)
        case .iPad10:
            return CGSize(width: 1640, height: 2360)
        case .iPadA16:
            return CGSize(width: 1640, height: 2360) // Fallback to iPad 10th gen size
        case .iPadAir:
            return CGSize(width: 1536, height: 2048)
        case .iPadAir2:
            return CGSize(width: 1536, height: 2048)
        case .iPadAir3:
            return CGSize(width: 1668, height: 2224)
        case .iPadAir4:
            return CGSize(width: 1640, height: 2360)
        case .iPadAir5:
            return CGSize(width: 1640, height: 2360)
        case .iPadMini:
            return CGSize(width: 768, height: 1024)
        case .iPadMini2:
            return CGSize(width: 1536, height: 2048)
        case .iPadMini3:
            return CGSize(width: 1536, height: 2048)
        case .iPadMini4:
            return CGSize(width: 1536, height: 2048)
        case .iPadMini5:
            return CGSize(width: 1536, height: 2048)
        case .iPadMini6:
            return CGSize(width: 1488, height: 2266)
        case .iPadMini7:
            return CGSize(width: 1488, height: 2266)
        case .iPadAirM2_11Inch:
            return CGSize(width: 1640, height: 2360)
        case .iPadAirM2_13Inch:
            return CGSize(width: 2048, height: 2732)
        case .iPadAirM3_11Inch:
            return CGSize(width: 1640, height: 2360) // Fallback to M2 11" size
        case .iPadAirM3_13Inch:
            return CGSize(width: 2048, height: 2732) // Fallback to M2 13" size
        // iPad Pro models
        case .iPadPro9_7Inch:
            return CGSize(width: 1536, height: 2048)
        case .iPadPro12_9Inch:
            return CGSize(width: 2048, height: 2732)
        case .iPadPro10_5Inch:
            return CGSize(width: 1668, height: 2224)
        case .iPadPro12_9Inch2:
            return CGSize(width: 2048, height: 2732)
        case .iPadPro11_0Inch:
            return CGSize(width: 1668, height: 2388)
        case .iPadPro12_9Inch3:
            return CGSize(width: 2048, height: 2732)
        case .iPadPro11_0Inch2:
            return CGSize(width: 1668, height: 2388)
        case .iPadPro11_0Inch3:
            return CGSize(width: 1668, height: 2388)
        case .iPadPro11_0Inch4:
            return CGSize(width: 1668, height: 2388)
        case .iPadPro12_9Inch4:
            return CGSize(width: 2048, height: 2732)
        case .iPadPro12_9Inch5:
            return CGSize(width: 2048, height: 2732)
        case .iPadPro12_9Inch6:
            return CGSize(width: 2048, height: 2732)
        case .iPadProM4_11Inch:
            return CGSize(width: 1668, height: 2420)
        case .iPadProM4_13Inch:
            return CGSize(width: 2064, height: 2752)
        // iPod models
        case .iPodTouch1Gen:
            return CGSize(width: 320, height: 480)
        case .iPodTouch2Gen:
            return CGSize(width: 320, height: 480)
        case .iPodTouch3Gen:
            return CGSize(width: 320, height: 480)
        case .iPodTouch4Gen:
            return CGSize(width: 640, height: 960)
        case .iPodTouch5Gen:
            return CGSize(width: 640, height: 1136)
        case .iPodTouch6Gen:
            return CGSize(width: 640, height: 1136)
        case .iPodTouch7Gen:
            return CGSize(width: 640, height: 1136)
        // Special cases
        case .simulator, .unknown:
            return CGSize.zero
        }
    }
}
