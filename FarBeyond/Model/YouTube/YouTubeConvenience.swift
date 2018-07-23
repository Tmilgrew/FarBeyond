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
        _ = taskForGETMethod(method, parameters as [String: AnyObject]) { (results, error) in
            
            func sendError(_ error:NSError){
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
            
            completionHandlerForGetCategories(categoryItems, nil)
        }
        
    }
    
    func getChannels(completionHandlerForGetChannels: @escaping (_ results:[YouTubeChannel]?, _ error: NSError?) -> Void){
        
        let parameters = [
            YouTubeClient.ParameterKeys.Part : "\(YouTubeClient.ParameterValues.Snippet),\(YouTubeClient.ParameterValues.ContentDetails)" as AnyObject,
            YouTubeClient.ParameterKeys.Mine : "true",
            YouTubeClient.ParameterKeys.MaxResults : 20
            ] as [String : AnyObject]
        
        let method = YouTubeClient.Methods.Subscribe
        
        let task = taskForGETMethod(method, parameters) { (results, error) in
            
            func sendError(_ error: NSError){
                completionHandlerForGetChannels(nil, error)
            }
            
            
            guard error == nil else {
                sendError(error!)
                return
            }
            
            guard let results = results as? [String:AnyObject] else {
                print("****ERROR: Results did not equal results.  Issue at getChannels().")
                return
            }
            
            print(results)
            
            guard let allSubscribedChannels = results[YouTubeClient.JSONBodyResponse.CategoryItems] as? [AnyObject] else {
                print("****ERROR: Problem parsing JSON.  Issue at allSubscribedChannels.****")
                return
            }
            
            var subscribedChannelsArray = [YouTubeChannel]()
            
            for singleSubscribedChannel in allSubscribedChannels {
                
                guard let snippet = singleSubscribedChannel[YouTubeClient.JSONBodyResponse.Snippet] as? [String:AnyObject] else {
                    return
                }
                
                //print("**** TEST - THE SNIPPET READS: \(snippet)")
                
                var singleChannel = YouTubeChannel()
                //singleChannel.channelID = snippet[YouTubeClient.JSONBodyResponse.ChannelId] as? String
                singleChannel.channelDescription = snippet[YouTubeClient.JSONBodyResponse.Description] as? String
                singleChannel.channelTitle = snippet[YouTubeClient.JSONBodyResponse.Title] as? String
                
                guard let resourceID = snippet[YouTubeClient.JSONBodyResponse.ResourceId] as? [String:AnyObject] else {
                    return
                }
                
                singleChannel.channelID = resourceID[YouTubeClient.JSONBodyResponse.ChannelId] as? String
            
                guard let thumbnails = snippet[YouTubeClient.JSONBodyResponse.Thumbnails] as? [String:AnyObject] else {
                    print("-----------------We missed the thumbnails.")
                    return
                }
                
                guard let defaultThumbnail = thumbnails[YouTubeClient.JSONBodyResponse.Default] as? [String:AnyObject] else {
                    return
                }
                
                singleChannel.channelThumbnailURLString = defaultThumbnail[YouTubeClient.JSONBodyResponse.URL] as? String
                
                subscribedChannelsArray.append(singleChannel)
            
                
            
            }
            completionHandlerForGetChannels(subscribedChannelsArray,nil)
        
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
            completionHandlerForGetChannelsFromCategory(channels, nil)
        }
    }
    
    func getVideosFromChannel(_ channel: String, completionHandlerForGetVideosFromChannel: @escaping (_ results:[AnyObject]?, _ error: NSError?) -> Void){
        
        let parameters = [
            YouTubeClient.ParameterKeys.Part : YouTubeClient.ParameterValues.Snippet,
            YouTubeClient.ParameterKeys.MaxResults : YouTubeClient.ParameterValues.Twentyfive,
            YouTubeClient.ParameterKeys.ChannelId : channel
        ]
        
        //print("****TEST - THE CHANNEL ID IS: \(channel)")
        
        let method = YouTubeClient.Methods.Search
        
        _ = taskForGETMethod(method, parameters as [String:AnyObject], completionHandlerForGET: { (results, error) in
            
            func sendError(_ error: NSError){
                completionHandlerForGetVideosFromChannel(nil, error)
            }
            
            guard error == nil else {
                sendError(error!)
                return
            }
            
            //print("****TEST - VIDEO RESULTS ARE: \(results)")
            
            // TODO: Change variable CategoryItems to just an 'items' name.  This is not fetching just categories.
            guard let videos = results?[YouTubeClient.JSONBodyResponse.CategoryItems] as? [AnyObject] else {
                // TODO: What happens if this fails?
                return
            }
            
            
            
            completionHandlerForGetVideosFromChannel(videos, nil)
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
                newChannel.channelThumbnailURLString = defaultURL
                channelArray.append(newChannel)
            }
            
            completionHandlerForGetChannelsForSearchString(channelArray, nil)
        }
        
        return task
        
    }
    
    
    
    func sendSubscribeRequest(_ channel: YouTubeChannel, completionHandlerForSendSubscribeRequest: @escaping (_ results:YouTubeChannel?, _ error: NSError?) -> Void){
        let parameters = [YouTubeClient.ParameterKeys.Part : YouTubeClient.ParameterValues.Snippet]
        let jsonBody = "{\"\(YouTubeClient.JSONBodyKey.Snippet)\": {\"\(YouTubeClient.JSONBodyKey.ResourceId)\": {\"\(YouTubeClient.JSONBodyKey.Kind)\": \"\(YouTubeClient.JSONBodyValue.YoutubeChannel)\", \"\(YouTubeClient.JSONBodyKey.channelId)\": \"\(channel.channelID as! String)\"}}}"
        
        let method = YouTubeClient.Methods.Subscribe
        
        let task = taskForPOSTMethod(method, parameters: parameters as [String : AnyObject], jsonBody: jsonBody) { (result, error) in
            
            func sendError(_ error: NSError) {
                completionHandlerForSendSubscribeRequest(nil, error)
            }
            
            guard let result = result else {
                return
            }
            
            print(result)
            
            guard let channelBlock = result[YouTubeClient.JSONBodyResponse.Snippet] as? [String:AnyObject] else {
                return
            }
            
            print(channelBlock)
            
            var newChannel = YouTubeChannel()
            newChannel.channelDescription = channelBlock[YouTubeClient.JSONBodyResponse.Description] as? String
            newChannel.channelID = channelBlock[YouTubeClient.JSONBodyResponse.ChannelId] as? String
            newChannel.channelTitle = channelBlock[YouTubeClient.JSONBodyResponse.Title] as? String
            
            guard let thumbnailBlock = channelBlock[YouTubeClient.JSONBodyResponse.Thumbnails] as? [String:AnyObject] else{
                return
            }
            guard let defaultThumbnail = thumbnailBlock[YouTubeClient.JSONBodyResponse.Default] as? [String:AnyObject] else {
                return
            }
            
            newChannel.channelThumbnailURLString = defaultThumbnail[YouTubeClient.JSONBodyResponse.URL] as? String
            
            completionHandlerForSendSubscribeRequest(newChannel, nil)
        }
    }
}
