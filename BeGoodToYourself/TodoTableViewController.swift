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
    
    var events: Events!
    var eventIndexPath2: NSIndexPath!
    var eventIndex: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-Create buttons
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addTodoList")
        
        let b1 = self.editButtonItem()
        let b2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addTodoList")
        let buttons = [b2, b1] as NSArray
        self.navigationItem.rightBarButtonItems = [b2, b1]
        
        
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
        
    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
//
//    }
    
    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
    
    
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete method implementation.
//        // Return the number of rows in the section.
//        return models.count
//    }
    
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    //-Fetch the Todo List data
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
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let CellIdentifier = "todoTableCell"
            
            let todos = fetchedResultsController.objectAtIndexPath(indexPath) as! TodoList
            
            let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as!
            UITableViewCell
            
            configureCell(cell, withList: todos)
            
            return cell
    }
    

    override func tableView(tableView: UITableView,
        commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            
            switch (editingStyle) {
            case .Delete:
                
                //-Here we get the Todo List item, then delete it from core data
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
    
    //
    // This is the most interesting method. Take particular note of way the that newIndexPath
    // parameter gets unwrapped and put into an array literal: [newIndexPath!]
    //
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
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
                
            default:
                return
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    
    func configureCell(cell: UITableViewCell, withList todos: TodoList) {

        cell.textLabel?.text = todos.todoListText
        
    }
    
    
    //-Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "edit" {
            
            var path = tableView.indexPathForSelectedRow()
            var detailViewController = segue.destinationViewController as! TodoEditTableViewController
            
            detailViewController.events = self.events
            detailViewController.todosIndexPath = path
            detailViewController.todosIndex = path?.row
            
        }
    }
    
    //-Add Todo List item function
    func addTodoList(){
        println("Add to List")

        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("TodoAddTableViewController") as! TodoAddTableViewController
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func editToMainViewController (segue:UIStoryboardSegue) {
        
        let detailViewController = segue.sourceViewController as! TodoEditTableViewController
        
        let todos = fetchedResultsController.objectAtIndexPath(tableView.indexPathForSelectedRow()!) as! TodoList
        todos.todoListText = detailViewController.editedModel!
        self.sharedContext.refreshObject(todos, mergeChanges: true)
        CoreDataStackManager.sharedInstance().saveContext()
        
        tableView.reloadData()
        
    }
    
    @IBAction func saveToMainViewController (segue:UIStoryboardSegue) {
        
        let detailViewController = segue.sourceViewController as! TodoAddTableViewController
        let listText = detailViewController.editedModel
        
        let todos = TodoList(todoListText:  listText, context: self.sharedContext)
        todos.events = self.events
        CoreDataStackManager.sharedInstance().saveContext()
        
        tableView.reloadData()
        
    }
    
}

