//
//  UserHoldingEntity+CoreDataProperties.swift
//  stock
//
//  Created by Tejas Pradipkumar Nanavati on 15/07/25.
//
//

import Foundation
import CoreData


extension UserHoldingEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserHoldingEntity> {
        return NSFetchRequest<UserHoldingEntity>(entityName: "UserHoldingEntity")
    }
    @NSManaged public var symbol: String?
    @NSManaged public var quantity: Int16
    @NSManaged public var ltp: Double
    @NSManaged public var avgPrice: Double
    @NSManaged public var close: Double

}

extension UserHoldingEntity : Identifiable {

}
