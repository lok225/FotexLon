//
//  AppDelegate.swift
//  Føtex Løn
//
//  Created by Martin Lok on 22/07/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dataController = DataController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        setDataControllers()
        setManagedObjectContext()
        
        registerDefaults()
        
        setGlobalColors()
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        if shortcutItem.type == "com.martinlok.F-tex-L-n.nyVagt" {
            let tabBarController = window!.rootViewController as! UITabBarController
            let vagterNC = tabBarController.viewControllers![1] as! UINavigationController
            let vagterVC = vagterNC.topViewController as! VagterVC
            
            tabBarController.selectedIndex = 1
            vagterVC.performSegue(withIdentifier: kVagtDetailSegue, sender: nil)
        }
    }
    
    // MARK: Functions
    
    func setGlobalColors() {
        UINavigationBar.appearance().tintColor = UIColor.white
        UIApplication.shared.statusBarStyle = .lightContent
        
        let tabBarController = window!.rootViewController as! UITabBarController
        setColors(forTabBar: tabBarController.tabBar)
    }
    
    // MARK: CoreData
    
    private func setDataControllers() {
        let tabBarController = window?.rootViewController as! UITabBarController
        let mainNavigationController = tabBarController.viewControllers![0] as! UINavigationController
        let mainVC = mainNavigationController.viewControllers[0] as! MainVC
        mainVC.dataController = self.dataController
        
        let vagterNavigationController = tabBarController.viewControllers![1] as! UINavigationController
        let vagterVC = vagterNavigationController.viewControllers[0] as! VagterVC
        vagterVC.dataController = self.dataController
    }

    private func setManagedObjectContext() {
        let tabBarController = window?.rootViewController as! UITabBarController
        let mainNavigationController = tabBarController.viewControllers![0] as! UINavigationController
        let mainVC = mainNavigationController.viewControllers[0] as! MainVC
        mainVC.managedObjectContext = self.dataController.managedObjectContext
        
        let vagterNavigationController = tabBarController.viewControllers![1] as! UINavigationController
        let vagterVC = vagterNavigationController.viewControllers[0] as! VagterVC
        vagterVC.managedObjectContext = self.dataController.managedObjectContext
    }
    
    // MARK: UserDefaults
    
    private func registerDefaults() {
        
        let defaultsDic = [kFirstTime: true,
                           kTheme: Shop.ingen.rawValue,
                           kNotifications: [0],
                           kStandardHverdage: NSKeyedArchiver.archivedData(withRootObject: [StandardVagt]()),
                           kStandardLørdag: NSKeyedArchiver.archivedData(withRootObject: [StandardVagt]()),
                           kStandardSøndag: NSKeyedArchiver.archivedData(withRootObject: [StandardVagt]()),
                           kYoungBasisLon: 63.86,
                           kYoungAftensSats: 12.6,
                           kYoungLordagsSats: 22.38,
                           kYoungSondagsSats: 25.3,
                           kOldBasisLon: 112.42,
                           kOldAftensSats: 25.2,
                           kOldLordagsSats: 44.75,
                           kOldSondagsSats: 50.6] as [String : Any]
        UserDefaults.standard.register(defaults: defaultsDic)
    }
    
    // MARK: - Other AppDelegate Funcs
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

