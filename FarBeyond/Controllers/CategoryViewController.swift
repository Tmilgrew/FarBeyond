//
//  CategoryViewController.swift
//  FarBeyond
//
//  Created by Thomas Milgrew on 3/28/18.
//  Copyright © 2018 Thomas Milgrew. All rights reserved.
//

import Foundation
import UIKit
import CoreData
//import GoogleSignIn

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    //@IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var categories: [YouTubeCategory] = []
    var dataController: DataController!

    
    // MARK: - Outlets
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Inject the dataController into all viewControllers in the MainTabBarController
        //*************************************************************************************
//        if let tab = self.tabBarController as? MainTabBarController {
//            for child in (tab.viewControllers as? [UINavigationController]) ?? []
//            {
//                let viewController = child.viewControllers.first
//                if let top = viewController as? CoreDataClient {
//                    top.setStack(stack: appDelegate.dataController)
//                }
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = categoryTableView.indexPathForSelectedRow {
            self.categoryTableView.deselectRow(at: indexPath, animated: false)
        }
        

        categoryTableView.dataSource = self

        if categories.count == 0 {
            callGetCategories()
        }
    }
    
    func callGetCategories(){
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        YouTubeClient.sharedInstance().getCategories(){(results, error) in
            
            guard error == nil else {
                self.showAlert()
                performUIUpdatesOnMain {
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
                return
            }

            for item in results! {
                var category = YouTubeCategory()
                category.id = item[YouTubeClient.JSONBodyResponse.Id] as? String
                
                if let snippet = item[YouTubeClient.JSONBodyResponse.Snippet] as? [String:AnyObject] {
                    category.name = snippet[YouTubeClient.JSONBodyResponse.Title] as? String
                }
                self.categories.append(category)
            }
            

            performUIUpdatesOnMain {
                self.categoryTableView.reloadData()
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
            }
        }
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
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushToChannels"{
            if let controller = segue.destination as? CategoryChannelViewController {
                controller.category = categories[(categoryTableView.indexPathForSelectedRow! as NSIndexPath).row] 
                controller.dataController = self.dataController
            }
        }
    }
}

// MARK:  TableView Delegate Methods
extension CategoryViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aCategory = categories[(indexPath as NSIndexPath).row]
        let cellReuseIdentifier = "CategoryTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)
        
        cell?.textLabel?.text = aCategory.name
        
        return cell!
    }
    

}

extension CategoryViewController : CoreDataClient {
    func setStack(stack: DataController) {
        self.dataController = stack
    }
}


