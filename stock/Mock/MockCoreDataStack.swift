//
//  Untitled.swift
//  stock
//
//  Created by Tejas Pradipkumar Nanavati on 15/07/25.
//

// MARK: - MockCoreDataStack.swift

import Foundation
import CoreData

class MockCoreDataStack: CoreDataStack {

    override init() {
        super.init()
        persistentContainer = NSPersistentContainer(name: "HoldingsDataModel", managedObjectModel: self.managedObjectModel)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType // Use in-memory store
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    // This is needed for the in-memory store setup
    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle(for: type(of: self)).url(forResource: "HoldingsDataModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    // MARK: - Mocking specific Core Data operations

    var deleteAllHoldingsCalled = false
    var deleteAllHoldingsShouldFail = false
    var savedHoldings: [UserHoldingEntity] = [] // To track what was "saved"

    override func deleteAllHoldings(completion: @escaping (Result<Void, Error>) -> Void) {
        deleteAllHoldingsCalled = true
        if deleteAllHoldingsShouldFail {
            completion(.failure(NSError(domain: "MockCoreDataError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Mock delete failed"])))
        } else {
            // Clear the in-memory store
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserHoldingEntity.fetchRequest()
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try mainContext.execute(batchDeleteRequest)
                // Clear the mock's internal savedHoldings array as well
                savedHoldings.removeAll()
                saveContext() // Save the deletion
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

    override func saveContext() {
        // In a real mock, you might just track if save was called.
        // Here, we'll actually commit to the in-memory store and update our tracking array.
        let context = mainContext
        if context.hasChanges {
            do {
                try context.save()
                // After saving, fetch all entities to update our 'savedHoldings' array
                let fetchRequest: NSFetchRequest<UserHoldingEntity> = UserHoldingEntity.fetchRequest()
                savedHoldings = try context.fetch(fetchRequest)
            } catch {
                fatalError("Mock save failed: \(error)")
            }
        }
    }

    // Helper to add entities directly to the mock for testing loading
    func addMockHoldingEntities(_ holdings: [UserHolding]) {
        for holding in holdings {
            _ = UserHoldingEntity(from: holding, in: mainContext)
        }
        saveContext()
    }
}
