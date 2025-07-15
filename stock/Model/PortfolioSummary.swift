//
//  PortfolioSummary.swift
//  stock
//
//  Created by Tejas Pradipkumar Nanavati on 15/07/25.
//


struct PortfolioSummary {
    let currentValue: Double
    let totalInvestment: Double
    let totalPNL: Double
    let todayPNL: Double

    var totalPNLPercentage: Double {
        guard totalInvestment != 0 else { return 0 }
        return (totalPNL / totalInvestment) * 100
    }
}