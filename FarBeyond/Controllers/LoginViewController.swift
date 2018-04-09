//
//  LoginViewController.swift
//  FarBeyond
//
//  Created by Thomas Milgrew on 3/29/18.
//  Copyright © 2018 Thomas Milgrew. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn

class LoginViewController : UIViewController, GIDSignInUIDelegate {
    
    // MARK: Properties
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
     // TODO: Add label to storyboard and connect as outlet for debugTextLabel
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var signInButton: GIDSignInButton!
   
    
    
    var session: URLSession!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        // TODO: Implement configureBackground()
        //configureBackground()
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //debugTextLabel.text = ""
    }
    
    // Mark: Login
    
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        if (error == nil) {
//            // Perform any operations on signed in user here.
//            YouTubeClient.sharedInstance().getCategories(appDelegate.user!)
//            
////            let controller = storyboard!.instantiateViewController(withIdentifier: "ManagerNavigationController") as! UINavigationController
////            present(controller, animated: true, completion: nil)
//            // ...
//        } else {
//            print("\(error.localizedDescription)")
//        }
//            
////
//            // ...
//        
//    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // TODO: Perform any operations when the user disconnects from app here.
        // ...
        // TODO: Implement the disconnect method
    }
}

