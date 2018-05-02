//
//  AppDelegate.swift
//  FarBeyond
//
//  Created by Thomas Milgrew on 3/28/18.
//  Copyright © 2018 Thomas Milgrew. All rights reserved.
//

import UIKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var user: User!
//    var category: [Category]?
//    var channelsFromCategory: [Channel]?
    var accessToken : String!
    let dataController = DataController(modelName: "Model")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        dataController.load()
        
        // If the the 'authenticated' value is set up in UserDefaults continue forward,
        // otherwise go to else statement
        //******************************************************************************************
        if let authenticatedUser = UserDefaults.standard.value(forKey: "authenticated") {
            
            // The value for 'authenticated' has been set before.  Is the value false?
            // The user is then not signed in.  Execute the following block of code
            //**************************************************************************************
            if authenticatedUser as! Bool == false {
                let rootController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginViewController")
                self.window?.rootViewController = rootController
                
            } else {
                if let tab = window?.rootViewController as? MainTabBarController {
                    for child in (tab.viewControllers as? [UINavigationController]) ?? [] {
                        let firstViewController = child.viewControllers.first
                        if let top = firstViewController as? CoreDataClient {
                            top.setStack(stack: dataController)
                        }
                    }
                }
            }
        // The 'authenticated' valuse has not been set up.
        // This block sets the initial value for 'authenticated' in UserDefaults.
        // After we set the value, we make the rootViewController the LoginViewController
        //*******************************************************************************************
        } else {
            UserDefaults.standard.setValue(false, forKey: "authenticated")
            
            let rootController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginViewController")
            self.window?.rootViewController = rootController
            print("This is the first time launching the app!")
        }
        
        //dataController.load()
//        let rootViewController = window?.rootViewController as? MainTabBarController
//        rootViewController?.dataController = dataController
//        if let tab = window?.rootViewController as? MainTabBarController {
//            for child in tab.viewControllers ?? [] {
//                if let top = child as? CoreDataClient {
//                    top.setStack(stack: dataController)
//                }
//            }
//        }
        
        return true
    }

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
        UserDefaults.standard.setValue(false, forKey: "authenticated")
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        
        return GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation:options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    // Deprecated method for app to run on iOS 8 and older.
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        
        
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    


}

