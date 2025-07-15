//
//  HoldingsResponse.swift
//  stock
//
//  Created by Tejas Pradipkumar Nanavati on 15/07/25.
//
import Foundation

struct HoldingsResponse: Decodable {
    let userHolding: [UserHolding]
}
