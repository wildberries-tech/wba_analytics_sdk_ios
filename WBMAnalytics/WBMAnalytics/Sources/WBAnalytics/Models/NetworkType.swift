// Copyright © 2021 Wildberries. All rights reserved.

/// Enum representing the type of network connection.
public enum WBMNetworkType: String {
    case wifi = "Wi-Fi"
    case ethernet = "Ethernet"
    case cellular2G = "2G", cellular3G = "3G", cellular4G = "4G", cellular5G = "5G"
    case other = "Other"
}
