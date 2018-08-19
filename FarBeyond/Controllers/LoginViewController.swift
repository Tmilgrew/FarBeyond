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


// *************************************************************************************
// The login screen.  We are using youTube oAuth to sign in
// *************************************************************************************
class LoginViewController : UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    // MARK: Properties
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var dataController: DataController!
    var session: URLSession!
    
     // MARK: Outlets
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var signInButton: GIDSignInButton!
   
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign Google delegates
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        // Assign Google clientID and scopes
        GIDSignIn.sharedInstance().clientID = YouTubeClient.Constants.clientID
        GIDSignIn.sharedInstance().scopes = [YouTubeClient.Constants.scope1]
        
        GIDSignIn.sharedInstance().signInSilently()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // Mark: Login
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            YouTubeClient.sharedInstance().getChannels(){ (channels, error) in
                
                guard error == nil else {
                    self.showAlert()
                    return
                }
                
                guard let channels = channels else {
                    return
                }
                
                self.appDelegate.subscribedChannels = channels
                
                for (i, channel) in self.appDelegate.subscribedChannels.enumerated() {
                    YouTubeClient.sharedInstance().getVideosFromChannel(channel.channelID!, completionHandlerForGetVideosFromChannel: { (videos, error) in
                        
                        guard let videos = videos else  {
                            return
                        }
                        
                        self.appDelegate.subscribedChannels[i].videosForChannel = videos
                        
                        if i == (self.appDelegate.subscribedChannels.count - 1) {
                            performUIUpdatesOnMain {
                                self.performSegue(withIdentifier: "segueToContent", sender: self)
                                
                            }
                        }
                    })
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func showAlert(){
        let alert = UIAlertController(title: "Network Error", message: "You are not connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

