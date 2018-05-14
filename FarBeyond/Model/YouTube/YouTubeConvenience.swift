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
    
    func getCategories(completionHandlerForGetCategories: @escaping (_ results:[AnyObject]?, _ error: NSError?) -> Void){
        
        let parameters = [
            YouTubeClient.ParameterKeys.Part:YouTubeClient.ParameterValues.Snippet,
            YouTubeClient.ParameterKeys.RegionCode:YouTubeClient.ParameterValues.USRegionCode
        ]
        let method = YouTubeClient.Methods.GuideCategories
        //print("-------------------------------------------------THE METHOD IS: \(method)")
        _ = taskForGETMethod(method, parameters as [String: AnyObject]) { (results, error) in
            
            func sendError(_ error:NSError){
                // TODO: Send error to completion handler (completion handler not built yet at time of this note)
                completionHandlerForGetCategories(nil, error)
            }
            
            guard error == nil else {
                sendError(error!)
                return
            }
            
            guard let categoryItems = results?[JSONBodyResponse.CategoryItems] as? [AnyObject] else {
                // TODO: What happens if this fails?
                return
            }
            
           //print("\(categoryItems)")
            completionHandlerForGetCategories(categoryItems, nil)
            //var string = String()
//            var categoryArray = [String]()
//            var editorCategory = String()
//            editorCategory.id = "007"
//            editorCategory.name = "Editor's Pick"
//            categoryArray.append(editorCategory)
//
//            for item in categoryItems {
//                var category = Category()
//                category.id = item[JSONBodyResponse.CategoryId] as! String
//                if let snippet = item[JSONBodyResponse.Snippet] as? [String:AnyObject] {
//                    category.name = snippet[JSONBodyResponse.Title] as! String
//                    categoryArray.append(category)
//                }
//            }
//
//            completionHandlerForGetCategories(categoryArray, nil)
            //print ("\(String(describing: results))")
        }
        
    }
    
    func getChannelsFromCategory(_ category: String, completionHandlerForGetChannelsFromCategory: @escaping (_ results:[AnyObject]?, _ error: NSError?) -> Void){
        
        let parameters = [
            YouTubeClient.ParameterKeys.Part : YouTubeClient.ParameterValues.Snippet,
            YouTubeClient.ParameterKeys.MaxResults : YouTubeClient.ParameterValues.Twentyfive,
            YouTubeClient.ParameterKeys.CategoryId : category
        ]
        
        let method = YouTubeClient.Methods.Channels
        
        _ = taskForGETMethod(method, parameters as [String: AnyObject]) { (results, error) in
            
            func sendError(_ error: NSError){
                completionHandlerForGetChannelsFromCategory(nil, error)
            }
            
            guard error == nil else {
                sendError(error!)
                return
            }
            
            guard let channels = results?[YouTubeClient.JSONBodyResponse.CategoryItems] as? [AnyObject] else {
                // TODO: What happens if this fails?
                return
            }
//            var channelArray = [Channel]()
//            for channel in channels {
//                let customChannel = Channel()
//                customChannel.channelID = channel[YouTubeClient.JSONBodyResponse.CategoryId] as? String
//
//
//
//                let thumbnailSnippet = channel[YouTubeClient.JSONBodyResponse.Snippet] as? [String:AnyObject]
//                customChannel.channelTitle = thumbnailSnippet?[YouTubeClient.JSONBodyResponse.Title] as? String
//                customChannel.channelDescription = thumbnailSnippet?[YouTubeClient.JSONBodyResponse.Description] as? String
//
//                let allThumbnails = thumbnailSnippet?[YouTubeClient.JSONBodyResponse.Thumbnails] as? [String:AnyObject]
//                let defaultThumbnail = allThumbnails?[YouTubeClient.JSONBodyResponse.Default] as? [String:AnyObject]
//                let defaultURL = defaultThumbnail?[YouTubeClient.JSONBodyResponse.URL] as? String
//                //print("\(defaultURL)")
//                //print("\(defaultURL)")
//                customChannel.channelThumbnailURL = defaultURL
//                channelArray.append(customChannel)
//            }
            //print("\(channels)")
            completionHandlerForGetChannelsFromCategory(channels, nil)
            //print("\(String(describing: channels))")
        }
    }
    
    func getVideosFromChannel(_ channel: String, completionHandlerForGetVideosFromChannel: @escaping (_ results:[AnyObject]?, _ error: NSError?) -> Void){
        
        let parameters = [
            YouTubeClient.ParameterKeys.Part : YouTubeClient.ParameterValues.Snippet,
            YouTubeClient.ParameterKeys.MaxResults : YouTubeClient.ParameterValues.Twentyfive,
            YouTubeClient.ParameterKeys.ChannelId : channel
        ]
        
        let method = YouTubeClient.Methods.Search
        
        _ = taskForGETMethod(method, parameters as [String:AnyObject], completionHandlerForGET: { (results, error) in
            
            func sendError(_ error: NSError){
                completionHandlerForGetVideosFromChannel(nil, error)
            }
            
            guard error == nil else {
                sendError(error!)
                return
            }
            
            // TODO: Change variable CategoryItems to just an 'items' name.  This is not fetching just categories.
            guard let videos = results?[YouTubeClient.JSONBodyResponse.CategoryItems] as? [AnyObject] else {
                // TODO: What happens if this fails?
                return
            }
            
            completionHandlerForGetVideosFromChannel(videos, nil)
            //print("We have made it!!!")
        })
    }
    
    func getChannelsForSearchString(_ searchString: String, completionHandlerForGetChannelsForSearchString: @escaping (_ results:[YouTubeChannel]?, _ error: NSError?) -> Void) -> URLSessionDataTask? {
        
        let parameters = [
            YouTubeClient.ParameterKeys.Part : YouTubeClient.ParameterValues.Snippet,
            YouTubeClient.ParameterKeys.MaxResults : YouTubeClient.ParameterValues.Twentyfive,
            YouTubeClient.ParameterKeys.Q : searchString,
            YouTubeClient.ParameterKeys.resourceType : YouTubeClient.ParameterValues.Channel
        ]
        
        let method = YouTubeClient.Methods.Search
        
        let task = taskForGETMethod(method, parameters as [String:AnyObject]) { (results, error) in
            
            func sendError(_ error: NSError) {
                completionHandlerForGetChannelsForSearchString(nil, error)
            }
            
            guard error == nil else {
                sendError(error!)
                return
            }
            
            guard let channelBlock = results?[YouTubeClient.JSONBodyResponse.CategoryItems] as? [AnyObject] else {
                // TODO: What happens if this fails?
                return
            }
            
            var channelArray = [YouTubeChannel]()
            for channel in channelBlock {
                var newChannel = YouTubeChannel()
                let idBlock = channel[YouTubeClient.JSONBodyResponse.Id] as! [String: AnyObject]
                newChannel.channelID = idBlock[YouTubeClient.JSONBodyResponse.ChannelId] as? String 
                let thumbnailSnippet = channel[YouTubeClient.JSONBodyResponse.Snippet] as? [String:AnyObject]
                newChannel.channelTitle = thumbnailSnippet?[YouTubeClient.JSONBodyResponse.Title] as? String
                newChannel.channelDescription = thumbnailSnippet?[YouTubeClient.JSONBodyResponse.Description] as? String
                
                let allThumbnails = thumbnailSnippet?[YouTubeClient.JSONBodyResponse.Thumbnails] as? [String:AnyObject]
                let defaultThumbnail = allThumbnails?[YouTubeClient.JSONBodyResponse.Default] as? [String:AnyObject]
                let defaultURL = defaultThumbnail?[YouTubeClient.JSONBodyResponse.URL] as? String
                //print("\(defaultURL)")
                //print("\(defaultURL)")
                newChannel.channelThumbnailURLString = defaultURL
                channelArray.append(newChannel)
                //print("---------Channel id is: \(channel)")
            }
            
            completionHandlerForGetChannelsForSearchString(channelArray, nil)
        }
        
        return task
        
    }
}
