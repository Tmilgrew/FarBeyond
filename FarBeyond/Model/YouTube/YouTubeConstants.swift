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
        static let clientID = "352399262689-3a1vbjcaushnsvt10hkrr4tdai5129lc.apps.googleusercontent.com"
        static let scope1 = "https://www.googleapis.com/auth/youtube"
        
    }
    
    // MARK: Methods
    struct Methods{
        static let GuideCategories = "/guideCategories"
        static let Channels = "/channels"
        static let Search = "/search"
        static let Subscribe = "/subscriptions"
    
    }
    
    // MARK: Youtube guideCategories & search Parameter Keys
    struct ParameterKeys{
        static let AccessToken = "access_token"
        static let Part = "part"
        static let RegionCode = "regionCode"
        static let CategoryId = "categoryId"
        static let MaxResults = "maxResults"
        static let ChannelId = "channelId"
        static let Q = "q"
        static let resourceType = "type"
        
    }
    
    // MARK: Youtube guideCategories & search Parameter Values
    struct ParameterValues{
        static let Snippet = "snippet"
        static let USRegionCode = "us"
        static let Twentyfive = "25"
        static let Channel = "channel"
    }
    
    // MARK: JSON Body Response Constants
    struct JSONBodyResponse {
        static let CategoryItems = "items"
        static let Snippet = "snippet"
        static let Title = "title"
        static let Id = "id"
        static let Description = "description"
        static let Default = "default"
        static let URL = "url"
        static let Thumbnails = "thumbnails"
        static let VideoId = "videoId"
        static let ChannelId = "channelId"
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKey {
        static let Snippet = "snippet"
        static let ResourceId = "resourceId"
        static let Kind = "kind"
        static let channelId = "channelId"
    }
    
    // MARK: JSON Body Value
    struct JSONBodyValue {
        static let YoutubeChannel = "youtube#channel"
    }
    

}
