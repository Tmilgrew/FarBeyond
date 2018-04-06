//
//  User.swift
//  FarBeyond
//
//  Created by Thomas Milgrew on 4/2/18.
//  Copyright © 2018 Thomas Milgrew. All rights reserved.
//

import Foundation

struct User {
    
    var userID : String = String()
    var idToken : String = String()
    var fullName : String = String()
    var givenName : String = String()
    var familyName : String = String()
    var email : String = String()
    
    init(_ string: [String]) {
        userID = string[0]
        idToken = string[1]
        fullName = string[2]
        givenName = string[3]
        familyName = string[4]
        email = string[5]
    }
}
