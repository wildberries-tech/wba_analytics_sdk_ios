//
//  Copyright © 2026 Wildberries LLC. All rights reserved.
//

// swiftlint:disable identifier_name
extension Version {
    // swiftlint:disable type_name
    enum CPU {
        case s5l8720
        case s5l8900
        case s5l8920
        case s5pc100
        case a4
        case a5
        case a5X
        case a6
        case a6X
        case a7
        case a8
        case a8X
        case a9
        case a9X
        case a10Fusion
        case a10XFusion
        case a11Bionic
        case a12Bionic
        case a12XBionic
        case a12ZBionic
        case a13Bionic
        case a14Bionic
        case a15Bionic
        case a16Bionic
        case a17Pro
        case a18
        case a18Pro
        case a19
        case a19Pro
        case m1
        case m2
        case m3
        case m4
        case m5
        case unknown
    }

    /// CPU type
    var cpu: CPU {
        switch self {
        /*** iPhone **/
        case .iPhone2G: return .s5l8900
        case .iPhone3G: return .s5l8900
        case .iPhone3GS: return .s5pc100
        case .iPhone4: return .a4
        case .iPhone4S: return .a5
        case .iPhone5: return .a6
        case .iPhone5C: return .a6
        case .iPhone5S: return .a7
        case .iPhone6: return .a8
        case .iPhone6Plus: return .a8
        case .iPhone6S: return .a9
        case .iPhone6SPlus: return .a9
        case .iPhoneSE: return .a9
        case .iPhone7: return .a10Fusion
        case .iPhone7Plus: return .a10Fusion
        case .iPhone8: return .a11Bionic
        case .iPhone8Plus: return .a11Bionic
        case .iPhoneX: return .a11Bionic
        case .iPhoneXS: return .a12Bionic
        case .iPhoneXS_Max: return .a12Bionic
        case .iPhoneXR: return .a12Bionic
        case .iPhone11: return .a13Bionic
        case .iPhone11Pro: return .a13Bionic
        case .iPhone11Pro_Max: return .a13Bionic
        case .iPhoneSE2: return .a13Bionic
        case .iPhone12Mini: return .a14Bionic
        case .iPhone12: return .a14Bionic
        case .iPhone12Pro: return .a14Bionic
        case .iPhone12Pro_Max: return .a14Bionic
        case .iPhone13Mini: return .a15Bionic
        case .iPhone13: return .a15Bionic
        case .iPhone13Pro: return .a15Bionic
        case .iPhone13Pro_Max: return .a15Bionic
        case .iPhoneSE3: return .a15Bionic
        case .iPhone14: return .a15Bionic
        case .iPhone14Plus: return .a15Bionic
        case .iPhone14Pro: return .a16Bionic
        case .iPhone14Pro_Max: return .a16Bionic
        case .iPhone15: return .a16Bionic
        case .iPhone15Plus: return .a16Bionic
        case .iPhone15Pro: return .a17Pro
        case .iPhone15Pro_Max: return .a17Pro
        case .iPhone16: return .a18
        case .iPhone16Plus: return .a18
        case .iPhone16Pro: return .a18Pro
        case .iPhone16Pro_Max: return .a18Pro
        case .iPhone16e: return .a18
        case .iPhone17: return .a19
        case .iPhone17Pro: return .a19Pro
        case .iPhone17Pro_Max: return .a19Pro
        case .iPhone17e: return .a19
        case .iPhoneAir: return .a19Pro

        /*** iPad **/
        case .iPad1: return .a4
        case .iPad2: return .a5
        case .iPad3: return .a5X
        case .iPad4: return .a6X
        case .iPad5: return .a9
        case .iPad6: return .a10Fusion
        case .iPad7: return .a10Fusion
        case .iPad8: return .a12Bionic
        case .iPad9: return .a13Bionic
        case .iPad10: return .a14Bionic
        case .iPadA16: return .a16Bionic
        case .iPadAir: return .a7
        case .iPadAir2: return .a8X
        case .iPadAir3: return .a12Bionic
        case .iPadAir4: return .a14Bionic
        case .iPadAir5: return .m1
        case .iPadMini: return .a5
        case .iPadMini2: return .a7
        case .iPadMini3: return .a7
        case .iPadMini4: return .a8
        case .iPadMini5: return .a12Bionic
        case .iPadMini6: return .a15Bionic
        case .iPadMini7: return .a17Pro
        case .iPadAirM2_11Inch: return .m2
        case .iPadAirM2_13Inch: return .m2
        case .iPadAirM3_11Inch: return .m3
        case .iPadAirM3_13Inch: return .m3
        case .iPadAirM4_11Inch: return .m4
        case .iPadAirM4_13Inch: return .m4

        /*** iPadPro **/
        case .iPadPro9_7Inch: return .a9X
        case .iPadPro12_9Inch: return .a9X
        case .iPadPro10_5Inch: return .a10XFusion
        case .iPadPro12_9Inch2: return .a10XFusion
        case .iPadPro11_0Inch: return .a12XBionic
        case .iPadPro12_9Inch3: return .a12XBionic
        case .iPadPro11_0Inch2: return .a12ZBionic
        case .iPadPro11_0Inch3: return .m1
        case .iPadPro11_0Inch4: return .m2
        case .iPadPro12_9Inch4: return .a12ZBionic
        case .iPadPro11_0Inch5: return .m1
        case .iPadPro12_9Inch5: return .m1
        case .iPadPro12_9Inch6: return .m2
        case .iPadProM4_11Inch: return .m4
        case .iPadProM4_13Inch: return .m4
        case .iPadProM5_11Inch: return .m5
        case .iPadProM5_13Inch: return .m5

        /*** iPod **/
        case .iPodTouch1Gen: return .s5l8900
        case .iPodTouch2Gen: return .s5l8920
        case .iPodTouch3Gen: return .s5l8720
        case .iPodTouch4Gen: return .a4
        case .iPodTouch5Gen: return .a5
        case .iPodTouch6Gen: return .a8
        case .iPodTouch7Gen: return .a10Fusion

        /*** simulator **/
        case .simulator: return .unknown

        /*** unknown **/
        case .unknown: return .unknown

        /*** tvOS (Apple TV) **/
        case .appleTV4: return .a8
        case .appleTV4K: return .a10XFusion
        case .appleTV4K_2ndGen: return .a12Bionic
        case .appleTV4K_3rdGen: return .a15Bionic
        case .appleTV4K_4thGen: return .a17Pro
        }
    }

