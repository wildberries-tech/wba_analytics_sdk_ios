// Copyright © 2024 Wildberries. All rights reserved.

import Foundation

/// Extension to URLRequest to generate a cURL command.
/// This can be useful for debugging network requests.
extension URLRequest {

    /// Generates a cURL command based on the URLRequest.
    /// - Parameter pretty: If true, the generated command will be formatted for readability.
    /// - Returns: A cURL command as a String.
    func cURL(pretty: Bool = false) -> String {
        let newLine = pretty ? "\\\n" : ""
        let method = (pretty ? "--request " : "-X ") + "\(self.httpMethod ?? "GET") \(newLine)"
        let url: String = (pretty ? "--url " : "") + "\'\(self.url?.absoluteString ?? "")\' \(newLine)"
        var cURL = "curl "
        var header = ""
        var data: String = ""

        if let httpHeaders = self.allHTTPHeaderFields, httpHeaders.keys.count > 0 {
            for (key, value) in httpHeaders {
                header += (pretty ? "--header " : "-H ") + "\'\(key): \(value)\' \(newLine)"
            }
        }
        if let bodyData = self.httpBody {
        // swiftlint:disable optional_data_string_conversion
           let bodyString = String(decoding: bodyData, as: UTF8.self)
            if !bodyString.isEmpty {
                data = "--data '\(String(describing: bodyString))'"
            }
        }
        cURL += method + url + header + data
        return cURL
    }
}
