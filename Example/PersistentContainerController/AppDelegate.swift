//
//  AppDelegate.swift
//  PersistentContainerController
//
//  Created by Aleksey Shabrov on 07/12/2018.
//  Copyright (c) 2018 Aleksey Shabrov. All rights reserved.
//

import UIKit
import PersistentContainerController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    lazy var persitentContainerController = PersistentContainerController(name: "PersistentContainerControllerExample") { [weak self] (container, persistentStoreDescription, error) in
        guard let _ = error else { return print("Store added successfully") }
        
        do {
            try container.destroyPersistentStore(with: persistentStoreDescription)
            container.addPersistentStore(with: persistentStoreDescription, completionHandler: { _, error in
                guard let error = error else { return }
                
                fatalError((error as NSError).localizedDescription)
            })
        }
        catch {
            assertionFailure((error as NSError).localizedDescription)
        }
    }
}

