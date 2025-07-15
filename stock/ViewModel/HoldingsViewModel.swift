//
//  HoldingsViewModel.swift
//  stock
//
//  Created by Tejas Pradipkumar Nanavati on 15/07/25.
//


import Foundation
import CoreData

class HoldingsViewModel {
    var holdings: [UserHolding] = [] {
        didSet {
            self.onHoldingsUpdated?()
            self.calculatePortfolioSummary()
        }
    }

    var portfolioSummary: PortfolioSummary? {
        didSet {
            self.onPortfolioSummaryUpdated?()
        }
    }
    var isLoading: Bool = false {
        didSet {
            self.onLoadingStateChanged?(isLoading)
        }
    }

    var onHoldingsUpdated: (() -> Void)?
    var onPortfolioSummaryUpdated: (() -> Void)?
    var onError: ((NetworkError) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?

    
    private let networkService: NetworkService
    private let coreDataStack: CoreDataStack


    init(networkService: NetworkService = .shared, coreDataStack: CoreDataStack = .shared) {
            self.networkService = networkService
            self.coreDataStack = coreDataStack
    }

    func fetchHoldings() {
            self.isLoading = true

            networkService.fetchHoldings { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.isLoading = false // Set loading to false when fetch completes

                    switch result {
                    case .success(let response):
                        self.holdings = response.data.userHolding
                        print("Fetched from network and reloaded from Core Data.")
                    case .failure(let error):
                        let localHoldings = self.loadHoldingsFromCoreData()

                        if localHoldings.isEmpty {
                            self.onError?(error)
                            print("Network fetch failed with no local data: \(error.localizedDescription)")
                        } else {
                            self.holdings = localHoldings
                            print("Network fetch failed, but local data available. Displaying local data. Error: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    
    private func loadHoldingsFromCoreData() -> [UserHolding] {
            let context = coreDataStack.mainContext
            let fetchRequest: NSFetchRequest<UserHoldingEntity> = UserHoldingEntity.fetchRequest()

            do {
                let entities = try context.fetch(fetchRequest)
                return entities.map { UserHolding(from: $0) }
            } catch {
                print("Failed to fetch holdings from Core Data: \(error)")
                return []
            }
        }

    // Make calculatePortfolioSummary internal for testing
    internal func calculatePortfolioSummary() {
        var totalCurrentValue: Double = 0
        var totalInvestment: Double = 0
        var totalPNL: Double = 0
        var todayPNL: Double = 0

        for holding in holdings {
            totalCurrentValue += holding.ltp * Double(holding.quantity)
            totalInvestment += holding.avgPrice * Double(holding.quantity)
            todayPNL += (holding.close - holding.ltp) * Double(holding.quantity)
        }

        totalPNL = totalCurrentValue - totalInvestment

        self.portfolioSummary = PortfolioSummary(
            currentValue: totalCurrentValue,
            totalInvestment: totalInvestment,
            totalPNL: totalPNL,
            todayPNL: todayPNL
        )
    }
}
