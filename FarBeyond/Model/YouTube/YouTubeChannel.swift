//
//  YouTubeChannel.swift
//  FarBeyond
//
//  Created by Thomas Milgrew on 5/9/18.
//  Copyright © 2018 Thomas Milgrew. All rights reserved.
//

import Foundation

struct YouTubeChannel:Equatable {
    
    
    
    var channelTitle : String?
    var channelID : String?
    var subscriptionID : String?
    var channelDescription : String?
    var channelThumbnailURLString : String?
    //var channelThumbnailImageData : Data?
    var channelToCategory : YouTubeCategory?
    var isSubscribed : String?
    var videosForChannel : [YouTubeVideo]?
    var resultsPerPage : String?
    var totalResults : Int?
    var nextPageToken : String?
    var previousPageToken : String?
    
    //===============================================================================================
    // MARK: A function that allows us to see if the channel is contained within an array of channels
    //===============================================================================================
    static func == (lhs: YouTubeChannel, rhs: YouTubeChannel) -> Bool {
        return lhs.channelID == rhs.channelID
    }
}
