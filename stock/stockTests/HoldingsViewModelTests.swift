//
//  Untitled.swift
//  stock
//
//  Created by Tejas Pradipkumar Nanavati on 15/07/25.
//



import XCTest
@testable import stock

class MockNetworkService: NetworkService {
    var shouldSucceed: Bool = true
    var mockHoldingsResponse: Stocks?
    var mockError: NetworkError?
    var fetchHoldingsCalled = false // Track if method was called

    override func fetchHoldings(completion: @escaping (Result<Stocks, NetworkError>) -> Void) {
        fetchHoldingsCalled = true
        if shouldSucceed {
            if let response = mockHoldingsResponse {
                completion(.success(response))
            } else {
                let defaultHoldings = [
                    UserHolding( symbol: "TEST1", quantity: 1, ltp: 100.0, avgPrice: 90.0, close: 105.0),
                    UserHolding( symbol: "TEST2", quantity: 2, ltp: 50.0, avgPrice: 45.0, close: 52.0)
                ]
                completion(.success(Stocks.init(data: HoldingsResponse(userHolding: defaultHoldings))))
            }
        } else {
            completion(.failure(mockError ?? .networkFailed("Mock network error")))
        }
    }
}


class HoldingsViewModelTests: XCTestCase {

    var sut: HoldingsViewModel!
    var mockNetworkService: MockNetworkService!
    var mockCoreDataStack: MockCoreDataStack! // New mock

    override func setUpWithError() throws {
        mockNetworkService = MockNetworkService()
        mockCoreDataStack = MockCoreDataStack()
        sut = HoldingsViewModel(networkService: mockNetworkService, coreDataStack: mockCoreDataStack)
    }

    override func tearDownWithError() throws {
        sut = nil
        mockNetworkService = nil
        mockCoreDataStack = nil
    }

    func testFetchHoldings_LoadsFromCoreDataFirst_ThenFetchesNetwork() {
        // Given
        let initialLocalHoldings = [
            UserHolding(symbol: "LOCAL1", quantity: 5, ltp: 10.0, avgPrice: 8.0, close: 11.0)
        ]
        mockCoreDataStack.addMockHoldingEntities(initialLocalHoldings)

        let networkHoldings = [
            UserHolding(symbol: "NETWORK1", quantity: 10, ltp: 100.0, avgPrice: 90.0, close: 105.0)
        ]
        mockNetworkService.mockHoldingsResponse = Stocks.init(data: HoldingsResponse(userHolding: networkHoldings))
        mockNetworkService.shouldSucceed = true

        let holdingsUpdatedExpectation = XCTestExpectation(description: "Holdings updated twice")
        holdingsUpdatedExpectation.expectedFulfillmentCount = 2

        sut.onHoldingsUpdated = {
            if self.sut.holdings.contains(where: { $0.symbol == "LOCAL1" }) {
                XCTAssertEqual(self.sut.holdings.count, 1, "Should initially load 1 local holding")
            } else if self.sut.holdings.contains(where: { $0.symbol == "NETWORK1" }) {
                XCTAssertEqual(self.sut.holdings.count, 1, "Should update to 1 network holding")
            } else {
                XCTFail("Unexpected holdings state")
            }
            holdingsUpdatedExpectation.fulfill()
        }

        // When
        sut.fetchHoldings()

        // Then
        // Immediately after fetchHoldings, holdings should be from local data
        XCTAssertEqual(sut.holdings.count, 0, "Should immediately load local holdings")

    }

    func testFetchHoldings_NetworkSuccessRefreshesCoreData() {
        // Given
        let initialLocalHoldings = [
            UserHolding(symbol: "OLD_LOCAL", quantity: 1, ltp: 1.0, avgPrice: 1.0, close: 1.0)
        ]
        mockCoreDataStack.addMockHoldingEntities(initialLocalHoldings)

        let networkHoldings = [
            UserHolding(symbol: "NEW_NETWORK", quantity: 10, ltp: 100.0, avgPrice: 90.0, close: 105.0)
        ]
        mockNetworkService.mockHoldingsResponse = Stocks.init(data: HoldingsResponse(userHolding: networkHoldings))
        mockNetworkService.shouldSucceed = true

        let holdingsUpdatedExpectation = XCTestExpectation(description: "Holdings updated after network success")
        holdingsUpdatedExpectation.expectedFulfillmentCount = 2 // Initial local + final network

        sut.onHoldingsUpdated = {
            holdingsUpdatedExpectation.fulfill()
        }

        // When
        sut.fetchHoldings()

        // Then
        XCTAssertEqual(sut.holdings.count, 0)
        
      
    }

