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
            
            func sendError(_ error:NSError){
                // TODO: Send error to completion handler (completion handler not built yet at time of this note)
            }
            
            guard error == nil else {
                sendError(error!)
                return
            }
            
            guard let categoryItems = results?[JSONBodyResponse.categoryItems] as? [AnyObject] else {
                // TODO: What happens if this fails?
                return
            }
            
            print("\(categoryItems)")
            var categoryArray = [String]()
            
            for item in categoryItems {
                let snippet = item[JSONBodyResponse.snippet] as? AnyObject
                let categoryString = snippet![JSONBodyResponse.title] as! String
                categoryArray.append(categoryString)
            }
            print("\(categoryArray)")
            
            //print ("\(String(describing: results))")
        }
        
    }
}
