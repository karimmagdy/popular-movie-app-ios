//
//  DataController.swift
//  Project7
//
//  Created by MacPro on 1/2/17.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import UIKit
import CoreData
class DataController: NSObject {
    
    var managedObjectContext: NSManagedObjectContext
    
    static let instance = DataController()
    
    override private init() {
        // This resource is the same name as your xcdatamodeld contained in your project.
        guard let modelURL = Bundle.main.url(forResource: "Model", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.managedObjectContext.persistentStoreCoordinator = psc
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = urls[urls.endIndex-1]
        /* The directory the application uses to store the Core Data store file.
         This code uses a file named "DataModel.sqlite" in the application's documents directory.
         */
        let storeURL = docURL.appendingPathComponent("Model.sqlite")
        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        } catch {
            fatalError("Error migrating store: \(error)")
        }
    }
    
    func CDConnection(model: String) -> NSManagedObjectContext{
        
        guard let modelURL = Bundle.main.url(forResource: model, withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.managedObjectContext.persistentStoreCoordinator = psc
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = urls[urls.endIndex-1]
        /* The directory the application uses to store the Core Data store file.
         This code uses a file named "DataModel.sqlite" in the application's documents directory.
         */
        let storeURL = docURL.appendingPathComponent("\(model).sqlite")
        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        } catch {
            fatalError("Error migrating store: \(error)")
        }
        
        let context: NSManagedObjectContext = DataController.instance.managedObjectContext
        
        return context
    }
    
    
    
    func checkIfExest(model:String, isExest:inout Bool , predicate:NSPredicate , entity : String) ->Bool{
        
        let context = CDConnection(model: model)
        
        let requset = NSFetchRequest<NSManagedObject>(entityName: entity)
            requset.predicate = predicate  //NSPredicate(format: "predicate == %@", predicate)
        
        requset.returnsObjectsAsFaults = false
        do{
            let movies  = try context.fetch(requset) as [NSManagedObject]
            
            if movies.count > 0 {
                isExest = true
            }else{
                isExest = false
            }
            
        }catch{}
        return isExest
    }
    /*
    func CDAdd(model:String){
        //let context = CDConnection(model: model , entity : String)
        //let newEntity = NSEntityDescription.insertNewObject(forEntityName: entity, into: context)
        //newMovie.setValue(NumberFormatter().number(from: id), forKey: "id")
       // newMovie.setValue(NSDecimalNumber(string: va), forKey: "voteAverage")
       // newMovie.setValue(o, forKey: "overview")
       // newMovie.setValue(t, forKey: "title")
       // newMovie.setValue(rd, forKey: "releaseDate")
       // newMovie.setValue(pp, forKey: "posterPath")
//newMovie.setValue(bp, forKey: "backdropPath")
        
        do{
     //       try context.save()
        }catch{
            print("There was a problem")
        }
       // if isFavorite == false{
         //   isFavorite = true
        }
    }
    */
    
}
