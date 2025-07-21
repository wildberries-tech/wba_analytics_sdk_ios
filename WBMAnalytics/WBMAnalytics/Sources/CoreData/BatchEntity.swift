//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation
import CoreData

@objc(BatchEntity)
class BatchEntity: NSManagedObject {
    @NSManaged var createdAt: Date?
    @NSManaged var data: String?
    @NSManaged var id: String?

    @nonobjc class func fetchRequest() -> NSFetchRequest<BatchEntity> {
        return NSFetchRequest<BatchEntity>(entityName: "BatchEntity")
    }

    static let schema: NSEntityDescription = {
        let entityName = NSStringFromClass(BatchEntity.self)
        let entity = NSEntityDescription()
        entity.managedObjectClassName = entityName
        entity.name = entityName

        // Создаём сущность BatchEntity
        let batchEntity = NSEntityDescription()
        batchEntity.name = "BatchEntity"
        batchEntity.managedObjectClassName = "BatchEntity"

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
