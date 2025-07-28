//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation
@testable import WBMAnalytics

final class WBAnalyticsDelegateMock: WBAnalyticsDelegateProtocol {

    private(set) var didResolveAttributedLinkWasCalled: Int = 0
    private(set) var didResolveAttributedLinkReceivedURL: URL?

    func didResolveAttributedLink(_ link: URL) {
        didResolveAttributedLinkWasCalled += 1
        didResolveAttributedLinkReceivedURL = link
    }
}
