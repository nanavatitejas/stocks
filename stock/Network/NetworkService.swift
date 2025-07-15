//
//  NetworkService.swift
//  stock
//
//  Created by Tejas Pradipkumar Nanavati on 15/07/25.
//

import Foundation

class API {
    enum Endpoint {
        static let holdings = "https://35dee773a9ec441e9f38d5fc249406ce.api.mockbin.io/"
    }
}

class NetworkService {
    static let shared = NetworkService()
    private let coreDataStack: CoreDataStack 

    
    var session: URLSession

    init(session: URLSession = .shared, coreDataStack: CoreDataStack = .shared) {
        self.session = session
        self.coreDataStack = coreDataStack // Initialize it
    }

    func fetchHoldings(completion: @escaping (Result<Stocks, NetworkError>) -> Void) {
        guard let url = URL(string: API.Endpoint.holdings) else {
            completion(.failure(.invalidURL))
            return
        }

        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.networkFailed(error.localizedDescription)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            do {
                let holdingsResponse = try JSONDecoder().decode(Stocks.self, from: data)
                completion(.success(holdingsResponse))
                self.coreDataStack.deleteAllHoldings { deleteResult in
                                    switch deleteResult {
                                    case .success:
                                        // Proceed to save new holdings
                                        let context = self.coreDataStack.mainContext
                                        for holding in holdingsResponse.data.userHolding {
                                            _ = UserHoldingEntity(from: holding, in: context)
                                        }
                                        self.coreDataStack.saveContext()

                                        completion(.success(holdingsResponse)) 
                                    case .failure(let deleteError):
                                        completion(.failure(.coreDataError("Failed to delete old holdings: \(deleteError.localizedDescription)")))
                                    }
                                }
                
                
            } catch {
                completion(.failure(.decodingError(error.localizedDescription)))
            }
        }.resume()
    }
    
}
