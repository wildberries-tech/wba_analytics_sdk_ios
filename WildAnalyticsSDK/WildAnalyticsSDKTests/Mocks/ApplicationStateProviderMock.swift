//
//  Copyright © 2026 Wildberries LLC. All rights reserved.
//

import UIKit

@testable import WildAnalyticsSDK

final class ApplicationStateProviderMock: ApplicationStateProviding {

    var applicationStateStub: UIApplication.State = .background
    private(set) var applicationStateWasCalled: Int = 0

    var applicationState: UIApplication.State {
        applicationStateWasCalled += 1
        return applicationStateStub
    }
}
