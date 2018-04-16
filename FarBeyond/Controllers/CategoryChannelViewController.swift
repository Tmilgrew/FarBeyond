//
//  CategoryChannelViewController.swift
//  FarBeyond
//
//  Created by Thomas Milgrew on 4/12/18.
//  Copyright © 2018 Thomas Milgrew. All rights reserved.
//

import Foundation
import UIKit

class CategoryChannelViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    var category : String!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: Outlets
    @IBOutlet weak var channelTableView: UITableView!
    
    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        channelTableView.delegate = self
        channelTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        displayChannelsFromCategory(category)
    }
    
    // MARK: Helper Methods
    private func displayChannelsFromCategory(_ category: String){
        
        YouTubeClient.sharedInstance().getChannelsFromCategory(appDelegate.user, category){ (results, error) in
            guard error == nil else {
                // TODO: Take the error and display and error message on the screen
                return
            }
            
            self.appDelegate.channelsFromCategory = results
            print("\(self.appDelegate.channelsFromCategory)")
            performUIUpdatesOnMain {
                self.channelTableView.reloadData()
            }
        }
        
    }
}

extension CategoryChannelViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: Configure the number of rows based on number of categories
        return appDelegate.channelsFromCategory?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "ChannelTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)
        
        // TODO: Decorate the cell
        cell?.textLabel?.text = appDelegate.channelsFromCategory?[(indexPath as NSIndexPath).row].title
        cell?.detailTextLabel?.text = appDelegate.channelsFromCategory?[(indexPath as NSIndexPath).row].description
        
        
        return cell!
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let controller = storyboard!.instantiateViewController(withIdentifier: "CategoryChannelsViewController") as! CategoryChannelViewController
//        controller.category = appDelegate.category?[(indexPath as NSIndexPath).row].id
//        present(controller, animated: false, completion: nil)
//    }
}
