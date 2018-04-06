//
//  YouTubeConvenience.swift
//  FarBeyond
//
//  Created by Thomas Milgrew on 3/31/18.
//  Copyright © 2018 Thomas Milgrew. All rights reserved.
//

import Foundation
import UIKit



// MARK: - YouTubeClient (Convenient Resource Methods)

extension YouTubeClient {
    
    func getCategories(_ user : User){
        // TODO: add api Key!!!!!!
        let parameters = [
            YouTubeClient.ParameterKeys.Part:YouTubeClient.ParameterValues.Snippet,
            YouTubeClient.ParameterKeys.RegionCode:YouTubeClient.ParameterValues.USRegionCode//,
            //YouTubeClient.ParameterKeys.AccessToken: user.idToken
        ]
        let method = YouTubeClient.Methods.guideCategories
        print("\(method)")
        _ = taskForGETMethod(method, parameters as [String: AnyObject]) { (results, error) in
            
            print ("\(error)")
        }
        
    }
}
