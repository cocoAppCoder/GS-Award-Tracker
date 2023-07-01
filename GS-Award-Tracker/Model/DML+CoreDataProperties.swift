//
//  DML+CoreDataProperties.swift
//  GS-Award-Tracker
//
//  Created by Diya V Gounder on 8/21/22.
//
//

import Foundation
import CoreData


extension DML {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DML> {
        return NSFetchRequest<DML>(entityName: "DML")
    }

    @NSManaged public var date: Date?
    @NSManaged public var log: String?
    @NSManaged public var minutes: Int64
    @NSManaged public var totalMinutes: Int64

}

extension DML : Identifiable {

}
