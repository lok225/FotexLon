//
//  DataController.swift
//  Føtex Løn
//
//  Created by Martin Lok on 28/07/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import UIKit
import CoreData

class DataController: NSObject {

    var managedObjectContext: NSManagedObjectContext
    
    override init() {
        
        guard let modelURL = Bundle.main.url(forResource: "CoreDataModel", withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }
        
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = urls[urls.endIndex - 1]
        
        let storeURL = docURL.appendingPathComponent("DataStore.sqlite")
        
        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        } catch {
            fatalError("Error migrating store: \(error)")
        }
    }
    
    func save() {
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Error: \(error)")
        }
    }
    
    func delete(vagt: Vagt) {
        managedObjectContext.delete(vagt)
        
        save()
    }
    
}

