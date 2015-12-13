//
//  TodoTableViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 9/30/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//


import UIKit
import CoreData


class TodoTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    //-Global objects, properties & variables
    var events: Events!
    var eventIndexPath2: NSIndexPath!
    
    //-Perform when view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-Create buttons
        self.navigationController!.navigationBar.barTintColor = UIColor(red:0.66,green:0.97,blue:0.59,alpha:1.0)
        let newBackButton = UIBarButtonItem(title: "Event", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelTodoList")
        self.navigationItem.leftBarButtonItem = newBackButton
        
        let b1 = self.editButtonItem()
        let b2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addTodoList")
        //let buttons = [b2, b1] as NSArray
        self.navigationItem.rightBarButtonItems = [b2, b1]
        
        do {
            //-Call Fetch method
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        fetchedResultsController.delegate = self
        
    }
    
    
    //-Reset the Table Edit view when the view disappears
    override func viewWillDisappear(animated: Bool) {
        resetEditing(false, animated: false)
    }
    
    
    //-Force set editing toggle (delete line items)
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
    
    
    //-Reset the Table Edit view when the view disappears
    func resetEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
    
    
    //-Table view data source
    
    
    //-Add the "sharedContext" convenience property
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    //-Fetch the To Do List data
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] 
        return sectionInfo.numberOfObjects
    }
    
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let CellIdentifier = "todoTableCell"
            let todos = fetchedResultsController.objectAtIndexPath(indexPath) as! TodoList
            let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)! as
            UITableViewCell
            
            configureCell(cell, withList: todos)
            return cell
    }
    

    override func tableView(tableView: UITableView,
        commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            
            switch (editingStyle) {
            case .Delete:
                
                //-Here we get the To Do List item, then delete it from Core Data
                let todos = fetchedResultsController.objectAtIndexPath(indexPath) as! TodoList
                sharedContext.deleteObject(todos)
                CoreDataStackManager.sharedInstance().saveContext()
                
            default:
                break
            }
    }
    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    
    
    func controller(controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType) {
            
            switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                
            default:
                return
            }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
        case .Update:
            let cell = tableView.cellForRowAtIndexPath(indexPath!) as UITableViewCell!
            let todos = controller.objectAtIndexPath(indexPath!) as! TodoList
            self.configureCell(cell, withList: todos)
            
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    
    //-Display To Do List data in table scene
    func configureCell(cell: UITableViewCell, withList todos: TodoList) {
        cell.textLabel?.text = todos.todoListText
    }
    
    
    //-Save edited To Do List data
    @IBAction func editToMainViewController (segue:UIStoryboardSegue) {
        
        let detailViewController = segue.sourceViewController as! TodoEditTableViewController
        
        let todos = fetchedResultsController.objectAtIndexPath(tableView.indexPathForSelectedRow!) as! TodoList
        todos.todoListText = detailViewController.editedModel!
        self.sharedContext.refreshObject(todos, mergeChanges: true)
        
        CoreDataStackManager.sharedInstance().saveContext()
        tableView.reloadData()
        
    }
    
    
    //-Save New To Do List data
    @IBAction func saveToMainViewController (segue:UIStoryboardSegue) {
        
        let detailViewController = segue.sourceViewController as! TodoAddTableViewController
        let listText = detailViewController.editedModel
        let todos = TodoList(todoListText:  listText, context: self.sharedContext)
        todos.events = self.events
        
        CoreDataStackManager.sharedInstance().saveContext()
        tableView.reloadData()
        
    }
    
    
    //-Navigation
    
    //-Prepare for segue to next navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "edit" {
            
            let path = tableView.indexPathForSelectedRow
            let detailViewController = segue.destinationViewController as! TodoEditTableViewController
            detailViewController.events = self.events
            detailViewController.todosIndexPath = path
            
        }
    }
    
    
    //-Add To Do List item function
    func addTodoList(){

        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("TodoAddTableViewController") as! TodoAddTableViewController
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    
    //-Cancel To Do List item function
    
    func cancelTodoList(){
        let tmpController :UIViewController! = self.presentingViewController;
        self.dismissViewControllerAnimated(false, completion: {()->Void in
            tmpController.dismissViewControllerAnimated(false, completion: nil);
        });
        
    }
    
}

