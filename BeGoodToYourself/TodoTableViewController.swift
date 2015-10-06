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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addTodoList")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        fetchedResultsController.performFetch(nil)
        
        fetchedResultsController.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
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
    
    
//    lazy var fetchedResultsController: NSFetchedResultsController = {
//        
//        let fetchRequest = NSFetchRequest(entityName: "TodoList")
//        fetchRequest.predicate = NSPredicate(format: "event == %@", self.event);
//        //fetchRequest.sortDescriptors = [NSSortDescriptor(key: "todoListText", ascending: true)]
//        fetchRequest.sortDescriptors = []
//        
//        
//        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
//            managedObjectContext: self.sharedContext,
//            sectionNameKeyPath: nil,
//            cacheName: nil)
//        
//        return fetchedResultsController
//        
//        }()
    
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
//      let event = self.fetchedResultsController.objectAtIndexPath(self.eventIndexPath2) as! Events
        
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
    
    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("todoTableCell", forIndexPath: indexPath) as! UITableViewCell
//        
//        // Configure the cell...
//        cell.textLabel?.text = models[indexPath.row]
//        
//        return cell
//    }
    
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let CellIdentifier = "todoTableCell"
            
            // Here is how to replace the actors array using objectAtIndexPath
            let todos = fetchedResultsController.objectAtIndexPath(indexPath) as! TodoList
            
            let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as!
            UITableViewCell
            
            // This is the new configureCell method
            configureCell(cell, withList: todos)
            
            return cell
    }
    
//    // This one is also fairly easy. You can get the actor in the same way as cellForRowAtIndexPath above.
//    override func tableView(tableView: UITableView,
//        didSelectRowAtIndexPath indexPath: NSIndexPath) {
//            let controller =
//            storyboard!.instantiateViewControllerWithIdentifier("MovieListViewController")
//                as! MovieListViewController
//            
//            // Similar to the method above
//            let todos = fetchedResultsController.objectAtIndexPath(indexPath) as! TodoList
//            
//            controller.todos = todos
//            
//            self.navigationController!.pushViewController(controller, animated: true)
//    }
    

    override func tableView(tableView: UITableView,
        commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            
            switch (editingStyle) {
            case .Delete:
                
                // Here we get the actor, then delete it from core data
                let todos = fetchedResultsController.objectAtIndexPath(indexPath) as! TodoList
                println("start delete process.")
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
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "edit" {
            
            var path = tableView.indexPathForSelectedRow()
            var detailViewController = segue.destinationViewController as! TodoEditTableViewController
            
            //let todos = fetchedResultsController.objectAtIndexPath(path!) as! TodoList
            detailViewController.events = self.events
            detailViewController.todosIndexPath = path
            detailViewController.todosIndex = path?.row
            
        }

        
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    
    func addTodoList(){
        println("Add to List")

        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("TodoAddTableViewController") as! TodoAddTableViewController
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func editToMainViewController (segue:UIStoryboardSegue) {
        
        let detailViewController = segue.sourceViewController as! TodoEditTableViewController
        
        //let event = self.fetchedResultsController.objectAtIndexPath(self.eventIndexPath2) as! Events
        
        let todos = fetchedResultsController.objectAtIndexPath(eventIndexPath2) as! TodoList
        todos.todoListText = detailViewController.editedModel!
        self.sharedContext.refreshObject(todos, mergeChanges: true)
        CoreDataStackManager.sharedInstance().saveContext()
        
        //let listText = detailViewController.editedModel
        //events.todos = listText

        //let index = detailViewController.index
        //let modelString = detailViewController.editedModel
        //models[index!] = modelString!
        
        tableView.reloadData()
        
    }
    
    @IBAction func saveToMainViewController (segue:UIStoryboardSegue) {
        
        let detailViewController = segue.sourceViewController as! TodoAddTableViewController
        
        //let index = detailViewController.index
        
        let modelString = detailViewController.editedModel
        let listText = detailViewController.editedModel
        
        //models.append(modelString!)
        
        //let event = self.fetchedResultsController.objectAtIndexPath(self.eventIndexPath2) as! Events
        
        let todos = TodoList(todoListText:  listText, context: self.sharedContext)
        todos.events = self.events
        CoreDataStackManager.sharedInstance().saveContext()
        
        tableView.reloadData()
        
    }
    
}

