//
//  Version.swift
//  WBMAnalytics
//
//  Copyright © 2025 Wildberries LLC. All rights reserved.
//

import CoreGraphics

// swiftlint:disable file_length
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
    case iPhone17
    case iPhone17Pro
    case iPhone17Pro_Max
    case iPhone17e
    case iPhoneAir

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
    case iPadAirM4_11Inch
    case iPadAirM4_13Inch

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
    case iPadPro11_0Inch5
    case iPadPro12_9Inch4
    case iPadPro12_9Inch5
    case iPadPro12_9Inch6
    case iPadProM4_11Inch
    case iPadProM4_13Inch
    case iPadProM5_11Inch
    case iPadProM5_13Inch

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

    /*** tvOS (Apple TV) ***/
    case appleTV4
    case appleTV4K
    case appleTV4K_2ndGen
    case appleTV4K_3rdGen
    case appleTV4K_4thGen
}

// MARK: - Physical Size
extension Version {
    /// Physical screen size in pixels
    public var physicalSize: CGSize {
        switch self {
        // Apple TV models (logical points mapped to typical pixel dimensions)
        case .appleTV4:
            return CGSize(width: 1920, height: 1080)
        case .appleTV4K, .appleTV4K_2ndGen, .appleTV4K_3rdGen, .appleTV4K_4thGen:
            return CGSize(width: 3840, height: 2160)
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
            return CGSize(width: 1179, height: 2556)
        case .iPhone17:
            return CGSize(width: 1206, height: 2622)
        case .iPhone17Pro:
            return CGSize(width: 1206, height: 2622)
        case .iPhone17Pro_Max:
            return CGSize(width: 1320, height: 2868)
        case .iPhone17e:
            return CGSize(width: 1179, height: 2556)
        case .iPhoneAir:
            return CGSize(width: 1260, height: 2736)
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
        case .iPadAirM4_11Inch:
            return CGSize(width: 1640, height: 2360)
        case .iPadAirM4_13Inch:
            return CGSize(width: 2048, height: 2732)
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
        case .iPadPro11_0Inch5:
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
        case .iPadProM5_11Inch:
            return CGSize(width: 1668, height: 2420)
        case .iPadProM5_13Inch:
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

extension Version {
    // swiftlint:disable cyclomatic_complexity function_body_length
    init(modelID: String) {
        switch modelID {
        /*** iPhone **/
        case "iPhone1,1":
            self = .iPhone2G
        case "iPhone1,2":
            self = .iPhone3G
        case "iPhone2,1":
            self = .iPhone3GS
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":
            self = .iPhone4
        case "iPhone4,1":
            self = .iPhone4S
        case "iPhone5,1", "iPhone5,2":
            self = .iPhone5
        case "iPhone5,3", "iPhone5,4":
            self = .iPhone5C
        case "iPhone6,1", "iPhone6,2":
            self = .iPhone5S
        case "iPhone7,1":
            self = .iPhone6Plus
        case "iPhone7,2":
            self = .iPhone6
        case "iPhone8,1":
            self = .iPhone6S
        case "iPhone8,2":
            self = .iPhone6SPlus
        case "iPhone8,4":
            self = .iPhoneSE
        case "iPhone9,1", "iPhone9,3":
            self = .iPhone7
        case "iPhone9,2", "iPhone9,4":
            self = .iPhone7Plus
        case "iPhone10,1", "iPhone10,4":
            self = .iPhone8
        case "iPhone10,2", "iPhone10,5":
            self = .iPhone8Plus
        case "iPhone10,3", "iPhone10,6":
            self = .iPhoneX
        case "iPhone11,2":
            self = .iPhoneXS
        case "iPhone11,4", "iPhone11,6":
            self = .iPhoneXS_Max
        case "iPhone11,8":
            self = .iPhoneXR
        case "iPhone12,1":
            self = .iPhone11
        case "iPhone12,3":
            self = .iPhone11Pro
        case "iPhone12,5":
            self = .iPhone11Pro_Max
        case "iPhone12,8":
            self = .iPhoneSE2
        case "iPhone13,1":
            self = .iPhone12Mini
        case "iPhone13,2":
            self = .iPhone12
        case "iPhone13,3":
            self = .iPhone12Pro
        case "iPhone13,4":
            self = .iPhone12Pro_Max
        case "iPhone14,2":
            self = .iPhone13Pro
        case "iPhone14,3":
            self = .iPhone13Pro_Max
        case "iPhone14,4":
            self = .iPhone13Mini
        case "iPhone14,5":
            self = .iPhone13
        case "iPhone14,6":
            self = .iPhoneSE3
        case "iPhone14,7":
            self = .iPhone14
        case "iPhone14,8":
            self = .iPhone14Plus
        case "iPhone15,2":
            self = .iPhone14Pro
        case "iPhone15,3":
            self = .iPhone14Pro_Max
        case "iPhone15,4":
            self = .iPhone15
        case "iPhone15,5":
            self = .iPhone15Plus
        case "iPhone16,1":
            self = .iPhone15Pro
        case "iPhone16,2":
            self = .iPhone15Pro_Max
        case "iPhone17,1":
            self = .iPhone16Pro
        case "iPhone17,2":
            self = .iPhone16Pro_Max
        case "iPhone17,3":
            self = .iPhone16
        case "iPhone17,4":
            self = .iPhone16Plus
        case "iPhone17,5":
            self = .iPhone16e
        case "iPhone18,1":
            self = .iPhone17Pro
        case "iPhone18,2":
            self = .iPhone17Pro_Max
        case "iPhone18,3":
            self = .iPhone17
        case "iPhone18,4":
            self = .iPhoneAir
        case "iPhone18,5":
            self = .iPhone17e

        /*** iPad **/
        case "iPad1,1", "iPad1,2":
            self = .iPad1
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":
            self = .iPad2
        case "iPad3,1", "iPad3,2", "iPad3,3":
            self = .iPad3
        case "iPad2,5", "iPad2,6", "iPad2,7":
            self = .iPadMini
        case "iPad3,4", "iPad3,5", "iPad3,6":
            self = .iPad4
        case "iPad4,1", "iPad4,2", "iPad4,3":
            self = .iPadAir
        case "iPad4,4", "iPad4,5", "iPad4,6":
            self = .iPadMini2
        case "iPad4,7", "iPad4,8", "iPad4,9":
            self = .iPadMini3
        case "iPad5,1", "iPad5,2":
            self = .iPadMini4
        case "iPad5,3", "iPad5,4":
            self = .iPadAir2
        case "iPad6,3", "iPad6,4":
            self = .iPadPro9_7Inch
        case "iPad6,7", "iPad6,8":
            self = .iPadPro12_9Inch
        case "iPad6,11", "iPad6,12":
            self = .iPad5
        case "iPad7,1", "iPad7,2":
            self = .iPadPro12_9Inch2
        case "iPad7,3", "iPad7,4":
            self = .iPadPro10_5Inch
        case "iPad7,5", "iPad7,6":
            self = .iPad6
        case "iPad7,11", "iPad7,12":
            self = .iPad7
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":
            self = .iPadPro11_0Inch3
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":
            self = .iPadPro12_9Inch3
        case "iPad8,9", "iPad8,10":
            self = .iPadPro11_0Inch4
        case "iPad8,11", "iPad8,12":
            self = .iPadPro12_9Inch4
        case "iPad11,1", "iPad11,2":
            self = .iPadMini5
        case "iPad11,3", "iPad11,4":
            self = .iPadAir3
        case "iPad11,6", "iPad11,7":
            self = .iPad8
        case "iPad12,1", "iPad12,2":
            self = .iPad9
        case "iPad14,1", "iPad14,2":
            self = .iPadMini6
        case "iPad13,1", "iPad13,2":
            self = .iPadAir4
        case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":
            self = .iPadPro11_0Inch5
        case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":
            self = .iPadPro12_9Inch5
        case "iPad13,16", "iPad13,17":
            self = .iPadAir5
        case "iPad13,18", "iPad13,19":
            self = .iPad10
        case "iPad14,3", "iPad14,4":
            self = .iPadPro11_0Inch4
        case "iPad14,5", "iPad14,6":
            self = .iPadPro12_9Inch6
        case "iPad14,8", "iPad14,9":
            self = .iPadAirM2_11Inch
        case "iPad14,10", "iPad14,11":
            self = .iPadAirM2_13Inch
        case "iPad15,3", "iPad15,4":
            self = .iPadAirM3_11Inch
        case "iPad15,5", "iPad15,6":
            self = .iPadAirM3_13Inch
        case "iPad15,7", "iPad15,8":
            self = .iPadA16
        case "iPad16,1", "iPad16,2":
            self = .iPadMini7
        case "iPad16,3", "iPad16,4":
            self = .iPadProM4_11Inch
        case "iPad16,5", "iPad16,6":
            self = .iPadProM4_13Inch
        case "iPad16,8", "iPad16,9":
            self = .iPadAirM4_11Inch
        case "iPad16,10", "iPad16,11":
            self = .iPadAirM4_13Inch
        case "iPad17,1", "iPad17,2":
            self = .iPadProM5_11Inch
        case "iPad17,3", "iPad17,4":
            self = .iPadProM5_13Inch

        /*** iPod **/
        case "iPod1,1": self = .iPodTouch1Gen
        case "iPod2,1": self = .iPodTouch2Gen
        case "iPod3,1": self = .iPodTouch3Gen
        case "iPod4,1": self = .iPodTouch4Gen
        case "iPod5,1": self = .iPodTouch5Gen
        case "iPod7,1": self = .iPodTouch6Gen
        case "iPod9,1": self = .iPodTouch7Gen

        /*** simulator **/
        case "i386", "x86_64", "arm64":
            self = .simulator

        /*** tvOS (Apple TV) **/
        case "AppleTV5,3": self = .appleTV4
        case "AppleTV6,2": self = .appleTV4K
        case "AppleTV16,1": self = .appleTV4K_4thGen

        default: self = .unknown
        }
    }
}
