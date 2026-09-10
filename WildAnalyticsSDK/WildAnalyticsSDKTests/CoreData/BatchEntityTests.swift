//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest
import CoreData

@testable import WildAnalyticsSDK

final class BatchEntityTests: XCTestCase {

    func testSchema() {
        // when
        let entity = BatchEntity.schema

        // then
        XCTAssertEqual(entity.name, "BatchEntity")
        let properties = entity.propertiesByName
        guard let idAttribute = properties["id"] as? NSAttributeDescription,
              let dataAttribute = properties["data"] as? NSAttributeDescription,
              let createdAtAttribute = properties["createdAt"] as? NSAttributeDescription else {
            XCTFail("One or more attributes are missing.")
            return
        }

        XCTAssertEqual(idAttribute.attributeType, .stringAttributeType)
        XCTAssertEqual(dataAttribute.attributeType, .stringAttributeType)
        XCTAssertEqual(createdAtAttribute.attributeType, .dateAttributeType)

        XCTAssertTrue(idAttribute.isOptional)
        XCTAssertTrue(dataAttribute.isOptional)
        XCTAssertTrue(createdAtAttribute.isOptional)
    }

    /// Several copies of the SDK (public and private) can be linked into a single app.
    /// The Objective-C runtime has one flat namespace per process, so `@objc(BatchEntity)`
    /// would make both copies register a class under the name `BatchEntity`; the winner
    /// would be picked nondeterministically, and the losing copy would crash when casting
    /// the fetch result to its own type.
    func testClassDoesNotOccupyFlatObjCName() {
        XCTAssertNil(
            NSClassFromString("BatchEntity"),
            "BatchEntity must not be registered in the Objective-C runtime without a module prefix"
        )
    }

    /// The model must reference the class of *its own* module rather than the string
    /// `BatchEntity`, which could resolve to another copy of the SDK's class.
    func testSchemaClassNameIsModuleQualified() {
        // when
        let entity = BatchEntity.schema

        // then
        XCTAssertEqual(entity.managedObjectClassName, NSStringFromClass(BatchEntity.self))
        XCTAssertTrue(
            NSClassFromString(entity.managedObjectClassName) === BatchEntity.self,
            "managedObjectClassName must resolve to this module's BatchEntity"
        )
    }

    /// The entity name is part of the store metadata and the version hash. Changing it
    /// would make existing stores unreadable and require a model migration.
    func testSchemaEntityNameIsStable() {
        XCTAssertEqual(BatchEntity.schema.name, "BatchEntity")
    }
}
