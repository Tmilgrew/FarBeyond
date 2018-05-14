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
    //let categoryTableViewDelegate = CategoryViewControllerDelegate()
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    //var categoryStrings : [String]?
    //var categoryStrings = [String]()
    var categories: [YouTubeCategory] = []
    var dataController: DataController!
//    var fetchedResultsController:NSFetchedResultsController<Category>!
    
//    fileprivate func setupFetchedResultsController(){
//        let fetchRequest:NSFetchRequest<Category> = Category.fetchRequest()
//        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
//
//        fetchedResultsController.delegate = self
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {
//            fatalError("The fetch could not be performed: \(error.localizedDescription)")
//        }
//    }
    
    
    
    // MARK: - Outlets
    @IBOutlet weak var categoryTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Inject the dataController into all viewControllers in the MainTabBarController
        //*************************************************************************************
        
        if let tab = self.tabBarController as? MainTabBarController {
            for child in (tab.viewControllers as? [UINavigationController]) ?? []
            {
                let viewController = child.viewControllers.first
                if let top = viewController as? CoreDataClient {
                    top.setStack(stack: appDelegate.dataController)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = categoryTableView.indexPathForSelectedRow {
            self.categoryTableView.deselectRow(at: indexPath, animated: false)
        }
        
        
        // Setup the Fetched Results Controller
        //**************************************************************************************
        //setupFetchedResultsController()
        categoryTableView.dataSource = self
        
        //let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        //let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        //fetchRequest.sortDescriptors = [sortDescriptor]
        
        //if let result = try? dataController.viewContext.fetch(fetchRequest){
//            if result.count == 0 {
//                self.callGetCategories()
//            } else {
//                categories = result
//            }
//        }
        if categories.count == 0 {
            callGetCategories()
        }
        //categoryTableView.delegate = self
        
        // If there are zero objects for Category then get the categories
        //***************************************************************************************
        
        
            //print("\(categories)")
        
        
        
//        let fetchRequest : NSFetchRequest<Category> = Category.fetchRequest()
//
//        if let result = try? dataController.viewContext.fetch(fetchRequest) {
//            categories = result
//            categoryTableView.reloadData()
//        }
        
        
    }
    
    func callGetCategories(){
        YouTubeClient.sharedInstance().getCategories(){(results, error) in
            
            guard error == nil else {
                // TODO: Take the error and display and error message on the screen
                return
            }
            //var categoryArray = [Category]()
//            var editorCategory = [String]()
//            editorCategory.append("007")
//            editorCategory.append("Editor's Pick")
//            self.addCategory(editorCategory)
            
            //var categoryArray = [YouTubeCategory]()
            for item in results! {
                var category = YouTubeCategory()
                //let category = Category(context: self.dataController.viewContext)
                category.id = item[YouTubeClient.JSONBodyResponse.Id] as? String
                
                if let snippet = item[YouTubeClient.JSONBodyResponse.Snippet] as? [String:AnyObject] {
                    category.name = snippet[YouTubeClient.JSONBodyResponse.Title] as? String
                }
                self.categories.append(category)
                //print("------------- This is category before saving:  \(category)")
                //try? self.dataController.viewContext.save()
                //print ("------------ This is context after saving: \(self.dataController.viewContext)")
            }
            
//            let fetchRequest : NSFetchRequest<Category> = Category.fetchRequest()
//            let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
//            fetchRequest.sortDescriptors = [sortDescriptor]
//            if let result = try? self.dataController.viewContext.fetch(fetchRequest){
//                self.categories = result
//            }
            
            //print("\(String(describing: self.fetchedResultsController.fetchedObjects))")
            performUIUpdatesOnMain {
                self.categoryTableView.reloadData()
            }
        }
    }
    
//    func addCategory(_ nameAndID : [String]){
//        let category = Category(context: dataController.viewContext)
//        category.id = nameAndID[0]
//        category.name = nameAndID[1]
//        try? dataController.viewContext.save()
//        print("\(category)")
//    }
    
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
        // TODO: Configure the number of rows based on number of categories
//        print("The number of objects is \(String(describing: fetchedResultsController.sections?.count))")
//        return fetchedResultsController.sections?.count ?? 1
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let aCategory = fetchedResultsController.object(at: indexPath)
        let aCategory = categories[(indexPath as NSIndexPath).row]
        let cellReuseIdentifier = "CategoryTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)
        
        // TODO: Decorate the cell
        cell?.textLabel?.text = aCategory.name
        
        return cell!
    }
    

}

extension CategoryViewController : CoreDataClient {
    func setStack(stack: DataController) {
        self.dataController = stack
    }
}
//extension CategoryViewController:NSFetchedResultsControllerDelegate {
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            categoryTableView.insertRows(at: [newIndexPath!], with: .fade)
//            break
//        case .delete:
//            categoryTableView.deleteRows(at: [indexPath!], with: .fade)
//            break
//        case .update:
//            categoryTableView.reloadRows(at: [indexPath!], with: .fade)
//        case .move:
//            categoryTableView.moveRow(at: indexPath!, to: newIndexPath!)
//        }
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        let indexSet = IndexSet(integer: sectionIndex)
//        switch type {
//        case .insert: categoryTableView.insertSections(indexSet, with: .fade)
//        case .delete: categoryTableView.deleteSections(indexSet, with: .fade)
//        case .update, .move:
//            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
//        }
//    }
//
//
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        categoryTableView.beginUpdates()
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        categoryTableView.endUpdates()
//    }
//
//}

