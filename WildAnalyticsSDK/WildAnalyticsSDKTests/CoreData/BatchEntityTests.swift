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

    /// Несколько копий SDK (публичная и приватная) могут быть слинкованы в одно приложение.
    /// Objective-C runtime имеет одно плоское пространство имён на процесс, поэтому
    /// `@objc(BatchEntity)` привёл бы к тому, что обе копии зарегистрировали бы класс под
    /// именем `BatchEntity`, победитель выбирался бы недетерминированно, а проигравшая копия
    /// падала бы на приведении результата fetch к своему типу.
    func testClassDoesNotOccupyFlatObjCName() {
        XCTAssertNil(
            NSClassFromString("BatchEntity"),
            "BatchEntity не должен регистрироваться в Objective-C runtime без префикса модуля"
        )
    }

    /// Модель должна ссылаться на класс *своего* модуля, а не на строку `BatchEntity`,
    /// которая может разрешиться в класс другой копии SDK.
    func testSchemaClassNameIsModuleQualified() {
        // when
        let entity = BatchEntity.schema

        // then
        XCTAssertEqual(entity.managedObjectClassName, NSStringFromClass(BatchEntity.self))
        XCTAssertTrue(
            NSClassFromString(entity.managedObjectClassName) === BatchEntity.self,
            "managedObjectClassName должен разрешаться в BatchEntity этого модуля"
        )
    }

    /// Имя сущности участвует в метаданных хранилища и version hash. Его изменение сделает
    /// существующие хранилища нечитаемыми и потребует model migration.
    func testSchemaEntityNameIsStable() {
        XCTAssertEqual(BatchEntity.schema.name, "BatchEntity")
    }
}
