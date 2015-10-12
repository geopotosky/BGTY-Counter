//
//  TodoEditTableViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 9/30/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//


import UIKit
import CoreData

class TodoEditTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet weak var editModelTextField: UITextField!
    
    var events: Events!
    
    var todosIndexPath: NSIndexPath!
    var todosIndex: Int!
    
    var editedModel:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController.performFetch(nil)
        
        fetchedResultsController.delegate = self
        
        let todos = fetchedResultsController.objectAtIndexPath(todosIndexPath) as! TodoList
        editModelTextField.text = todos.todoListText
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "TodoList")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "todoListText", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "events == %@", self.events);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
        }()
    
    
    //-Table view data source
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            editModelTextField.becomeFirstResponder()
            //editTextField.becomeFirstResponder()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    

    //-Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "saveDataEdit" {
            editedModel = editModelTextField.text
            println("Edit Save button pushed.")
            println(editedModel)
        }
        //editedModel = editModelTextField.text
        
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    
    
}



