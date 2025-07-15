//
//  Untitled.swift
//  stock
//
//  Created by Tejas Pradipkumar Nanavati on 15/07/25.
//

// MARK: - CoreDataStack.swift

import CoreData

class CoreDataStack {
    static let shared = CoreDataStack() // Singleton instance

    internal init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "HoldingsDataModel") 
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: saveContext

    func saveContext () {
        let context = mainContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
              
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - Batch Deletion Helper (Optional but useful)
    func deleteAllHoldings(completion: @escaping (Result<Void, Error>) -> Void) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserHoldingEntity.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
//           try mainContext.execute(batchDeleteRequest)
//            saveContext()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}
