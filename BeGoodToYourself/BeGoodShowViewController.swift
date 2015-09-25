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
    
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var textFieldEvent: UILabel!
    @IBOutlet weak var deleteEventButton: UIBarButtonItem!
    @IBOutlet weak var editEventButton: UIBarButtonItem!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var untilEventText: UILabel!
    @IBOutlet weak var untilEventSelector: UISegmentedControl!
    
    var events: [Events]!
    //    var events: Events!
    var eventIndex:Int!
    var eventIndexPath: NSIndexPath!
    var editEventFlag: Bool!
    
    var timeAtPress = NSDate()
    var currentDateWithOffset = NSDate()
    var count: Int!
    //var count = 180
    //var eventText: String!
    var pickEventDate: NSDate!
    var tempEventDate: NSDate!
    
    var durationSeconds: Int!
    var durationMinutes: Int!
    var durationHours: Int!
    var durationDays: Int!
    var durationWeeks: Int!
    var durationMonths: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get shared model info
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        events = appDelegate.events
        
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "editEvent")
        
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
        
        //-Countdown Timer routine
        var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
        
        //-Call the "Until Date" selector method
        segmentPicked(untilEventSelector)
        
    }
    
    //Perform when view appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        println("BeGoodShowVC viewWillAppear")
        
        //println("memes.count: \(memes.count)")
        println("eventIndex: \(eventIndex)")
        println("eventIndexPath: \(eventIndexPath)")
        println("editEventFlag: \(editEventFlag)")
        
        //Get shared model info
        //        let object = UIApplication.sharedApplication().delegate
        //        let appDelegate = object as! AppDelegate
        //        memes = appDelegate.memes
        
        let event = fetchedResultsController.objectAtIndexPath(eventIndexPath) as! Events
        
        println(event.textEvent)
        
        var dateFormatter = NSDateFormatter()
        
        let currentDate = NSDate()
        let date = event.eventDate
        let timeZone = NSTimeZone(name: "Local")
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateNew = dateFormatter.stringFromDate(date!)
        
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
        dateFormatter.timeZone = NSTimeZone()
        println(dateFormatter.timeZone)
        
        self.currentDateLabel.text = dateFormatter.stringFromDate(currentDate)
        let localDate = dateFormatter.stringFromDate(date!)
        self.eventDate.text = localDate
        
        let finalImage = UIImage(data: event.eventImage!)
        self.imageView!.image = finalImage
        self.textFieldEvent.text = event.textEvent

        //-Setup Countdown Ticker values
        let pickerDate = event.eventDate
        let elapsedTime = pickerDate!.timeIntervalSinceDate(timeAtPress)  //* Event Date in seconds raw
        durationSeconds = Int(elapsedTime)
        durationMinutes = durationSeconds / 60
        durationHours = (durationSeconds / 60) / 60
        durationDays = ((durationSeconds / 60) / 60) / 24
        durationWeeks = (((durationSeconds / 60) / 60) / 24) / 7
        
        //-Disable Segment button if value = 0
        if durationWeeks == 0 {
            untilEventSelector.setEnabled(false, forSegmentAtIndex: 0)
            untilEventSelector.setEnabled(false, forSegmentAtIndex: 1)
        }
        if durationDays == 0 {
            untilEventSelector.setEnabled(false, forSegmentAtIndex: 2)
        }
        if durationHours == 0 {
            untilEventSelector.setEnabled(false, forSegmentAtIndex: 3)
        }
        if durationMinutes == 0 {
            untilEventSelector.setEnabled(false, forSegmentAtIndex: 4)
        }
        //-Set the default segment value (days)
        let tempText1 = String(stringInterpolationSegment: self.durationDays)
        untilEventText.text = ("Only \(tempText1) Days")
        
        //-Set the duration count in seconds which will be used in the countdown calculation
        count = durationSeconds
    }
    
    
    //-Add the "sharedContext" convenience property
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    
    //-Fetched Results Controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Events")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "textEvent", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
        }()
    @IBAction func segmentPicked(sender: UISegmentedControl) {
        
        switch untilEventSelector.selectedSegmentIndex {

        case 0:
            println("Zero")
            let tempText1 = String(stringInterpolationSegment: self.durationWeeks)
            untilEventText.text = ("Only \(tempText1) Months")
        case 1:
            println("One")
            let tempText1 = String(stringInterpolationSegment: self.durationWeeks)
            untilEventText.text = ("Only \(tempText1) Weeks")
        case 2:
            println("Two")
            let tempText1 = String(stringInterpolationSegment: self.durationDays)
            untilEventText.text = ("Only \(tempText1) Days")
        case 3:
            println("Three")
            let tempText1 = String(stringInterpolationSegment: self.durationHours)
            untilEventText.text = ("Only \(tempText1) Hours")
        case 4:
            println("Four")
            let tempText1 = String(stringInterpolationSegment: self.durationMinutes)
            untilEventText.text = ("Only \(tempText1) Minutes")
        case 5:
            println("Five")
            let tempText1 = String(stringInterpolationSegment: self.durationSeconds)
            untilEventText.text = ("Only \(tempText1) Seconds")
        default:
            println("Error")
            
        }

    }
    
    
    //-Edit the selected event
    @IBAction func editEvent(sender: AnyObject) {
        println("Getting ready to edit the Event")
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BeGoodAddEventViewController") as! BeGoodAddEventViewController

        controller.eventIndexPath2 = eventIndexPath
        controller.eventIndex2 = eventIndex
        controller.editEventFlag = true

        self.navigationController!.pushViewController(controller, animated: true)
//
    }
    
    
    //-Delete the selected event
    @IBAction func deleteEvent(sender: UIBarButtonItem) {
        
        println("delete button pushed.")
        
        //-Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Warning!", message: "Do you really want to Delete the Event and it's ToDo List?", preferredStyle: .Alert)
        
        //-Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        actionSheetController.addAction(cancelAction)
        
        //-Create and add the Delete Event action
        let deleteAction: UIAlertAction = UIAlertAction(title: "Delete Meme", style: .Default) { action -> Void in
            let object = UIApplication.sharedApplication().delegate
            let appDelegate = object as! AppDelegate
            println(self.eventIndex)
            
            let event = self.fetchedResultsController.objectAtIndexPath(self.eventIndexPath) as! Events
            self.sharedContext.deleteObject(event)
            
            CoreDataStackManager.sharedInstance().saveContext()

            self.navigationController!.popViewControllerAnimated(true)
        }
        actionSheetController.addAction(deleteAction)
        
        //-Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    
    //-Countdown Time Viewer
    func update() {
        
        if(count > 0)
        {
            count = count - 1
            let minutes:Int = (count / 60)
            let hours:Int = ((count / 60) / 60) % 24
            let days:Int = ((count / 60) / 60) / 24
            let seconds:Int = count - (minutes * 60)
            let minutes2:Int = (count / 60) % 60
            
            let timerOutput = String(format: "%5d Days %2d:%2d:%02d", days, hours, minutes2, seconds) as String
            countDownLabel.text = timerOutput as String
            //CountDownDescription.text = eventText
        }
        
    }
    
}

