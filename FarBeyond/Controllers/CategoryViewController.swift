//
//  CategoryViewController.swift
//  FarBeyond
//
//  Created by Thomas Milgrew on 3/28/18.
//  Copyright © 2018 Thomas Milgrew. All rights reserved.
//

import Foundation
import UIKit

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    
    // MARK: - Properties
    //let categoryTableViewDelegate = CategoryViewControllerDelegate()
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    //var categoryStrings : [String]?
    var categoryStrings = [String]()
    
    
    // MARK: - Outlets
    @IBOutlet weak var categoryTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        
        
        YouTubeClient.sharedInstance().getCategories(appDelegate.user!){(results, error) in
            
            guard error == nil else {
                // TODO: Take the error and display and error message on the screen
                return
            }
            
            self.appDelegate.category = results
            for category in self.appDelegate.category! {
                self.categoryStrings.append(category.name)
            }
            //self.categoryTableViewDelegate.categoryStrings = results!
            performUIUpdatesOnMain {
                self.categoryTableView.reloadData()
            }
        }
    }
}

// MARK:  TableView Delegate Methods
extension CategoryViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: Configure the number of rows based on number of categories
        return appDelegate.category?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "CategoryTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)
        
        // TODO: Decorate the cell
        cell?.textLabel?.text = appDelegate.category?[(indexPath as NSIndexPath).row].name
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = storyboard!.instantiateViewController(withIdentifier: "CategoryChannelsViewController") as! CategoryChannelViewController
        controller.category = appDelegate.category?[(indexPath as NSIndexPath).row].id
        present(controller, animated: false, completion: nil)
    }
}
