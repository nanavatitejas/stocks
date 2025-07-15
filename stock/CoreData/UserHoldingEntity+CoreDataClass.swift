//
//  UserHoldingEntity+CoreDataClass.swift
//  stock
//
//  Created by Tejas Pradipkumar Nanavati on 15/07/25.
//
//
// MARK: - UserHoldingEntity+CoreDataClass.swift

import Foundation
import CoreData

@objc(UserHoldingEntity)
public class UserHoldingEntity: NSManagedObject {
    convenience init(from userHolding: UserHolding, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.symbol = userHolding.symbol
        self.quantity = Int16(userHolding.quantity) // Cast to Int16
        self.ltp = userHolding.ltp
        self.avgPrice = userHolding.avgPrice
        self.close = userHolding.close
    }
}
