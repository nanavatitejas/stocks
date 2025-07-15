//
//  UserHolding.swift
//  stock
//
//  Created by Tejas Pradipkumar Nanavati on 15/07/25.
//
import Foundation

struct UserHolding: Decodable, Identifiable {
    let id = UUID()
    let symbol: String
    let quantity: Int
    let ltp: Double
    let avgPrice: Double
    let close: Double 

    init(symbol: String, quantity: Int, ltp: Double, avgPrice: Double, close: Double) {
            self.symbol = symbol
            self.quantity = quantity
            self.ltp = ltp
            self.avgPrice = avgPrice
            self.close = close
    }
   
    init(from entity: UserHoldingEntity) {
        self.symbol = entity.symbol ?? "N/A"
        self.quantity = Int(entity.quantity)
        self.ltp = entity.ltp
        self.avgPrice = entity.avgPrice
        self.close = entity.close
    }
}
