//
//  PersistentContainerController.swift
//  PersistentContainerController
//
//  Created by Aleksey Shabrov on 10.07.2018.
//  Copyright © 2018 Hight Technologies Center. All rights reserved.
//

import CoreData

public class PersistentContainerController {
    
    private class WeakObject {
        weak var object: AnyObject?
        
        init(object: AnyObject) {
            self.object = object
        }
    }
    
    private var contextsContainer: [String: WeakObject] = [:]
    
    private var appWillTerminateNotificationObeserver: NSObjectProtocol?
    private var appDidEnterBackgroundNotificationObeserver: NSObjectProtocol?
    
    /// Created persisten container (read-only)
    private(set) public var persistentContainer: NSPersistentContainer
    
    /// The managed object context associated with the main queue. (read-only)
    public var viewContext: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    /// Create new persisten container controller with given parameters and call `loadPersistentStores(completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Swift.Void)` method on created container.
    ///
    /// - parameter name: Name of container
    /// - parameter persistentStoreDescriptions: Allows to set multiple stores before load. Pass empty array if you want to use default stores.
    /// - parameter persistentStoresLoadingCompletionHandler: Once the loading of the persistent stores has completed, this block will be executed on the calling thread.
    public init(name: String, persistentStoreDescriptions: [NSPersistentStoreDescription] = [], persistentStoresLoadCompletionHandler: ((NSPersistentContainer, NSPersistentStoreDescription, Error?) -> Void)? = nil) {
        self.persistentContainer = NSPersistentContainer(name: name)
        
        if !persistentStoreDescriptions.isEmpty {
            self.persistentContainer.persistentStoreDescriptions = persistentStoreDescriptions
        }
        
        self.persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let handler = persistentStoresLoadCompletionHandler {
                handler(self.persistentContainer, storeDescription, error)
            } else if let error = error as NSError? {
                assertionFailure(error.localizedDescription)
            }
        }
        
        self.appWillTerminateNotificationObeserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillTerminate, object: nil, queue: nil) { [weak self] _ in
            guard let strongSelf = self else { return }
            PersistentContainerController.save(context: strongSelf.persistentContainer.viewContext)
        }
        
        self.appDidEnterBackgroundNotificationObeserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground, object: nil, queue: nil, using: { [weak self] _ in
            guard let strongSelf = self else { return }
            PersistentContainerController.save(context: strongSelf.persistentContainer.viewContext)
        })
    }
    
    deinit {
        if let observer = self.appWillTerminateNotificationObeserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = self.appDidEnterBackgroundNotificationObeserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    /// Create new context (or exiting if context for given `key` still alive) for group of operations for given `key`
    ///
    /// - parameter key: key for group of operations
    /// - returns: Exiting or new context for given `key`
    
    public func backgroundContext(for key: String) -> NSManagedObjectContext {
        let context: NSManagedObjectContext
        if let weakContainer = self.contextsContainer[key], let savedContext = weakContainer.object as? NSManagedObjectContext {
            context = savedContext
        } else {
            context = self.persistentContainer.newBackgroundContext()
            self.contextsContainer[key] = WeakObject(object: context)
        }
        return context
    }
    
    /// Perform given `blockToPerform` in background context associated with `contextGroupKey`
    ///
    /// - parameter contextGroupKey: key for group of operations
    /// - parameter blockToPerform: block to perform in background context
    /// - parameter saveErrorAction: action to perform with given context if error occured shile saving. Default is `.rollback`
    /// - parameter completion: block to perfor after saving finished
    
    public func performBackgroundTaskAndSave(for contextGroupKey: String,
                                             blockToPerform: @escaping ((_ context: NSManagedObjectContext) -> Void),
                                             saveErrorAction: SaveErrorAction = .rollback,
                                             completion: ((_ saveResult: SaveResult) -> Void)? = nil) {
        let context = self.backgroundContext(for: contextGroupKey)
        context.perform {
            blockToPerform(context)
            
            let saveResult = PersistentContainerController.save(context: context)
            
            if case .error = saveResult, case .rollback = saveErrorAction {
                context.rollback()
            }
            
            completion?(saveResult)
        }
    }
    
    /// Save context
    ///
    /// - parameter context: context to save
    /// - returns: result of saving operation
    
    @discardableResult
    public class func save(context: NSManagedObjectContext) -> SaveResult {
        guard context.hasChanges else { return .success }
        
        do {
            try context.save()
        } catch {
            return .error(error)
        }
        
        return .success
    }
    
}
