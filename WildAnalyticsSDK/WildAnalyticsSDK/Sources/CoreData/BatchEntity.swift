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
        // Create the BatchEntity entity
        let batchEntity = NSEntityDescription()
        // The entity name is part of the store metadata: it can't be changed, otherwise
        // existing stores would become unreadable.
        batchEntity.name = "BatchEntity"
        // The class name is resolved via NSClassFromString, so it must be qualified by
        // module — otherwise Core Data could substitute the BatchEntity from another
        // copy of the SDK.
        batchEntity.managedObjectClassName = NSStringFromClass(BatchEntity.self)

        // Add attributes to the entity
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
