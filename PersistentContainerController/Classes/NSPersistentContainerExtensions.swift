//
//  NSPersistentContainerExtensions.swift
//  PersistentContainerController
//
//  Created by Aleksey Shabrov on 12.07.2018.
//

import CoreData

public extension NSPersistentContainer {
    /// Deletes (or truncates) the target persistent store in accordance with the store class' requirements.
    ///
    /// - parameter persistentStoreDescription: description of persistent store to be destroyed.
    
    public func destroyPersistentStore(with persistentStoreDescription: NSPersistentStoreDescription) throws {
        guard let url = persistentStoreDescription.url else { return }
        let coordinator = self.persistentStoreCoordinator
        try coordinator.destroyPersistentStore(at: url, ofType: persistentStoreDescription.type, options: persistentStoreDescription.options)
    }
    
    /// Adds a new persistent store of a specified description, and returns the new store.
    ///
    /// - parameter persistentStoreDescription: description of persistent store to be added.
    /// - parameter completionHandler: block to be performed on add operaiton completed with 2 parameters:
    /// - parameter persistentStoreDescription: description of persistent store.
    /// - parameter error: nil if persistent store was added successfull, otherwise object with error description
    
    public func addPersistentStore(with persistentStoreDescription: NSPersistentStoreDescription, completionHandler: @escaping (_ persistentStoreDescription: NSPersistentStoreDescription, _ error: Error?) -> Void) {
        let coordinator = self.persistentStoreCoordinator
        coordinator.addPersistentStore(with: persistentStoreDescription, completionHandler: completionHandler)
    }
}
