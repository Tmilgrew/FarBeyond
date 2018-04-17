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
    
    func getCategories(_ user : User, completionHandlerForGetCategories: @escaping (_ results:[Category]?, _ error: NSError?) -> Void){
        
        let parameters = [
            YouTubeClient.ParameterKeys.Part:YouTubeClient.ParameterValues.Snippet,
            YouTubeClient.ParameterKeys.RegionCode:YouTubeClient.ParameterValues.USRegionCode
        ]
        let method = YouTubeClient.Methods.GuideCategories
        print("\(method)")
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
            
           // print("\(categoryItems)")
            var categoryArray = [Category]()
            var editorCategory = Category()
            editorCategory.id = "007"
            editorCategory.name = "Editor's Pick"
            categoryArray.append(editorCategory)
            
            for item in categoryItems {
                var category = Category()
                category.id = item[JSONBodyResponse.CategoryId] as! String
                if let snippet = item[JSONBodyResponse.Snippet] as? [String:AnyObject] {
                    category.name = snippet[JSONBodyResponse.Title] as! String
                    categoryArray.append(category)
                }
            }
            
            completionHandlerForGetCategories(categoryArray, nil)
            //print ("\(String(describing: results))")
        }
        
    }
    
    func getChannelsFromCategory(_ user: User, _ category: String, completionHandlerForGetChannelsFromCategory: @escaping (_ results:[Channel]?, _ error: NSError?) -> Void){
        
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
            var channelArray = [Channel]()
            for channel in channels {
                var customChannel = Channel()
                customChannel.id = channel[YouTubeClient.JSONBodyResponse.CategoryId] as? String
                
                
                
                let thumbnailSnippet = channel[YouTubeClient.JSONBodyResponse.Snippet] as? [String:AnyObject]
                customChannel.title = thumbnailSnippet?[YouTubeClient.JSONBodyResponse.Title] as? String
                customChannel.description = thumbnailSnippet?[YouTubeClient.JSONBodyResponse.Description] as? String
                
                let allThumbnails = thumbnailSnippet?[YouTubeClient.JSONBodyResponse.Thumbnails] as? [String:AnyObject]
                let defaultThumbnail = allThumbnails?[YouTubeClient.JSONBodyResponse.Default] as? [String:AnyObject]
                let defaultURL = defaultThumbnail?[YouTubeClient.JSONBodyResponse.URL] as? String
                //print("\(defaultURL)")
                //print("\(defaultURL)")
                customChannel.thumbnail = defaultURL
                channelArray.append(customChannel)
            }
            //print("\(channels)")
            completionHandlerForGetChannelsFromCategory(channelArray, nil)
            //print("\(String(describing: channels))")
        }
    }
}
