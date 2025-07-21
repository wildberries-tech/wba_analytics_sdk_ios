//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

protocol FileHandleProtocol {
    init(forWritingTo url: URL) throws
    @discardableResult
    func seekToEndOfFile() -> UInt64
    func write(_ data: Data)
    @available(iOS 13.4, *)
    func write<T>(contentsOf data: T) throws where T : DataProtocol
}

extension FileHandle: FileHandleProtocol {}
