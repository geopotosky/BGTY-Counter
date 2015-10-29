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
    @IBOutlet weak var eventImageView: UIImageView!
    
    var events = [Events]()
    
    var eventIndex: Int!
    var eventIndexPath: NSIndexPath!
    
    //-Flag passed to determine editing function (add or edit). This flag allows reuse of the AddEvent view
    var editEventFlag: Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addEvent")
        
        
        //-Manage Top and Bottom bar colors
        //-Green Bars
        self.navigationController!.navigationBar.barTintColor = UIColor(red:0.66,green:0.97,blue:0.59,alpha:1.0)
        self.tabBarController?.tabBar.barTintColor = UIColor(red:0.66,green:0.97,blue:0.59,alpha:1.0)
        
        fetchedResultsController.performFetch(nil)
        
        //-Set the view controller as the delegate
        fetchedResultsController.delegate = self
        
        
        //-Unarchive the event when the list is first shown
        self.events = NSKeyedUnarchiver.unarchiveObjectWithFile(eventsFilePath) as? [Events] ?? [Events]()
        println("self.events: \(self.events)")
        
    }
    
    
    //-Perform when view appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.hidden = false
        
        //-Archive the graph any time this list of events is displayed.
        NSKeyedArchiver.archiveRootObject(self.events, toFile: eventsFilePath)
        
        //-Brute Force Reload the scene to view table updates
        self.tableView.reloadData()

        
    }
    
    
    //-Reset the Table Edit view when the view disappears
    override func viewWillDisappear(animated: Bool) {
        
        resetEditing(false, animated: false)
       
    }
    
    //-Set Table Editing
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
        println("Edit pushed")
    }
    
    
    //-Reset the Table Edit view when the view disappears
    func resetEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }

    
    
    //-Add the "sharedContext" convenience property
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
//    func layoutSubviews(){
//        super .layoutsubviews()
//        self.imageView.frame = CGRectMake(0,0,32,32)
//    }
    
    
    
    //-Fetched Results Controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Events")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "eventDate", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
        }()
    
    
    //-Configure Cell
    
    func configureCell(cell: UITableViewCell, withEvent event: Events) {
        
        //-Format the Date for the cell
        var dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
        dateFormatter.timeZone = NSTimeZone()
        
        //-Set the cell values for the event
        let eventImage2 = event.eventImage
        let finalImage = UIImage(data: eventImage2!)
        cell.textLabel!.text = event.textEvent
        cell.detailTextLabel!.text = dateFormatter.stringFromDate(event.eventDate!)
        cell.imageView!.image = finalImage
        
        //-Lock the table image size to 50x50
        var itemSize: CGSize = CGSizeMake(50, 50)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, CGFloat())
        var imageRect: CGRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height)
        cell.imageView!.image!.drawInRect(imageRect)
        cell.imageView!.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
    }
    
    
    
    //-Table View Data Source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        
//        //-Check to see if you have any events. If not, go directly to the Add Event Screen.
//        if sectionInfo.numberOfObjects == 0 {
//            
//            let actionSheetController: UIAlertController = UIAlertController(title: "Zippo!", message: "No Events. Press OK to create an Event", preferredStyle: .Alert)
//            
//            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
//                
//                //let storyboard = self.storyboard
//                let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BeGoodAddEventViewController") as! BeGoodAddEventViewController
//                controller.editEventFlag = false
//                //self.presentViewController(controller, animated: true, completion: nil)
//                self.navigationController!.pushViewController(controller, animated: true)
//            }
//            actionSheetController.addAction(okAction)
//            
//            //-Present the AlertController
//            self.presentViewController(actionSheetController, animated: true, completion: nil)
//            
//        }
        
        return sectionInfo.numberOfObjects
        
    }
    
    //-Set the table view cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let CellIdentifier = "BeGoodTableCell"
        
        let event = fetchedResultsController.objectAtIndexPath(indexPath) as! Events
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! UITableViewCell
        
        //-This is the new configureCell method
        configureCell(cell, withEvent: event)
        
        return cell
    }
    
    
    //-If a table entry is selected, pull up the Event Details page
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let controller =
        storyboard!.instantiateViewControllerWithIdentifier("BeGoodShowViewController") as! BeGoodShowViewController

        let event = fetchedResultsController.objectAtIndexPath(indexPath) as! Events

        controller.eventIndexPath = indexPath
        controller.eventIndex = indexPath.row
        
        self.navigationController!.pushViewController(controller, animated: true)
        //self.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {

            switch (editingStyle) {
            case .Delete:
                
                //-Here we get the event, then delete it from core data
                let event = fetchedResultsController.objectAtIndexPath(indexPath) as! Events
                sharedContext.deleteObject(event)
                CoreDataStackManager.sharedInstance().saveContext()

                //-Update the Archive any time this list of events is displayed.
                NSKeyedArchiver.archiveRootObject(self.events, toFile: eventsFilePath)
                
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
    
    
    //-Create a New EVent
    func addEvent(){
        //let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BeGoodAddEventViewController") as! BeGoodAddEventViewController
        controller.editEventFlag = false
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    
    //-Saving the array Helper.
    var eventsFilePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        println(url.URLByAppendingPathComponent("events").path!)
        return url.URLByAppendingPathComponent("events").path!
    }
    
}

