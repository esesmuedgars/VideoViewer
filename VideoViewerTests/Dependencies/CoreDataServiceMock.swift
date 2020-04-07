//
// Copyright © 2020 @esesmuedgars.
//

import Foundation
import CoreData
@testable import VideoViewer

protocol CoreDataServiceMockProtocol: class {}

final class CoreDataServiceMock: CoreDataManagedObjectContextOwner, CoreDataServiceProtocol, CoreDataServiceMockProtocol {
    
    var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContextOwner = Dependencies.shared.coreDataService as! CoreDataManagedObjectContextOwner
        let managedObjectModel = managedObjectContextOwner.managedObjectContext.persistentStoreCoordinator!.managedObjectModel
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType,
                                                              configurationName: nil,
                                                              at: nil)
        } catch {
            fatalError("Adding in-memory persistent store failed")
        }
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        let testObject = VideoItem(context: managedObjectContext)
        managedObjectContext.delete(testObject)
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Unable to save context")
        }
        
        return managedObjectContext
    }()
    
    func fetchVideoItems() throws -> [VideoItem] {
        let fetchRequest = VideoItem.fetchRequest() as! NSFetchRequest<VideoItem>
        
        return try managedObjectContext.fetch(fetchRequest)
    }
    
    func setItem(_ video: Response.Video) {
        VideoItem(context: managedObjectContext)
            .set(video)
    }
    
    func saveContext() throws {
        if managedObjectContext.hasChanges {
            try managedObjectContext.save()
        }
    }
}
