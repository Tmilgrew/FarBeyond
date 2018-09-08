//
//  YouTubeVideo.swift
//  FarBeyond
//
//  Created by Thomas Milgrew on 5/9/18.
//  Copyright © 2018 Thomas Milgrew. All rights reserved.
//

import Foundation

struct YouTubeVideo {
    
    var videoTitle : String?
    var videoID : String?
    var videoDescription : String?
    var videoThumbnailDefaultURL : String?
    //var videoThumbnailDefaultData : Data?
    var videoToChannel : YouTubeChannel?
    var resultsPerPage : Int?
    var totalResults : Int?
    var nextPageToken : String?
    var previousPageToken : String?
}
