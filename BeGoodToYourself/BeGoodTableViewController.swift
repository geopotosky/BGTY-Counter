//
//  BeGoodTableViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 9/19/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//

import UIKit
import CoreData


class BeGoodTableViewController: UIViewController, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var events: [Events]!
    //    var memes: Memes!
    var eventIndex: Int!
    var eventIndexPath: NSIndexPath!
    var editEventFlag: Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addEvent")
        
        //self.tabBarController?.tabBar.hidden = false
        
        
        fetchedResultsController.performFetch(nil)
        
        // Set the view controller as the delegate
        fetchedResultsController.delegate = self
        
    }
    
    
    //Perform when view appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.hidden = false
        
        //Get shared model info
                let object = UIApplication.sharedApplication().delegate
                let appDelegate = object as! AppDelegate
                events = appDelegate.events
        
        //Brute Force Reload the scene to view table updates
        self.tableView.reloadData()

        
    }
    
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
    
    
    //* - GEO: Add the "sharedContext" convenience property
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    
    // Mark: - Fetched Results Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Events")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "textEvent", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
        }()
    
    
    
    //* - Configure Cell
    
    func configureCell(cell: UITableViewCell, withEvent event: Events) {
        
        let eventImage2 = event.eventImage
        let finalImage = UIImage(data: eventImage2!)
        
        cell.textLabel!.text = event.textEvent
        cell.imageView!.image = finalImage
        println("show table event")
        
    }
    
    
    
    //function - Table View Data Source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        
//        //Check to see if you have any events. If not, go directly to the Edit Screen.
//        if sectionInfo.numberOfObjects == 0 {
//            
//            let actionSheetController: UIAlertController = UIAlertController(title: "Zippo!", message: "No Events. Press OK to create an Event", preferredStyle: .Alert)
//            
//            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
//                
//                let storyboard = self.storyboard
//                let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BeGoodAddEventViewController") as! BeGoodAddEventViewController
//                controller.editEventFlag = false
//                self.presentViewController(controller, animated: true, completion: nil)
//            }
//            actionSheetController.addAction(okAction)
//            
//            //Present the AlertController
//            self.presentViewController(actionSheetController, animated: true, completion: nil)
//        }
//        
        return sectionInfo.numberOfObjects
        
    }
    
    //Set the table view cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let CellIdentifier = "BeGoodTableCell"
        
        // Here is how to replace the actors array using objectAtIndexPath
        let event = fetchedResultsController.objectAtIndexPath(indexPath) as! Events
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! UITableViewCell
        
        // This is the new configureCell method
        configureCell(cell, withEvent: event)
        
        return cell
    }
    
    
    //If a table entry is selected, pull up the Meme Details page and display the selected Meme
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let controller =
        storyboard!.instantiateViewControllerWithIdentifier("BeGoodShowViewController") as! BeGoodShowViewController
        // Similar to the method above
        let event = fetchedResultsController.objectAtIndexPath(indexPath) as! Events
        
        controller.events = self.events
        controller.eventIndexPath = indexPath
        controller.eventIndex = indexPath.row
        //controller.memedImage = meme.memedImage
        //controller.memedImage3 = meme.memedImage
        
        self.navigationController!.pushViewController(controller, animated: true)
        //self.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            
            switch (editingStyle) {
            case .Delete:
                
                // Here we get the actor, then delete it from core data
                let event = fetchedResultsController.objectAtIndexPath(indexPath) as! Events
                sharedContext.deleteObject(event)
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
                let cell = tableView.cellForRowAtIndexPath(indexPath!) as UITableViewCell?
                let event = controller.objectAtIndexPath(indexPath!) as! Events
                self.configureCell(cell!, withEvent: event)
                
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
    
    
    //Button Function - Create a New EVent
    //@IBAction func memeEditButton(sender: UIBarButtonItem) {
    func addEvent(){
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BeGoodAddEventViewController") as! BeGoodAddEventViewController
        controller.editEventFlag = false
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
}

