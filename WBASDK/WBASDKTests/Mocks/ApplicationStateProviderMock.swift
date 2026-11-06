//
//  Copyright © 2026 WBA. All rights reserved.
//

import UIKit

@testable import WBASDK

final class ApplicationStateProviderMock: ApplicationStateProviding {

    var applicationStateStub: UIApplication.State = .background
    private(set) var applicationStateWasCalled: Int = 0

    var applicationState: UIApplication.State {
        applicationStateWasCalled += 1
        return applicationStateStub
    }
}
