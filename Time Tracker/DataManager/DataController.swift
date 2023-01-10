//
//  DataController.swift
//  Time Tracker
//
//  Created by Mark McKeon on 7/12/2022.
//

import Foundation
import CoreData
import SwiftUI

class DataController: ObservableObject {
    let container = NSPersistentCloudKitContainer(name: "Time Tracker")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Fatal error loading Core Data stores \(error.localizedDescription)")
            }
        }
    }
    func save() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            }
            catch {
                fatalError("Unable to save data: \(error.localizedDescription)")
            }
        }
    }
    
    func delete(_ object: NSManagedObject) {
        container.viewContext.delete(object)
    }
    
    func deleteAll() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
        = Employee.fetchRequest()
        let batchDeleteRequest =
        NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try?
        container.viewContext.execute(batchDeleteRequest)
    }
}

