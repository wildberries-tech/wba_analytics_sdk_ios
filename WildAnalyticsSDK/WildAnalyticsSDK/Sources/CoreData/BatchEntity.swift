//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation
import CoreData

class BatchEntity: NSManagedObject {
    @NSManaged var createdAt: Date?
    @NSManaged var data: String?
    @NSManaged var id: String?

    @nonobjc class func fetchRequest() -> NSFetchRequest<BatchEntity> {
        return NSFetchRequest<BatchEntity>(entityName: "BatchEntity")
    }

    static let schema: NSEntityDescription = {
        // Создаём сущность BatchEntity
        let batchEntity = NSEntityDescription()
        // Имя сущности участвует в метаданных хранилища: менять его нельзя, иначе
        // существующие хранилища станут нечитаемыми.
        batchEntity.name = "BatchEntity"
        // Имя класса разрешается через NSClassFromString, поэтому оно должно быть
        // квалифицировано модулем — иначе Core Data может подставить BatchEntity
        // из другой копии SDK.
        batchEntity.managedObjectClassName = NSStringFromClass(BatchEntity.self)

        // Добавляем атрибуты к сущности
        let idAttribute = NSAttributeDescription()
        idAttribute.name = #keyPath(BatchEntity.id)
        idAttribute.attributeType = .stringAttributeType
        idAttribute.isOptional = true

        let dataAttribute = NSAttributeDescription()
        dataAttribute.name = #keyPath(BatchEntity.data)
        dataAttribute.attributeType = .stringAttributeType
        dataAttribute.isOptional = true

        let createdAtAttribute = NSAttributeDescription()
        createdAtAttribute.name = #keyPath(BatchEntity.createdAt)
        createdAtAttribute.attributeType = .dateAttributeType
        createdAtAttribute.isOptional = true

        batchEntity.properties = [idAttribute, dataAttribute, createdAtAttribute]

        return batchEntity
    }()
}
