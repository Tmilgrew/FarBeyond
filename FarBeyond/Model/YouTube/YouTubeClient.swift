//
//  YouTubeClient.swift
//  FarBeyond
//
//  Created by Thomas Milgrew on 3/29/18.
//  Copyright © 2018 Thomas Milgrew. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn


// MARK: - TMDBClient: NSObject

class YouTubeClient : NSObject {

    // MARK: Properties
    // MARK: - Properties
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // shared session
    var session = URLSession.shared
    
    
    func taskForGETMethod(_ method: String, _ parameters: [String:AnyObject], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        var request = URLRequest(url: parseURLFromParameters(parameters, withPathExtension: method))
        request.addValue("Bearer " + GIDSignIn.sharedInstance().currentUser.authentication.accessToken, forHTTPHeaderField: "Authorization")

        
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
//            self.convertDataWithCompletionHandler(data!, completionHandlerForConvertData: completionHandlerForGET )
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx! -----\(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET )
            
        }
        task.resume()
        return task
    }
    
    func taskForDELETEMethod(_ method: String, _ parameters: [String:AnyObject], completionHandlerForDELETE: @escaping (_ result: AnyObject?, _ error: NSError?)-> Void) -> URLSessionDataTask
    {
        var request = URLRequest(url: parseURLFromParameters(parameters, withPathExtension: method))
        request.addValue("Bearer " + GIDSignIn.sharedInstance().currentUser.authentication.accessToken, forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        let session = URLSession.shared
        let task = session.dataTask(with: request) {(data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForDELETE(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* Was there an error? */
            guard error == nil else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            //self.convertDataWithCompletionHandler(data!, completionHandlerForConvertData: completionHandlerForDELETE)

            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 204 else {
                sendError("Your request returned a status code other than 204! -----\(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                return
            }
            
            /* If successful, there will not be any data returned, so we do not need to check for data.  Just that the repsonse code is 204. */
            completionHandlerForDELETE(nil, nil)
            
        }
        task.resume()
        return task
    }
    
    
    func taskForPOSTMethod(_ method: String, parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let parameters = parameters
        
        var request = URLRequest(url: parseURLFromParameters(parameters, withPathExtension: method))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer " + GIDSignIn.sharedInstance().currentUser.authentication.accessToken, forHTTPHeaderField: "Authorization")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request) { data, response, error in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* Was there an error? */
            guard error == nil else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            //self.convertDataWithCompletionHandler(data!, completionHandlerForConvertData: completionHandlerForPOST)
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx! -----\(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
            
        }
        task.resume()
        return task
    }
    
    func parseURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = YouTubeClient.Constants.ApiScheme
        components.host = YouTubeClient.Constants.ApiHost
        components.path = YouTubeClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(queryItem)
        }
        
        //print(components.url)
        return components.url!
    }

    // MARK: Helpers
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        print(parsedResult)
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // MARK: Shared Instance

    class func sharedInstance() -> YouTubeClient {
        struct Singleton {
            static var sharedInstance = YouTubeClient()
        }
        return Singleton.sharedInstance
    }
}
