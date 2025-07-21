//
//  CoreDataStackMock.swift
//  WBMAnalyticsTests
//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation
import CoreData

@testable import WBMAnalytics

final class CoreDataStackMock: CoreDataStackProtocol {

    private(set) var contextGetWasCalled: Int = 0

    var context: NSManagedObjectContext {
        get {
            contextGetWasCalled += 1
            return containerGetStub.viewContext
        }
    }

    private(set) var containerGetWasCalled: Int = 0
    var containerGetStub: NSPersistentContainer!

    private(set) var containerSetWasCalled: Int = 0
    private(set) var containerSetReceivedArgument: NSPersistentContainer?

    var container: NSPersistentContainer {
        get {
            containerGetWasCalled += 1
            return containerGetStub
        }
        set {
            containerSetWasCalled += 1
            containerSetReceivedArgument = newValue
        }
    }
}
