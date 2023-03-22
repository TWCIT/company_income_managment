//
//  BuildCD+CoreDataProperties.swift
//  Expenso
//
//  Created by Marek Wala on 25/04/2021.
//
//

import Foundation
import CoreData


extension BuildCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BuildCD> {
        return NSFetchRequest<BuildCD>(entityName: "BuildCD")
    }

    @NSManaged public var title: String?
    @NSManaged public var amount: Double
    @NSManaged public var createdAt: Date?
    @NSManaged public var imageAttached: Data?
    @NSManaged public var note: String?
    @NSManaged public var occuredOn: Date?
    @NSManaged public var tag: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var relationship: NSSet?

}

// MARK: Generated accessors for relationship
extension BuildCD {

    @objc(addRelationshipObject:)
    @NSManaged public func addToRelationship(_ value: ExpenseCD)

    @objc(removeRelationshipObject:)
    @NSManaged public func removeFromRelationship(_ value: ExpenseCD)

    @objc(addRelationship:)
    @NSManaged public func addToRelationship(_ values: NSSet)

    @objc(removeRelationship:)
    @NSManaged public func removeFromRelationship(_ values: NSSet)

}

extension BuildCD : Identifiable {
    
}
