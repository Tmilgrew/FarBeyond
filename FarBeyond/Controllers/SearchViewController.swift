//
//  SearchNavigationController.swift
//  FarBeyond
//
//  Created by Thomas Milgrew on 5/9/18.
//  Copyright © 2018 Thomas Milgrew. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SDWebImage



class SearchViewController : UIViewController {
    
    // MARK: Properties
    
    // data for the table
    var channels = [YouTubeChannel]()
    var appDelegate = UIApplication.shared.delegate as! AppDelegate

    // the most recent data download task. We keep a reference to it so that it can be canceled every time the search text changes
    var searchTask: URLSessionDataTask?
    
    // MARK: Outlets
    
    @IBOutlet weak var channelSearchBar: UISearchBar!
    @IBOutlet weak var channelTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // configure the tap recognizer
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
        
        channelSearchBar.delegate = self
        channelTableView.delegate = self
        channelTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator.isHidden = true
    }
    
    // MARK: Dismissals
    
    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "pushToVideos"{
//            if let controller = segue.destination as? VideoListViewController {
//                controller.channel = channels[(channelTableView.indexPathForSelectedRow! as NSIndexPath).row]
//                controller.dataController = self.dataController
//            }
//        }
    }
}


// MARK: UIGestureRecognizerDelegate

extension SearchViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return channelSearchBar.isFirstResponder
    }
}

// MARK: SearchBarDelegate

extension SearchViewController : UISearchBarDelegate {
    
    // each time the search text changes we want to cancel any current download and start a new one
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // cancel the last task
        if let task = searchTask {
            task.cancel()
        }
        
        // if the text is empty, we are done
        if searchText == "" {
            channels = [YouTubeChannel]()
            channelTableView.reloadData()
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            return
        }
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        // new search
        searchTask = YouTubeClient.sharedInstance().getChannelsForSearchString(searchText) { (channels, error) in
            
            self.channels = [YouTubeChannel]()
            
            self.searchTask = nil
            if let channels = channels {
                self.channels = channels
                performUIUpdatesOnMain {
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    self.channelTableView.reloadData()
                    
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
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


// MARK: TableView Delegate Methods

extension SearchViewController : UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellResuseId = "ChannelSearchCell"
        let channel = channels[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellResuseId) as? SearchResultsCell
        
        cell?.activityIndicator.startAnimating()

        cell?.channelTitle?.text = channel.channelTitle
        cell?.channelDescription?.text = channel.channelDescription
        cell?.channelDescription?.numberOfLines = 2
        
        if let imageURLString = channel.channelThumbnailURLString  {
            let imageURL = URL(string: imageURLString)
            cell?.channelImage?.sd_setImage(with: imageURL, placeholderImage: UIImage(named: "placeholder"))
            
        }
        
        if appDelegate.subscribedChannels.contains(channels[(indexPath as NSIndexPath).row]) {
            cell?.subscribeButton.setTitle("GOT", for: .normal)
            cell?.subscribeButton.backgroundColor = UIColor.lightGray
        } else {
            cell?.subscribeButton.setTitle("GET", for: .normal)
            cell?.subscribeButton.backgroundColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
        }
        cell?.subscribeButton.tag = (indexPath as NSIndexPath).row
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    @IBAction func subscribeToChannel(sender: UIButton){
        let buttonTag = sender.tag
        let thisChannel = channels[buttonTag]
        
        YouTubeClient.sharedInstance().sendSubscribeRequest(thisChannel) { (result, error) in
            
            guard error == nil else {
                self.showAlert()
                return
            }
            
            if let result = result {
                self.appDelegate.subscribedChannels.append(result)
            }
            
            //self.appDelegate.subscribedChannels.append(result!)
            performUIUpdatesOnMain {
                // TODO: We need to correctly set the button text.  Get/Got.
                // Bug Known: Repeats in list for items not 'Got'
                let indexPath = [IndexPath(row: (sender.tag), section: 0)]
                self.channelTableView.reloadRows(at: indexPath, with: UITableViewRowAnimation.automatic)
                sender.setTitle("GOT", for: .normal)
            }
        }
    }
}


//extension SearchViewController : CoreDataClient {
//    func setStack(stack: DataController) { 
//        self.dataController = stack
//    }
//}


