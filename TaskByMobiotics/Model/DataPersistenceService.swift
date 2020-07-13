//
//  DataPersistenceService.swift
//  TaskByMobiotics
//
//  Created by Kap's on 11/07/20.
//

import Foundation
import CoreData

// MARK: - Core Data stack

class DataPersistenceService {

private init() {}

static var context : NSManagedObjectContext {
    return persistentContainer.viewContext
}

static var persistentContainer: NSPersistentContainer = {
    
    let container = NSPersistentContainer(name: "TaskByMobiotics")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    })
    return container
}()

// MARK: - Core Data Saving support

static func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
  }
}
