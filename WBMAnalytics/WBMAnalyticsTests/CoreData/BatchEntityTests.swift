//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import XCTest
import CoreData

@testable import WBMAnalytics

final class BatchEntityTests: XCTestCase {

    func testSchema () {
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
}