    /// CPU clock frequency, GHz
    var frequency: Double {
        switch self.cpu {
        case .s5l8720: return 0.533
        case .s5l8900: return 0.412
        case .s5l8920: return 0.600
        case .s5pc100: return 0.600
        case .a4: return 1
        case .a5: return 1
        case .a5X: return 1
        case .a6: return 1.3
        case .a6X: return 1.4
        case .a7: return 1.4
        case .a8: return 1.5
        case .a8X: return 1.5
        case .a9: return 1.85
        case .a9X: return 2.26
        case .a10Fusion: return 2.34
        case .a10XFusion: return 2.39
        case .a11Bionic: return 2.39
        case .a12Bionic: return 2.49
        case .a12XBionic: return 2.49
        case .a12ZBionic: return 2.5
        case .a13Bionic: return 2.65
        case .a14Bionic: return 3.1
        case .a15Bionic: return 3.24
        case .a16Bionic: return 3.46
        case .a17Pro: return 3.78
        case .a18: return 3.78
        case .a18Pro: return 4.04
        case .a19, .a19Pro: return 4.26
        case .m1: return 3.2
        case .m2: return 3.2
        case .m3: return 4.05
        case .m4: return 4.41
        case .m5: return 4.61
        case .unknown: return 1
        }
    }
}

extension Version.CPU {
    /// Marketing name of the processor. The iOS equivalent of Build.SOC_MODEL on Android:
    /// there's no direct system source on iOS — sysctl machdep.cpu.brand_string doesn't
    /// return a value on Apple Silicon devices.
    var name: String {
        switch self {
        case .s5l8720: return "S5L8720"
        case .s5l8900: return "S5L8900"
        case .s5l8920: return "S5L8920"
        case .s5pc100: return "S5PC100"
        case .a4: return "A4"
        case .a5: return "A5"
        case .a5X: return "A5X"
        case .a6: return "A6"
        case .a6X: return "A6X"
        case .a7: return "A7"
        case .a8: return "A8"
        case .a8X: return "A8X"
        case .a9: return "A9"
        case .a9X: return "A9X"
        case .a10Fusion: return "A10 Fusion"
        case .a10XFusion: return "A10X Fusion"
        case .a11Bionic: return "A11 Bionic"
        case .a12Bionic: return "A12 Bionic"
        case .a12XBionic: return "A12X Bionic"
        case .a12ZBionic: return "A12Z Bionic"
        case .a13Bionic: return "A13 Bionic"
        case .a14Bionic: return "A14 Bionic"
        case .a15Bionic: return "A15 Bionic"
        case .a16Bionic: return "A16 Bionic"
        case .a17Pro: return "A17 Pro"
        case .a18: return "A18"
        case .a18Pro: return "A18 Pro"
        case .a19: return "A19"
        case .a19Pro: return "A19 Pro"
        case .m1: return "M1"
        case .m2: return "M2"
        case .m3: return "M3"
        case .m4: return "M4"
        case .m5: return "M5"
        case .unknown: return "unknown"
        }
    }
}
