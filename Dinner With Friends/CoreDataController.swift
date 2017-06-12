//
//  CoreDataController.swift
//  Dinner With Friends
//
//  Created by Jason Hughes on 5/10/17.
//  Copyright © 2017 1976. All rights reserved.
//

import Foundation
import CoreData
import Firebase

class CoreDataController {
    static let sharedInstance = CoreDataController();
    
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Dinner_With_Friends")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func updateManagedObject(managedObject:NSManagedObject, record:NSDictionary){
        record.enumerateKeysAndObjects({(key, obj, stop) in
            self.setManagedObjectValue(value: obj as AnyObject, key: key as! String, managedObject: managedObject);
        });
        
        self.saveContext();
    }
    
    func setManagedObjectValue(value:AnyObject, key:String, managedObject:NSManagedObject){
        let entity = managedObject.entity;
        let attributes = entity.attributesByName as [NSString: NSAttributeDescription];
        
        for attributeName in attributes.keys {
            if attributeName as String == key {
                if let _ = value as? NSNull {
                    
                }else{
                    managedObject.setValue(value, forKey: key);
                }
            };
        }
        
        self.saveContext();
    }
    
    
    func newManagedObjectWith(className:String) ->NSManagedObject {
        let managedObject = NSEntityDescription.insertNewObject(forEntityName: className, into: self.persistentContainer.viewContext)
        
        return managedObject;
    }
    
    func newManagedObjectWith(className:String, record:NSDictionary) {
        let managedObject = self.newManagedObjectWith(className: className)
        
        record.enumerateKeysAndObjects({(key, obj, stop) in
            self.setManagedObjectValue(value: obj as AnyObject, key: key as! String, managedObject: managedObject)
        });
        
        self.saveContext();
    }
    
    /*func newManagedObjectWith(className:String, record:FAuthData) {
        let managedObject = self.newManagedObjectWith(className: className)
        
        self.setManagedObjectValue(value: record.uid as AnyObject, key: "uid", managedObject: managedObject)
        self.setManagedObjectValue(value: record.provider as AnyObject, key: "provider", managedObject: managedObject)
        
        if let providerData = record.providerData as NSDictionary? {
            providerData.enumerateKeysAndObjects({(key, obj, stop) in
                
                if let unwrappedObject = obj as? NSDictionary {
                    unwrappedObject.enumerateKeysAndObjects({(key, obj, stop) in
                        self.setManagedObjectValue(value: obj as AnyObject, key: key as! String, managedObject: managedObject)
                    })
                } else {
                    self.setManagedObjectValue(value: obj as AnyObject, key: key as! String, managedObject: managedObject)
                }
                
            })
        }
    
        self.saveContext();
    }*/
    
    func delete(managedObject:NSManagedObject){
        self.persistentContainer.viewContext.delete(managedObject);
        self.saveContext();
    }
    
    func managedObjectForClass(className:String) ->NSManagedObject? {
        
        var managedObject:NSManagedObject?;
        
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: className)
        
        do {
            let results = try self.persistentContainer.viewContext.fetch(request);
            
            if results.count > 0, let firstManagedObject = results[0] as? NSManagedObject {
                managedObject = firstManagedObject;
            }
        } catch {
            print("managedObjectForClass Fetch ERROR");
        }
        
        
        return managedObject;
    }
}
