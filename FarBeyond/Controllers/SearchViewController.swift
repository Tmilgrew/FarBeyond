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



class SearchViewController : UIViewController {
    
    // MARK: Properties
    
    // data for the table
    var channels = [YouTubeChannel]()
    var dataController: DataController!
    
    // the most recent data download task. We keep a reference to it so that it can be canceled every time the search text changes
    var searchTask: URLSessionDataTask?
    
    // MARK: Outlets
    
    @IBOutlet weak var channelSearchBar: UISearchBar!
    @IBOutlet weak var channelTableView: UITableView!
    
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
    
    // MARK: Dismissals
    
    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // MARK: Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushToVideos"{
            if let controller = segue.destination as? VideoListViewController {
                controller.channel = channels[(channelTableView.indexPathForSelectedRow! as NSIndexPath).row]
                controller.dataController = self.dataController
            }
        }
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
            return
        }
        
        // new search
        searchTask = YouTubeClient.sharedInstance().getChannelsForSearchString(searchText) { (channels, error) in
            self.searchTask = nil
            if let channels = channels {
                self.channels = channels
                performUIUpdatesOnMain {
                    self.channelTableView.reloadData()
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

// MARK: CollectionView Delegate Methods

//extension SearchViewController : UICollectionViewDelegate, UICollectionViewDataSource{
//
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return channels.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cellReuseId = "ChannelSearchCell"
//        var channel = channels[(indexPath as NSIndexPath).row]
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseId, for: indexPath) as! SearchResultCell
//
//        if channel.urlData == nil {
//            DispatchQueue.main.async {
//                let image = try! UIImage(data: Data(contentsOf: URL(string: channel.urlString!)!))
//                channel.urlData = UIImagePNGRepresentation(image!)
//
//                performUIUpdatesOnMain {
//                    cell.channelImage?.image = image
//                }
//            }
//
//        } else {
//            let image = UIImage(data: (channel.urlData)!)
//            cell.channelImage?.image = image
//        }
//        cell.channelTitle?.text = channel.title
//        cell.channelDescription?.text = channel.description
//        return cell
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let cellsAcross: CGFloat = 3
//        let spaceBetweenCells: CGFloat = 10
//        let dim = (collectionView.bounds.width - (cellsAcross - 1) * spaceBetweenCells) / cellsAcross
//        return CGSize(width: dim, height: dim)
//    }
//
//
//
//}

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
        var channel = channels[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellResuseId) as? SearchResultsCell

        cell?.channelTitle?.text = channel.channelTitle
        cell?.channelDescription?.text = channel.channelDescription
        cell?.channelDescription?.numberOfLines = 2

        if channel.channelThumbnailImageData == nil {
            DispatchQueue.main.async {
                let image = try! UIImage(data: Data(contentsOf: URL(string: channel.channelThumbnailURLString!)!))
                channel.channelThumbnailImageData = UIImagePNGRepresentation(image!)

                performUIUpdatesOnMain {
                    cell?.channelImage?.image = image
                }
            }

        } else {
            let image = UIImage(data: (channel.channelThumbnailImageData)!)
            cell?.channelImage?.image = image
        }
        
//        cell?.subscribeButton.tag = indexPath.row
//        cell?.subscribeButton.addTarget(self, action: (Selector(("subscribeToChannel"))), for: .touchUpInside)

        return cell!

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Implment this method
//        let channel = channels[(indexPath as NSIndexPath).row]
//        let controller = storyboard?.instantiateViewController(withIdentifier: "VideoListViewController") as! VideoListViewController
//        controller.channel = channel
//        controller.dataController = self.dataController
//        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func subscribeToChannel(sender: UIButton){
        let buttonTag = sender.tag
        let thisChannel = channels[buttonTag]
        //var cdChannel = [Channel]()
        
        let fetchRequest:NSFetchRequest<Channel> = Channel.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "channelTitle", ascending: true)
        fetchRequest.sortDescriptors=[sortDescriptor]
        let predicate = NSPredicate(format: "channelTitle == %@", thisChannel.channelTitle!)
        fetchRequest.predicate = predicate
        
        if let results = try? dataController.viewContext.fetch(fetchRequest) {
            
            guard results.count != 0 else {
                let savedChannel = Channel(context: dataController.viewContext)
                savedChannel.channelTitle = thisChannel.channelTitle
                savedChannel.channelID = thisChannel.channelID
                savedChannel.channelDescription = thisChannel.channelDescription
                savedChannel.channelThumbnailURL = thisChannel.channelThumbnailURLString
                savedChannel.channelThumbnailData = thisChannel.channelThumbnailImageData
                //savedChannel.channelToCategory = thisChannel.channelToCategory
                try? dataController.viewContext.save()
                print("you're ready to cancel!!!")
                return
            }
            if results[0].channelTitle == thisChannel.channelTitle {
                dataController.viewContext.delete(results[0])
                try? dataController.viewContext.save()
                print("you're ready to subscribe!!!")
            } else {
                let savedChannel = Channel(context: dataController.viewContext)
                savedChannel.channelTitle = thisChannel.channelTitle
                savedChannel.channelID = thisChannel.channelID
                savedChannel.channelDescription = thisChannel.channelDescription
                savedChannel.channelThumbnailURL = thisChannel.channelThumbnailURLString
                savedChannel.channelThumbnailData = thisChannel.channelThumbnailImageData
                //savedChannel.channelToCategory = thisChannel.channelToCategory
                try? dataController.viewContext.save()
                print("you're ready to cancel!!!")
            }
        }
    }
}


extension SearchViewController : CoreDataClient {
    func setStack(stack: DataController) { 
        self.dataController = stack
    }
}


//extension SearchViewController: SearchCellLayoutDelegate {
//    func collectionView(_ collectionView: UICollectionView,
//                        heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
//
//        return channels[indexPath.item].image.size.height
//    }
//}