    func testFetchHoldings_NetworkFailureWithLocalData() {
        // Given
        let initialLocalHoldings = [
            UserHolding(symbol: "LOCAL_FALLBACK", quantity: 2, ltp: 20.0, avgPrice: 18.0, close: 21.0)
        ]
        mockCoreDataStack.addMockHoldingEntities(initialLocalHoldings) // Pre-populate Core Data mock

        mockNetworkService.shouldSucceed = false
        mockNetworkService.mockError = .networkFailed("Simulated network down")

        let onErrorCalled = XCTestExpectation(description: "onError should NOT be called")
        onErrorCalled.isInverted = true // Expect this to NOT be fulfilled
        sut.onError = { _ in
            onErrorCalled.fulfill()
        }

        let holdingsUpdatedExpectation = XCTestExpectation(description: "Holdings updated initially from local data")
        sut.onHoldingsUpdated = {
            holdingsUpdatedExpectation.fulfill()
        }


        // When
        sut.fetchHoldings()

        // Then
        wait(for: [holdingsUpdatedExpectation, onErrorCalled], timeout: 2.0) // Wait for initial local load and ensure no error
        XCTAssertEqual(sut.holdings.count, 1, "Holdings should remain the local data")
        XCTAssertEqual(sut.holdings.first?.symbol, "LOCAL_FALLBACK")
        XCTAssertTrue(mockNetworkService.fetchHoldingsCalled, "Network service should still be called")
    }

    func testFetchHoldings_NetworkFailureNoLocalData() {
        // Given
        mockNetworkService.shouldSucceed = false
        mockNetworkService.mockError = .networkFailed("Simulated network down")

        let onErrorCalled = XCTestExpectation(description: "onError should be called")
        sut.onError = { error in
            XCTAssertEqual(error, .networkFailed("Simulated network down"))
            onErrorCalled.fulfill()
        }

        let holdingsUpdatedExpectation = XCTestExpectation(description: "Holdings updated should NOT be called if no local data and network fails")
        holdingsUpdatedExpectation.isInverted = true
        sut.onHoldingsUpdated = {
            holdingsUpdatedExpectation.fulfill()
        }

        // When
        sut.fetchHoldings()

        // Then
        wait(for: [onErrorCalled, holdingsUpdatedExpectation], timeout: 2.0)
        XCTAssertTrue(sut.holdings.isEmpty, "Holdings should be empty if no local data and network fails")
        XCTAssertTrue(mockNetworkService.fetchHoldingsCalled, "Network service should be called")
    }

    func testCalculatePortfolioSummary_CorrectCalculations() {
        // Given
        sut.holdings = [
            UserHolding(symbol: "A", quantity: 10, ltp: 100.0, avgPrice: 90.0, close: 105.0),
            UserHolding(symbol: "B", quantity: 5, ltp: 200.0, avgPrice: 210.0, close: 195.0)
        ]
        // When
        sut.calculatePortfolioSummary()

        // Then
        XCTAssertNotNil(sut.portfolioSummary)
        let summary = sut.portfolioSummary!
        XCTAssertEqual(summary.currentValue, 2000.0, accuracy: 0.001)
        XCTAssertEqual(summary.totalInvestment, 1950.0, accuracy: 0.001)
        XCTAssertEqual(summary.totalPNL, 50.0, accuracy: 0.001)
        XCTAssertEqual(summary.todayPNL, 25.0, accuracy: 0.001)
        let expectedPercentage = (50.0 / 1950.0) * 100
        XCTAssertEqual(summary.totalPNLPercentage, expectedPercentage, accuracy: 0.001)
    }

    func testCalculatePortfolioSummary_EmptyHoldings() {
        // Given
        sut.holdings = []

        // When
        sut.calculatePortfolioSummary()

        // Then
        XCTAssertNotNil(sut.portfolioSummary)
        let summary = sut.portfolioSummary!
        XCTAssertEqual(summary.currentValue, 0.0)
        XCTAssertEqual(summary.totalInvestment, 0.0)
        XCTAssertEqual(summary.totalPNL, 0.0)
        XCTAssertEqual(summary.todayPNL, 0.0)
        XCTAssertEqual(summary.totalPNLPercentage, 0.0)
    }
}
