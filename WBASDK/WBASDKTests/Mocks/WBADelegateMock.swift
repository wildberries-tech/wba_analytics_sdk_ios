//
//  Copyright © 2024 WBA. All rights reserved.
//

import Foundation
@testable import WBASDK

final class WBADelegateMock: WBADelegateProtocol {

    private(set) var didResolveAttributedLinkWasCalled: Int = 0
    private(set) var didResolveAttributedLinkReceivedURL: URL?

    func didResolveAttributedLink(_ link: URL) {
        didResolveAttributedLinkWasCalled += 1
        didResolveAttributedLinkReceivedURL = link
    }
}
