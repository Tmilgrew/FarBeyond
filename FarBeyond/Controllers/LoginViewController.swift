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

class LoginViewController : UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    // MARK: Properties
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
     // TODO: Add label to storyboard and connect as outlet for debugTextLabel
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var signInButton: GIDSignInButton!
   
    
    
    var session: URLSession!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Implement configureBackground()
        //configureBackground()
        
        GIDSignIn.sharedInstance().clientID = "352399262689-79b66sah1jmpvboa0vusj6eceipchomh.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Uncomment to automatically sign in the user
        //GIDSignIn.sharedInstance().signInSilently()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //debugTextLabel.text = ""
    }
    
    // Mark: Login
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // TODO: Perform any operations on signed in user here.  With core data or firebase, save information below as user object
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            
            let userParametersArray = [userId, idToken, fullName, givenName, familyName, email]
            appDelegate.user = User(userParametersArray as! [String])
            print(userParametersArray, user)
            
            let controller = storyboard!.instantiateViewController(withIdentifier: "ManagerNavigationController") as! UINavigationController
            
            present(controller, animated: true, completion: nil)
            // ...
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // TODO: Perform any operations when the user disconnects from app here.
        // ...
        // TODO: Implement the disconnect method
    }
}

