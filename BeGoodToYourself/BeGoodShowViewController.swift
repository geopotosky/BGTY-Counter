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
    @IBOutlet weak var mgFactorButon: UIButton!
    @IBOutlet weak var mgFactorLabel: UILabel!
    
    
    var events: [Events]!
    //var events: Events!
    
    //    var events: Events!
    var eventIndex:Int!
    var eventIndexPath: NSIndexPath!
    var editEventFlag: Bool!
    var mgFactorValue: Int! = 0
    
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
//        let object = UIApplication.sharedApplication().delegate
//        let appDelegate = object as! AppDelegate
//        events = appDelegate.events
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addTodoList")
        
        //* - Hide the Tab Bar
        self.tabBarController?.tabBar.hidden = true
        
//        let b1 = UIBarButtonItem(barButtonSystemItem: .Trash, target: self,  action: "deleteMeme")
//        let b2 = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editMeme")
//        let buttons = [b1, b2] as NSArray
//        self.navigationItem.rightBarButtonItems = [b1, b2]
        
        
        fetchedResultsController.performFetch(nil)
        
        // Set the view controller as the delegate
        fetchedResultsController.delegate = self
        
        
        
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
        
        let event = fetchedResultsController.objectAtIndexPath(eventIndexPath) as! Events
        
        println(event.textEvent)
        
        var dateFormatter = NSDateFormatter()
        
        let currentDate = NSDate()
        let date = event.eventDate
        let timeZone = NSTimeZone(name: "Local")
        dateFormatter.timeZone = timeZone
        //dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateNew = dateFormatter.stringFromDate(date!)
        
        //dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle //Set date style
        dateFormatter.timeZone = NSTimeZone()
        println(dateFormatter.timeZone)
        
        self.currentDateLabel.text = dateFormatter.stringFromDate(currentDate)
        let localDate = dateFormatter.stringFromDate(date!)
        self.eventDate.text = "Event Date: " + localDate
    
        let finalImage = UIImage(data: event.eventImage!)
        self.imageView!.image = finalImage
        self.textFieldEvent.text = "until " + event.textEvent!

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
        }
        if durationDays == 0 {
            untilEventSelector.setEnabled(false, forSegmentAtIndex: 1)
        }
        if durationHours == 0 {
            untilEventSelector.setEnabled(false, forSegmentAtIndex: 2)
        }
        if durationMinutes == 0 {
            untilEventSelector.setEnabled(false, forSegmentAtIndex: 3)
        }
        
        //-Set the default segment value (days)
        let tempText1 = String(stringInterpolationSegment: self.durationDays)
        
        //-Check for end of event
        if tempText1 == "-1" {
            untilEventText.text = "ZERO Days"
        } else {
            
            untilEventText.text = ("Only \(tempText1) Days")
        }
        
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
            let tempText1 = String(stringInterpolationSegment: self.durationWeeks)
            untilEventText.text = ("Only \(tempText1) Weeks")
        case 1:
            let tempText1 = String(stringInterpolationSegment: self.durationDays)
            untilEventText.text = ("Only \(tempText1) Days")
        case 2:
            let tempText1 = String(stringInterpolationSegment: self.durationHours)
            untilEventText.text = ("Only \(tempText1) Hours")
        case 3:
            let tempText1 = String(stringInterpolationSegment: self.durationMinutes)
            untilEventText.text = ("Only \(tempText1) Minutes")
        case 4:
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
            untilCounter()
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
        else{
            countDownLabel.text = "Event Has Past"
        }
        
    }
    
    func untilCounter(){
        
        let event = fetchedResultsController.objectAtIndexPath(eventIndexPath) as! Events
        
        let pickerDate = event.eventDate
        let elapsedTime = pickerDate!.timeIntervalSinceDate(timeAtPress)  //* Event Date in seconds raw
        durationSeconds = Int(elapsedTime)
        durationSeconds = count
        durationMinutes = count / 60
        durationHours = (count / 60) / 60
        durationDays = ((count / 60) / 60) / 24
        durationWeeks = (((count / 60) / 60) / 24) / 7
        
        println(durationSeconds)
        println(durationMinutes)
        
    }
    
    
    @IBAction func mgFactor(sender: UIButton) {
        println("MG Factor Button pushed.")
        
        println("MG: \(mgFactorValue)")
        if mgFactorValue == 0 {
            mgFactorValue = 172800
            //untilEventSelector.selectedSegmentIndex = 1
            mgFactorLabel.text = "MG ON"
        }
        else {
            mgFactorValue = 0
            //untilEventSelector.selectedSegmentIndex = 1
            mgFactorLabel.text = "MG OFF"
            
        }
        
        let event = fetchedResultsController.objectAtIndexPath(eventIndexPath) as! Events
        //-Setup Countdown Ticker values
        let pickerDate = event.eventDate
        let elapsedTime = pickerDate!.timeIntervalSinceDate(timeAtPress)  //* Event Date in seconds raw
        durationSeconds = Int(elapsedTime) - mgFactorValue
        
        durationMinutes = durationSeconds / 60
        durationHours = (durationSeconds / 60) / 60
        durationDays = ((durationSeconds / 60) / 60) / 24
        durationWeeks = (((durationSeconds / 60) / 60) / 24) / 7
        
        //-Disable Segment button if value = 0
        if durationWeeks == 0 {
            untilEventSelector.setEnabled(false, forSegmentAtIndex: 0)
        }
        if durationDays == 0 {
            untilEventSelector.setEnabled(false, forSegmentAtIndex: 1)
        }
        if durationHours == 0 {
            untilEventSelector.setEnabled(false, forSegmentAtIndex: 2)
        }
        if durationMinutes == 0 {
            untilEventSelector.setEnabled(false, forSegmentAtIndex: 3)
        }
        
        //-Set the default segment value (days)
        //let tempText1 = String(stringInterpolationSegment: self.durationDays)
        
        //-Check for end of event
        //if tempText1 == "-1" {
        if self.durationDays <= 0 {
            untilEventSelector.selectedSegmentIndex = 1
            untilEventText.text = "ZERO Days"
        } else {
        
            switch untilEventSelector.selectedSegmentIndex {
            
            case 0:
                let tempText1 = String(stringInterpolationSegment: self.durationWeeks)
                untilEventText.text = ("Only \(tempText1) Weeks")
            case 1:
                let tempText1 = String(stringInterpolationSegment: self.durationDays)
                untilEventText.text = ("Only \(tempText1) Days")
            case 2:
                let tempText1 = String(stringInterpolationSegment: self.durationHours)
                untilEventText.text = ("Only \(tempText1) Hours")
            case 3:
                let tempText1 = String(stringInterpolationSegment: self.durationMinutes)
                untilEventText.text = ("Only \(tempText1) Minutes")
            case 4:
                let tempText1 = String(stringInterpolationSegment: self.durationSeconds)
                untilEventText.text = ("Only \(tempText1) Seconds")
            default:
                println("Error")
            
            }
        }
    
        //-Set the duration count in seconds which will be used in the countdown calculation
        count = durationSeconds

    }
    
    
    
    func addTodoList(){
        println("Show: Add To Do List button pushed")
        
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("TodoTableViewController") as! TodoTableViewController
        
        let event = fetchedResultsController.objectAtIndexPath(eventIndexPath) as! Events
        
        controller.eventIndexPath2 = eventIndexPath
        //controller.events = events[eventIndex]
        println(controller.eventIndexPath2)
        
        controller.events = event
        
            
        //controller.events = self.events
        println("self.event1: \(self.events)")
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
}

