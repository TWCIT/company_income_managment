//
//  WorkerCD+CoreDataProperties.swift
//  Expenso
//
//  Created by Marek Wala on 25/04/2021.
//
//

import Foundation
import CoreData


extension WorkerCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkerCD> {
        return NSFetchRequest<WorkerCD>(entityName: "WorkerCD")
    }

    @NSManaged public var updatedAt: Date?
    @NSManaged public var tag: String?
    @NSManaged public var name: String?
    @NSManaged public var surname: String?
    @NSManaged public var occuredOn: Date?
    @NSManaged public var note: String?
    @NSManaged public var imageAttached: Data?
    @NSManaged public var createdAt: Date?
    @NSManaged public var amount: Double
    @NSManaged public var monthly: Double
    @NSManaged public var workAgreement: Bool
    @NSManaged public var relationship: NSSet?

}

// MARK: Generated accessors for relationship
extension WorkerCD {

    @objc(addRelationshipObject:)
    @NSManaged public func addToRelationship(_ value: ExpenseCD)

    @objc(removeRelationshipObject:)
    @NSManaged public func removeFromRelationship(_ value: ExpenseCD)

    @objc(addRelationship:)
    @NSManaged public func addToRelationship(_ values: NSSet)

    @objc(removeRelationship:)
    @NSManaged public func removeFromRelationship(_ values: NSSet)

}

extension WorkerCD : Identifiable {

}
