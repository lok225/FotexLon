//
//  AppDelegate.swift
//  Føtex Løn
//
//  Created by Martin Lok on 22/07/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dataController = DataController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Fjerner alle de skide UIKit debugger beskeder
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        setDataControllers()
        setManagedObjectContext()
        
        registerDefaults()
        setupStores()
        
        setGlobalColors()
        
        showLoginScreen(animated: false)
        
        print(UserDefaults.standard.bool(forKey: kFirstTime))
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        if shortcutItem.type == "com.martinlok.minLon.nyVagt" {
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
    
    func showLoginScreen(animated: Bool) {
        
        let defaults = UserDefaults.standard
        
        if defaults.bool(forKey: kFirstTime) == false && defaults.bool(forKey: kFirstTime103) == true {
            defaults.set(false, forKey: kFirstTime103)
            defaults.set("XDGJ-QAID", forKey: kEnteredCode)
            defaults.set(0, forKey: kStore)
            defaults.synchronize()
            
            return
        }
        
        for store in stores {
            if defaults.string(forKey: kEnteredCode) == store.code {
                return
            }
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "loginScreen")
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController?.present(vc, animated: animated, completion: nil)
    }
    
    func setupStores() {
        let noneStore = Store(id: 0, code: "XDGJ-QAID", hasOldLøn: true)
        noneStore.basisLon = 63.86
        noneStore.aftenTillæg = 12.6
        noneStore.lørdagTillæg = 22.38
        noneStore.søndagTillæg = 25.3
        noneStore.oldBasisLon = 112.42
        noneStore.oldAftenTillæg = 25.2
        noneStore.oldLørdagTillæg = 44.75
        noneStore.oldSøndagTillæg = 50.6
        noneStore.lønText = "Lønnen er baseret på HK Handels overenskomst og er gældende for Dansk Supermarked."
        
        let firstStore = Store(id: 1, code: "NIL", hasOldLøn: false)
        firstStore.basisLon = 75.9
        //firstStore.lonPeriodeStart = 15
        
        stores.append(noneStore)
        stores.append(firstStore)
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
                           kFirstTime103: true,
                           kEnteredCode: "XDGJ-QAID",
                           kLønperiodeIsSet: false,
                           kLønPeriodeStart: 1,
                           kAlderIsSet: false,
                           kIsLoggedIn: false,
                           kYoungWorker: true,
                           kAddToCalendar: false,
                           kFrikort: 0,
                           kTrækprocent: 0,
                           kTheme: Shop.teal.rawValue,
                           kStore: 0,
                           kNotifications: [0, 5],
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
    

}

extension AppDelegate {
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
