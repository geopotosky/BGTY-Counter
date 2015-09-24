//
//  BeGoodShowViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 9/19/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//


import UIKit
import CoreData


class BeGoodShowViewController : UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var textFieldEvent: UILabel!
    @IBOutlet weak var deleteEventButton: UIBarButtonItem!
    
    //var memedImage : UIImage!
    var events: [Events]!
    //    var events: Events!
    var eventIndex:Int!
    var eventIndexPath: NSIndexPath!
    //var memedImage: NSData!
    //    var memedImage2: NSData!
    //    var memedImage3: NSData!
    
    var editEventFlag: Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get shared model info
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        events = appDelegate.events
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "editEvent")
        
        //* - Hide the Tab Bar
        self.tabBarController?.tabBar.hidden = true
        
//        let b1 = UIBarButtonItem(barButtonSystemItem: .Trash, target: self,  action: "deleteMeme")
//        let b2 = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editMeme")
//        let buttons = [b1, b2] as NSArray
//        self.navigationItem.rightBarButtonItems = [b1, b2]
        
        fetchedResultsController.performFetch(nil)
        
        // Set the view controller as the delegate
        fetchedResultsController.delegate = self
        
        //        //println("memes.count: \(memes.count)")
        //        println("memeIndex: \(memeIndex)")
        //        println("memeIndexPath: \(memeIndexPath)")
        //        println("editEventFlag: \(editEventFlag)")
        
        
    }
    
    //Perform when view appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        println("BeGoodShowVC viewWillAppear")
        
        
        //println("memes.count: \(memes.count)")
//        println("memeIndex: \(memeIndex)")
//        println("memeIndexPath: \(memeIndexPath)")
//        println("editEventFlag: \(editEventFlag)")
        
        //Get shared model info
        //        let object = UIApplication.sharedApplication().delegate
        //        let appDelegate = object as! AppDelegate
        //        memes = appDelegate.memes
        
        let event = fetchedResultsController.objectAtIndexPath(eventIndexPath) as! Events
        
        println(event.textEvent)
        
        var dateFormatter = NSDateFormatter()
        
        //let date = NSDate()
        let date = event.eventDate
        let timeZone = NSTimeZone(name: "Local")
        
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateNew = dateFormatter.stringFromDate(date!)
        
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
        dateFormatter.timeZone = NSTimeZone()
        println(dateFormatter.timeZone)
        
        let localDate = dateFormatter.stringFromDate(date!)
        //let strDate = dateFormatter.stringFromDate(myDatePicker.date)
        self.eventDate.text = localDate
        
        
        let finalImage = UIImage(data: event.eventImage!)
        self.imageView!.image = finalImage
        self.textFieldEvent.text = event.textEvent
        
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
    
    
    func editEvent(){
        println("Getting ready to edit the Event")
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BeGoodAddEventViewController") as! BeGoodAddEventViewController
//
//        //controller.memes = memes[index]
//        //controller.memes = self.memes
//        
        controller.eventIndexPath2 = eventIndexPath
        controller.eventIndex2 = eventIndex
        controller.editEventFlag = true
//
//        //controller.memedImage2 = meme.memedImage
//        
//        self.presentViewController(controller, animated: true, completion: nil)
//        //self.navigationController!.pushViewController(controller, animated: true)
//        
//        //        let controller =
//        //        controller.memeIndexPath2 = memeIndexPath
//        //        controller.memeIndex2 = memeIndex
//        //        controller.editEventFlag = true
        self.navigationController!.pushViewController(controller, animated: true)
//
    }
    
    
    //function - Delete the selected meme

    @IBAction func deleteEvent(sender: UIBarButtonItem) {
    //func deleteEvent(){
        println("delete button pushed.")
        
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Warning!", message: "Do you really want to Delete the Event and it's ToDo List?", preferredStyle: .Alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        actionSheetController.addAction(cancelAction)
        
        //Create and add the Delete Meme action
        let deleteAction: UIAlertAction = UIAlertAction(title: "Delete Meme", style: .Default) { action -> Void in
            let object = UIApplication.sharedApplication().delegate
            let appDelegate = object as! AppDelegate
            println(self.eventIndex)
            //appDelegate.memes.removeAtIndex(self.memeIndex)
            
            let event = self.fetchedResultsController.objectAtIndexPath(self.eventIndexPath) as! Events
            self.sharedContext.deleteObject(event)
            
            CoreDataStackManager.sharedInstance().saveContext()
            
            //appDelegate.memes.removeAtIndex(self.memeIndex)
            self.navigationController!.popViewControllerAnimated(true)
        }
        actionSheetController.addAction(deleteAction)
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
}

