//
//  AppDelegate.swift
//  RadiumBrowser
//
//  Created by bslayter on 1/31/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import Then
import SnapKit
import RealmSwift
import StoreKit
import SwiftyStoreKit
import SwiftKeychainWrapper

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
	
	@objc var mainController: MainViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
		#if arch(i386) || arch(x86_64)
			let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
			NSLog("Document Path: %@", documentsPath)
		#endif
        
        MigrationManager.shared.attemptMigration()
		
        WebServer.shared.startServer()
        
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: SettingsKeys.firstRun) {
            defaults.set(true, forKey: SettingsKeys.firstRun)
            performFirstRunTasks()
        }
        if defaults.string(forKey: SettingsKeys.searchEngineUrl) == nil {
            defaults.set("https://onbibi.com/search?q=", forKey: SettingsKeys.searchEngineUrl)
        }
        
        #if DEBUG
//            KeychainWrapper.standard.set(false, forKey: SettingsKeys.adBlockPurchased)
        #endif
        defaults.set(true, forKey: SettingsKeys.stringLiteralAdBlock)
        for hostFile in HostFileNames.allValues {
            defaults.set(false, forKey: hostFile.rawValue)
        }
        
        mainController = MainViewController()
        self.window?.rootViewController = mainController
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func performFirstRunTasks() {
        UserDefaults.standard.set(true, forKey: SettingsKeys.trackHistory)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions 
        // (such as an incoming phone call or SMS message) or when the user quits the application and it begins the 
        // transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks.
        // Games should use this method to pause the game.
        mainController?.tabContainer?.saveBrowsingSession()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to 
        // restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; 
        // here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive.
        // If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        mainController?.tabContainer?.saveBrowsingSession()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        do {
            let source = try String(contentsOf: url, encoding: .utf8)
            mainController?.openEditor(withSource: source, andName: url.deletingPathExtension().lastPathComponent)
        } catch {
            print("Could not open file")
        }
        
        return true
    }
}
