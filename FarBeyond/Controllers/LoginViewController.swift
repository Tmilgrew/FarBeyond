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
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = "352399262689-3a1vbjcaushnsvt10hkrr4tdai5129lc.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().scopes = [
            "https://www.googleapis.com/auth/youtube"
        ]
        GIDSignIn.sharedInstance().delegate = self
        // TODO: Implement configureBackground()
        //configureBackground()
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //debugTextLabel.text = ""
    }
    
    // Mark: Login
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            
            let properties = [userId, idToken, fullName, givenName, familyName, email]
            appDelegate.user = User(properties as! [String])
            print("\(properties)")
            
            appDelegate.accessToken = GIDSignIn.sharedInstance().currentUser.authentication.accessToken
            
            YouTubeClient.sharedInstance().getCategories(appDelegate.user!)
            // ...
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
}

