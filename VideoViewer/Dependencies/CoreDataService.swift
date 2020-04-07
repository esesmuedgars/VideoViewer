//
// Copyright © 2020 @esesmuedgars.
//

import Foundation
import CoreData

protocol CoreDataManagedObjectContextOwner: class {
    var managedObjectContext: NSManagedObjectContext { get }
}

protocol CoreDataServiceProtocol: class {
    func fetchVideoItems() throws -> [VideoItem]
    func setItem(_ video: Response.Video)
    func saveContext() throws
}

final class CoreDataService: CoreDataManagedObjectContextOwner, CoreDataServiceProtocol {
    
    var managedObjectContext: NSManagedObjectContext = {
        let persistentContainer = NSPersistentContainer(name: "VideoViewer")
        persistentContainer.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                print("Error loading persistent stores: \(error), \(error.userInfo)")
            }
        }
        
        return persistentContainer.viewContext
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
