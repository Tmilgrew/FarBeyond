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
    var category : YouTubeCategory!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var channelsFromCategory: [YouTubeChannel] = []
    var dataController: DataController!
    
    // MARK: Outlets
    @IBOutlet weak var channelTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        channelTableView.delegate = self
        channelTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayChannelsFromCategory(category.id!)
    }
    
    // MARK: Helper Methods
    private func displayChannelsFromCategory(_ categoryId: String){
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        YouTubeClient.sharedInstance().getChannelsFromCategory(categoryId){ (results, error) in
            guard error == nil else {
                self.showAlert()
                performUIUpdatesOnMain {
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
                return
            }
            
            for channel in results! {
                var customChannel = YouTubeChannel()
                customChannel.channelID = channel[YouTubeClient.JSONBodyResponse.Id] as? String
                
                let thumbnailSnippet = channel[YouTubeClient.JSONBodyResponse.Snippet] as? [String:AnyObject]
                customChannel.channelTitle = thumbnailSnippet?[YouTubeClient.JSONBodyResponse.Title] as? String
                customChannel.channelDescription = thumbnailSnippet?[YouTubeClient.JSONBodyResponse.Description] as? String
                
                let allThumbnails = thumbnailSnippet?[YouTubeClient.JSONBodyResponse.Thumbnails] as? [String:AnyObject]
                let defaultThumbnail = allThumbnails?[YouTubeClient.JSONBodyResponse.Default] as? [String:AnyObject]
                let defaultURL = defaultThumbnail?[YouTubeClient.JSONBodyResponse.URL] as? String
                customChannel.channelThumbnailURLString = defaultURL
                customChannel.channelToCategory = self.category
                self.channelsFromCategory.append(customChannel)
            }
            

            performUIUpdatesOnMain {
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                self.channelTableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushToVideos"{
            if let controller = segue.destination as? VideoListViewController {
                controller.channel = channelsFromCategory[(channelTableView.indexPathForSelectedRow! as NSIndexPath).row]
                controller.dataController = self.dataController
            }
        }
    }
    
    func showAlert(_ error: String){
        let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(){
        let alert = UIAlertController(title: "Network Error", message: "You are not connected to the internet.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            }}))
        self.present(alert, animated: true, completion: nil)
    }
}

extension CategoryChannelViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelsFromCategory.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "ChannelTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as? SearchResultsCell
        cell?.activityIndicator.startAnimating()        
        
        cell?.channelTitle?.text = channelsFromCategory[(indexPath as NSIndexPath).row].channelTitle
        cell?.channelDescription?.text = channelsFromCategory[(indexPath as NSIndexPath).row].channelDescription
        cell?.detailTextLabel?.numberOfLines = 2
        
        if channelsFromCategory[(indexPath as NSIndexPath).row].channelThumbnailImageData == nil {
            
            DispatchQueue.main.async(){
                guard let image = try? UIImage(data: Data(contentsOf: URL(string: (self.channelsFromCategory[(indexPath as NSIndexPath).row].channelThumbnailURLString)!)!)) else {
                    self.showAlert()
                    return
                }
                
                self.channelsFromCategory[(indexPath as NSIndexPath).row].channelThumbnailImageData = UIImagePNGRepresentation(image!)
                //try? self.dataController.viewContext.save()
                performUIUpdatesOnMain {
                    cell?.channelImage?.image = image
                    cell?.activityIndicator.stopAnimating()
                    cell?.activityIndicator.isHidden = true
                    self.channelTableView.reloadData()
                }
            }
        } else {
            let image = UIImage(data: (channelsFromCategory[(indexPath as NSIndexPath).row].channelThumbnailImageData)! as Data)
            cell?.channelImage?.image = image
            cell?.activityIndicator.stopAnimating()
            cell?.activityIndicator.isHidden = true
        }
        
        if appDelegate.subscribedChannels.contains(channelsFromCategory[(indexPath as NSIndexPath).row]) {
            cell?.subscribeButton.setTitle("GOT", for: .normal)
        } else {
            cell?.subscribeButton.setTitle("GET", for: .normal)
        }
        cell?.subscribeButton.tag = (indexPath as NSIndexPath).row
        return cell!
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    @IBAction func subscribeToChannel(sender: UIButton){
        let buttonTag = sender.tag
        let thisChannel = channelsFromCategory[buttonTag]
        
        
        
        YouTubeClient.sharedInstance().sendSubscribeRequest(thisChannel) { (result, error) in
            
            guard error == nil else {
                self.showAlert()
                return
            }
            
            //self.appDelegate.subscribedChannels.append(result!)
            performUIUpdatesOnMain {
                // TODO: We need to correctly set the button text.  Get/Got.
                // Bug Known: Repeats in list for items not 'Got'
                sender.setTitle("GOT", for: .normal)
            }
        }
    }
}
