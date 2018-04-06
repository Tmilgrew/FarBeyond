//
//  YouTubeConstants.swift
//  FarBeyond
//
//  Created by Thomas Milgrew on 3/29/18.
//  Copyright © 2018 Thomas Milgrew. All rights reserved.
//

// MARK: - YouTubeClient (Constants)

extension YouTubeClient {
    
    // MARK: Constants
    
    struct Constants {
        
        // MARK: Keys & IDs
        static let ApiScheme = "https"
        static let ApiHost = "www.googleapis.com"
        static let ApiPath = "/youtube/v3"
        
    }
    
    // MARK: Methods
    struct Methods{
        static let guideCategories = "/guideCategories"
    
    }
    
    // MARK: Youtube guideCategories Parameter Keys
    struct ParameterKeys{
        static var AccessToken = "access_token"
        static var Part = "part"
        static var RegionCode = "regionCode"
    }
    
    // MARK: Youtube guideCategories Parameter Values
    struct ParameterValues{
        static var Snippet = "snippet"
        static var USRegionCode = "us"
    }
    

}
