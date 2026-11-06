//
//  Copyright © 2026 WBA. All rights reserved.
//

import Foundation

@testable import WBASDK

final class IDFAProviderMock: IDFAProvider {

    var currentIDFAStub: String = ""
    private(set) var currentIDFAWasCalled: Int = 0

    func currentIDFA() -> String {
        currentIDFAWasCalled += 1
        return currentIDFAStub
    }
}
