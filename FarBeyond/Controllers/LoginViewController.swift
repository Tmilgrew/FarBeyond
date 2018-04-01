//
//  LoginViewController.swift
//  FarBeyond
//
//  Created by Thomas Milgrew on 3/29/18.
//  Copyright © 2018 Thomas Milgrew. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController : UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var debugTextLabel: UILabel!
    // TODO: Add button to storyboard and connect as outlet below. Same for debugTextLabel
    //@IBOutlet weak var loginButton: BorderedButton!
    
    var session: URLSession!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Implement configureBackground()
        //configureBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debugTextLabel.text = ""
    }
}

