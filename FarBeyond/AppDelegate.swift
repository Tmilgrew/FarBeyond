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
    var category: [Category]?
    var channelsFromCategory: [Channel]?
    var accessToken : String!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        GIDSignIn.sharedInstance().clientID = "352399262689-3a1vbjcaushnsvt10hkrr4tdai5129lc.apps.googleusercontent.com"
//        GIDSignIn.sharedInstance().scopes = [
//            "https://www.googleapis.com/auth/youtube"
//        ]
//        GIDSignIn.sharedInstance().delegate = self
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
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        
        return GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation:options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    // Deprecated method for app to run on iOS 8 and older.
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        
        
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
//              withError error: Error!) {
//        if let error = error {
//            print("\(error.localizedDescription)")
//        } else {
//            // Perform any operations on signed in user here.
//            let userId = user.userID                  // For client-side use only!
//            let idToken = user.authentication.idToken // Safe to send to the server
//            let fullName = user.profile.name
//            let givenName = user.profile.givenName
//            let familyName = user.profile.familyName
//            let email = user.profile.email
//
//            let properties = [userId, idToken, fullName, givenName, familyName, email]
//            self.user = User(properties as! [String])
//            print("\(properties)")
//
//            self.accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken
//
//            YouTubeClient.sharedInstance().getCategories(self.user!)
//            // ...
//        }
//    }
//    
//    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
//              withError error: Error!) {
//        // Perform any operations when the user disconnects from app here.
//        // ...
//    }

}

