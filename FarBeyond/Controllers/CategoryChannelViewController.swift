//
//  CategoryChannelViewController.swift
//  FarBeyond
//
//  Created by Thomas Milgrew on 4/12/18.
//  Copyright © 2018 Thomas Milgrew. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CategoryChannelViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    var category : Category!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var channelsFromCategory: [Channel]?
    var dataController: DataController!
    
    // MARK: Outlets
    @IBOutlet weak var channelTableView: UITableView!
    
    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        channelTableView.delegate = self
        channelTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        let fetchRequest: NSFetchRequest<Channel> = Channel.fetchRequest()
        let predicate = NSPredicate(format: "channelToCategory == %@", category)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "channelID", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            if result.count == 0 {
                displayChannelsFromCategory(category.id!)
            } else {
                channelsFromCategory = result
            }
        }
        
    }
    
    // MARK: Helper Methods
    private func displayChannelsFromCategory(_ categoryId: String){
        
        YouTubeClient.sharedInstance().getChannelsFromCategory(appDelegate.user, categoryId){ (results, error) in
            guard error == nil else {
                // TODO: Take the error and display and error message on the screen
                return
            }
            
            //var channelArray = [Channel]()
            for channel in results! {
                let customChannel = Channel(context: self.dataController.viewContext)
                customChannel.channelID = channel[YouTubeClient.JSONBodyResponse.CategoryId] as? String
                
                
                
                let thumbnailSnippet = channel[YouTubeClient.JSONBodyResponse.Snippet] as? [String:AnyObject]
                customChannel.channelTitle = thumbnailSnippet?[YouTubeClient.JSONBodyResponse.Title] as? String
                customChannel.channelDescription = thumbnailSnippet?[YouTubeClient.JSONBodyResponse.Description] as? String
                
                let allThumbnails = thumbnailSnippet?[YouTubeClient.JSONBodyResponse.Thumbnails] as? [String:AnyObject]
                let defaultThumbnail = allThumbnails?[YouTubeClient.JSONBodyResponse.Default] as? [String:AnyObject]
                let defaultURL = defaultThumbnail?[YouTubeClient.JSONBodyResponse.URL] as? String
                //print("\(defaultURL)")
                //print("\(defaultURL)")
                customChannel.channelThumbnailURL = defaultURL
                customChannel.channelToCategory = self.category
                try? self.dataController.viewContext.save()
                //channelArray.append(customChannel)
            }
            
            let fetchRequest : NSFetchRequest<Channel> = Channel.fetchRequest()
            let predicate = NSPredicate(format: "channelToCategory == %@", self.category)
            fetchRequest.predicate = predicate
            let sortDescriptor = NSSortDescriptor(key: "channelID", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            if let results = try? self.dataController.viewContext.fetch(fetchRequest){
                self.channelsFromCategory = results
            }
            
            //self.channelsFromCategory = channelArray
            //print("-----The results are: \(String(describing: results))")
            performUIUpdatesOnMain {
                self.channelTableView.reloadData()
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushToVideos"{
            if let controller = segue.destination as? VideoListViewController {
                controller.channel = channelsFromCategory![(channelTableView.indexPathForSelectedRow! as NSIndexPath).row]
                controller.dataController = self.dataController
            }
        }
    }
}

extension CategoryChannelViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: Configure the number of rows based on number of categories
        return channelsFromCategory?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "ChannelTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)
        
        // TODO: Decorate the cell
        cell?.textLabel?.text = channelsFromCategory?[(indexPath as NSIndexPath).row].channelTitle
        cell?.detailTextLabel?.text = channelsFromCategory?[(indexPath as NSIndexPath).row].description
        
        if channelsFromCategory?[(indexPath as NSIndexPath).row].channelThumbnailData == nil {
//            cell?.imageView?.image = UIImage(named: "placeholder")
//            cell.activityIndicator.isHidden = false
//            cell.activityIndicator.startAnimating()
            
            DispatchQueue.main.async(){
                //let backgroundPhoto = backgroundContext.object(with: photoID) as! Photo
                let image = try! UIImage(data: Data(contentsOf: URL(string: (self.channelsFromCategory?[(indexPath as NSIndexPath).row].channelThumbnailURL)!)!))
                self.channelsFromCategory?[(indexPath as NSIndexPath).row].channelThumbnailData = UIImagePNGRepresentation(image!)
                try? self.dataController.viewContext.save()
//                cell.activityIndicator.isHidden = true
//                cell.activityIndicator.stopAnimating()
                performUIUpdatesOnMain {
                    cell?.imageView?.image = image
                    self.channelTableView.reloadData()
                }
                
            }
        } else {
            let image = UIImage(data: (channelsFromCategory?[(indexPath as NSIndexPath).row].channelThumbnailData)! as Data)
            cell?.imageView?.image = image
        }
        
//        getDataFromUrl(url: URL(string: (channelsFromCategory?[(indexPath as NSIndexPath).row].channelThumbnailURL)!)!) { (data, response, error) in
//            guard let data = data, error == nil else{
//                return
//            }
//            performUIUpdatesOnMain {
//                cell?.imageView?.image = UIImage(data: data)
//                self.channelTableView.reloadData()
//            }
//        }
        
        return cell!
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let controller = storyboard!.instantiateViewController(withIdentifier: "CategoryChannelsViewController") as! CategoryChannelViewController
//        controller.category = appDelegate.category?[(indexPath as NSIndexPath).row].id
//        present(controller, animated: false, completion: nil)
//    }
}
