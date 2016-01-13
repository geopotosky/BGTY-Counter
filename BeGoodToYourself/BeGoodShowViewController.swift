//
//  BeGoodShowViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 9/19/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//


import UIKit
import CoreData
import EventKit


class BeGoodShowViewController : UIViewController, NSFetchedResultsControllerDelegate {
    
    //-View Outlets
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
    @IBOutlet weak var shareEventButton: UIToolbar!
    @IBOutlet weak var eventCalendarButton: UIButton!
    @IBOutlet weak var toolbarObject: UIToolbar!
    @IBOutlet weak var secondsTickerLabel: UILabel!
    @IBOutlet weak var secondsWordLabel: UILabel!
    @IBOutlet weak var minutesTickerLabel: UILabel!
    @IBOutlet weak var minutesWordLabel: UILabel!
    @IBOutlet weak var hoursTickerLabel: UILabel!
    @IBOutlet weak var hoursWordLabel: UILabel!
    @IBOutlet weak var daysTickerLabel: UILabel!
    @IBOutlet weak var daysWordLabel: UILabel!
    @IBOutlet weak var untilEventText2: UITextField!

    //-Global objects, properties & variables
    var events: [Events]!

    var eventIndex:Int!
    var eventIndexPath: NSIndexPath!
    var editEventFlag: Bool!
    var mgFactorValue: Int! = 0
    var shareEventImage: UIImage!
    
    var timeAtPress = NSDate()
    var currentDateWithOffset = NSDate()
    var count: Int!
    var pickEventDate: NSDate!
    var tempEventDate: NSDate!
    
    var durationSeconds: Int!
    var durationMinutes: Int!
    var durationHours: Int!
    var durationDays: Int!
    var durationWeeks: Int!
    var durationMonths: Int!
    
    //-Alert variable
    var alertMessage: String!
    var alertTitle: String!
    
    //-Event Font Attributes
    let eventTextAttributes = [
        NSStrokeColorAttributeName : UIColor.whiteColor(),
        NSForegroundColorAttributeName : UIColor.blackColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-Bold", size: 26)!,
        NSStrokeWidthAttributeName : -4.0
    ]
    
    
    //-Perform when view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-Change toolbar color
        self.toolbarObject?.backgroundColor = UIColor.greenColor()
        //-Hide the Tab Bar
        self.tabBarController?.tabBar.hidden = true
        //-Hide the "Event Ended" message
        countDownLabel.hidden = true
        
        //-Add font attributes
        self.untilEventText2.defaultTextAttributes = eventTextAttributes
        self.untilEventText2.textAlignment = NSTextAlignment.Center

        do {
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        
        //-Set the view controller as the delegate
        fetchedResultsController.delegate = self
        
        
        //-Start Countdown Timer routine
        var _ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
        let event = fetchedResultsController.objectAtIndexPath(eventIndexPath) as! Events
        
        //-Set the initial time values
        let pickerDate = event.eventDate
        let elapsedTime = pickerDate!.timeIntervalSinceDate(timeAtPress)  //* Event Date in seconds raw
        durationSeconds = Int(elapsedTime)
        durationMinutes = durationSeconds / 60
        durationHours = (durationSeconds / 60) / 60
        durationDays = ((durationSeconds / 60) / 60) / 24
        durationWeeks = (((durationSeconds / 60) / 60) / 24) / 7
        
        //-Call the "Until Date" selector method
        segmentPicked(untilEventSelector)
        
    }
    
    //-Perform when view will appear
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //-UnHide the main ticker
        secondsTickerLabel.hidden = false
        secondsWordLabel.hidden = false
        minutesTickerLabel.hidden = false
        minutesWordLabel.hidden = false
        hoursTickerLabel.hidden = false
        hoursWordLabel.hidden = false
        daysTickerLabel.hidden = false
        daysWordLabel.hidden = false
        countDownLabel.hidden = true
        
        //-Set Magic Wand button to OFF
        mgFactorValue = 0
        mgFactorLabel.text = "OFF"
        
        let event = fetchedResultsController.objectAtIndexPath(eventIndexPath) as! Events
        
        let dateFormatter = NSDateFormatter()
        
        //let currentDate = NSDate()
        let date = event.eventDate
        let timeZone = NSTimeZone(name: "Local")
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        //let dateNew = dateFormatter.stringFromDate(date!)
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle //Set date style
        dateFormatter.timeZone = NSTimeZone()
        
        let localDate = dateFormatter.stringFromDate(date!)
        self.eventDate.text = "Event Date: " + localDate
    
        let finalImage = UIImage(data: event.eventImage!)
        self.imageView!.image = finalImage
        self.textFieldEvent.text = "until " + event.textEvent!

        //-Call the main "until" setup routine
        untilCounterStart()

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
    
    
    //-Set the "until" dynamic text based on segment selection
    @IBAction func segmentPicked(sender: UISegmentedControl) {
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        
        switch untilEventSelector.selectedSegmentIndex {

        case 0:
            let tempText1 = numberFormatter.stringFromNumber(self.durationWeeks)!
            untilEventText2.text = ("Only \(tempText1) + Weeks")
        case 1:
            let tempText1 = numberFormatter.stringFromNumber(self.durationDays)!
            
            if self.durationDays < 2 {
                untilEventText2.text = ("Only \(tempText1) + Day")
            }
            else {
                untilEventText2.text = ("Only \(tempText1) + Days")
            }
        case 2:
            let tempText1 = numberFormatter.stringFromNumber(self.durationHours)!
            untilEventText2.text = ("Only \(tempText1) + Hours")
        case 3:
            let tempText1 = numberFormatter.stringFromNumber(self.durationMinutes)!
            untilEventText2.text = ("Only \(tempText1) + Minutes")
        case 4:
            let tempText1 = numberFormatter.stringFromNumber(self.durationSeconds)!
            untilEventText2.text = ("Only \(tempText1) Seconds")
        default:
            print("Less than 1 day left")
        }
    }
    
    
    //-Edit the selected event
    @IBAction func editEvent(sender: AnyObject) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BeGoodAddEventViewController") as! BeGoodAddEventViewController

        controller.eventIndexPath2 = eventIndexPath
        controller.eventIndex2 = eventIndex
        controller.editEventFlag = true

        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    
    //-Delete the selected event
    @IBAction func deleteEvent(sender: UIBarButtonItem) {
        
        //-Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Warning!", message: "Do you really want to Delete the Event?", preferredStyle: .Alert)
        
        //-Update alert colors and attributes
        actionSheetController.view.tintColor = UIColor.blueColor()
        let subview = actionSheetController.view.subviews.first! 
        let alertContentView = subview.subviews.first! 
        alertContentView.backgroundColor = UIColor(red:0.66,green:0.97,blue:0.59,alpha:1.0)
        alertContentView.layer.cornerRadius = 5;
        
        //-Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        actionSheetController.addAction(cancelAction)
        
        //-Create and add the Delete Event action
        let deleteAction: UIAlertAction = UIAlertAction(title: "Delete Event", style: .Default) { action -> Void in
            
            //-Get the event, then delete it from core data, delete related notifications, and remove any existing
            //-Calendar Event
            
            let event = self.fetchedResultsController.objectAtIndexPath(self.eventIndexPath) as! Events
            
            //-Delete the event notificaton
            if String(event.eventDate!) > String(NSDate()) { //...if event date is greater than the current date, remove the upcoming notification. If not, skip this routine.
                
                for notification in UIApplication.sharedApplication().scheduledLocalNotifications! as [UILocalNotification] { // loop through notifications...
                    if (notification.userInfo!["UUID"] as! String == String(event.eventDate!)) { // ...and cancel the notification that corresponds to this TodoItem instance (matched by UUID)
                        UIApplication.sharedApplication().cancelLocalNotification(notification) // there should be a maximum of one match on title
                        break
                    }
                }
            }
            
            //-Call Delete Calendar Event
            if event.textCalendarID == nil {
                print("No calendar event:", event.textCalendarID)
            } else {
                let eventStore = EKEventStore()
                let eventID = event.textCalendarID!
                let eventToRemove = eventStore.eventWithIdentifier(eventID)
                
                if (eventToRemove != nil) {
                    do {
                        try eventStore.removeEvent(eventToRemove!, span: .ThisEvent)
                    } catch {
                        print("Calender Event Removal Failed.")
                    }
                }
            }

            //-Delete Main Event
            self.sharedContext.deleteObject(event)
            CoreDataStackManager.sharedInstance().saveContext()

            self.navigationController!.popViewControllerAnimated(true)
        }
        actionSheetController.addAction(deleteAction)
        
        //-Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    
    //-Update Countdown Time Viewer
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
            
            secondsTickerLabel.text = String(format: "%02d", seconds)
            minutesTickerLabel.text = String(format: "%02d", minutes2)
            hoursTickerLabel.text = String(format: "%02d", hours)
            daysTickerLabel.text = String(days)
            
        }
        else{
            //-Hide the main ticker and show the "Event Ended" message
            secondsTickerLabel.hidden = true
            secondsWordLabel.hidden = true
            minutesTickerLabel.hidden = true
            minutesWordLabel.hidden = true
            hoursTickerLabel.hidden = true
            hoursWordLabel.hidden = true
            daysTickerLabel.hidden = true
            daysWordLabel.hidden = true
            countDownLabel.hidden = false
            
            countDownLabel.text = "Event Has Past"
        }
        
        //------------------- UNTIL TICKER -----------------------------
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        
        switch untilEventSelector.selectedSegmentIndex {
            
        case 0:
            let tempText1 = numberFormatter.stringFromNumber(self.durationWeeks)!
            if self.durationWeeks < 2 {
                untilEventText2.text = ("Only \(tempText1) + Week")
            } else {
                untilEventText2.text = ("Only \(tempText1) + Weeks")
            }
        case 1:
            let tempText1 = numberFormatter.stringFromNumber(self.durationDays)!
            if self.durationDays < 2 {
                untilEventText2.text = ("Only \(tempText1) + Day")
            } else {
                untilEventText2.text = ("Only \(tempText1) + Days")
            }
        case 2:
            let tempText1 = numberFormatter.stringFromNumber(self.durationHours)!
            if self.durationHours < 2 {
                untilEventText2.text = ("Only \(tempText1) + Hour")
            } else {
                untilEventText2.text = ("Only \(tempText1) + Hours")
            }
        case 3:
            let tempText1 = numberFormatter.stringFromNumber(self.durationMinutes)!
            if self.durationMinutes < 2 {
                untilEventText2.text = ("Only \(tempText1) + Minute")
            } else {
                untilEventText2.text = ("Only \(tempText1) + Minutes")
            }
        case 4:
            let tempText1 = numberFormatter.stringFromNumber(self.durationSeconds)!
            if self.durationSeconds < 2 {
                untilEventText2.text = ("Only \(tempText1) Second")
            } else {
                untilEventText2.text = ("Only \(tempText1) Seconds")
            }
        default:
            break
        }
        
        //-Until Counter Updater
        durationSeconds = count
        durationMinutes = count / 60
        durationHours = (count / 60) / 60
        durationDays = ((count / 60) / 60) / 24
        durationWeeks = (((count / 60) / 60) / 24) / 7
    
    }
    
    
    //-Setup the "untils" based on the current date and event date for the first time
    func untilCounterStart(){

        let event = fetchedResultsController.objectAtIndexPath(eventIndexPath) as! Events
        let pickerDate = event.eventDate
        let elapsedTime = pickerDate!.timeIntervalSinceDate(timeAtPress)  //* Event Date in seconds raw
        durationSeconds = Int(elapsedTime)
        durationMinutes = durationSeconds / 60
        durationHours = (durationSeconds / 60) / 60
        durationDays = ((durationSeconds / 60) / 60) / 24
        durationWeeks = (((durationSeconds / 60) / 60) / 24) / 7
        
        //-Disable Magic Wand button is days < 2
        if durationDays < 2 {
            mgFactorLabel.enabled = false
            mgFactorButon.enabled = false
        } else {
            mgFactorLabel.enabled = true
            mgFactorButon.enabled = true
        }
        
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
        }
        
        //-Set the duration count in seconds which will be used in the countdown calculation
        count = durationSeconds
        
        
    }
    
    
    //-The Magic Wand is a special method which removes 1 day from the front of the vacation
    //-and 1 day from the back. After all, does anybody really count those days when your planning? :-)
    @IBAction func mgFactor(sender: UIButton) {
        
        //-Set the MG Factor (172800 = 2 days in seconds) and update the button label
        if mgFactorValue == 0 {
            mgFactorValue = 172800
            mgFactorLabel.text = "ON"
        }
        else {
            mgFactorValue = 0
            mgFactorLabel.text = "OFF"
        }
        
        let event = fetchedResultsController.objectAtIndexPath(eventIndexPath) as! Events
        let pickerDate = event.eventDate
        let elapsedTime = pickerDate!.timeIntervalSinceDate(timeAtPress)  //* Event Date in seconds raw
        durationSeconds = Int(elapsedTime) - mgFactorValue
        durationMinutes = durationSeconds / 60
        durationHours = (durationSeconds / 60) / 60
        durationDays = ((durationSeconds / 60) / 60) / 24
        durationWeeks = (((durationSeconds / 60) / 60) / 24) / 7

        //-Set the duration count in seconds which will be used in the countdown calculation
        count = durationSeconds

    }

    
    //-Call the Popover Menu
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        switch(segue.identifier!){
        case "eventMenu":
            let popoverController = (segue.destinationViewController as? BeGoodPopoverViewController)
            let event = fetchedResultsController.objectAtIndexPath(eventIndexPath) as! Events
            popoverController!.eventIndexPath2 = eventIndexPath
            popoverController!.events = event
            break
        default:
            break
        }
    }
    
} //- END main class



//-Separate the Sharing and Calendar Method to better organize the code

extension BeGoodShowViewController {
    
    //-Generate the Event Image to share
    func generateEventImage() -> UIImage {
        
        //-Hide toolbar
        toolbarObject.hidden = true
        
        //-Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let shareEventImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //-UnHide toolbar
        toolbarObject.hidden = false
        
        return shareEventImage
    }
    
    
    //-Share the generated event image with other apps
    @IBAction func shareEvent(sender: UIBarButtonItem) {
        
        //-Create a event image, pass it to the activity view controller.
        self.shareEventImage = generateEventImage()
        
        let activityVC = UIActivityViewController(activityItems: [self.shareEventImage!], applicationActivities: nil)
        
        activityVC.excludedActivityTypes =  [
            UIActivityTypeSaveToCameraRoll
            //UIActivityTypePostToTwitter,
            //UIActivityTypePostToFacebook,
            //UIActivityTypePostToWeibo,
            //UIActivityTypeMessage,
            //UIActivityTypeMail,
            //UIActivityTypePrint,
            //UIActivityTypeCopyToPasteboard,
            //UIActivityTypeAssignToContact,
            //UIActivityTypeSaveToCameraRoll,
            //UIActivityTypeAddToReadingList,
            //UIActivityTypePostToFlickr,
            //UIActivityTypePostToVimeo,
            //UIActivityTypePostToTencentWeibo
        ]
        
        activityVC.completionWithItemsHandler = {
            activity, completed, items, error in
            if completed {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    

//    // Creates an event in the EKEventStore. The method assumes the eventStore is created and
//    // accessible
//    
//    func createEvent(eventStore: EKEventStore, title: String, startDate: NSDate, endDate: NSDate) {
//    //func createEvent() {
//        let event = EKEvent(eventStore: eventStore)
//        
//        
//        event.title = title
//        event.startDate = startDate
//        event.endDate = endDate
//        event.calendar = eventStore.defaultCalendarForNewEvents
//        do {
//            try eventStore.saveEvent(event, span: .ThisEvent)
//            savedEventId = event.eventIdentifier
//        } catch {
//            print("Bad things happened")
//        }
//    }
    
//    // Removes an event from the EKEventStore. The method assumes the eventStore is created and
//    // accessible
//    func deleteEvent(eventStore: EKEventStore, eventIdentifier: String) {
//        let eventToRemove = eventStore.eventWithIdentifier(eventIdentifier)
//        if (eventToRemove != nil) {
//            do {
//                try eventStore.removeEvent(eventToRemove!, span: .ThisEvent)
//            } catch {
//                print("Bad things happened")
//            }
//        }
//    }
    
//    // Responds to button to add event. This checks that we have permission first, before adding the
//    // event
//    @IBAction func addEvent(sender: UIButton) {
//        let eventStore = EKEventStore()
//        
//        let startDate = NSDate()
//        let endDate = startDate.dateByAddingTimeInterval(60 * 60) // One hour
//        
//        if (EKEventStore.authorizationStatusForEntityType(.Event) != EKAuthorizationStatus.Authorized) {
//            eventStore.requestAccessToEntityType(.Event, completion: {
//                granted, error in
//                self.createEvent(eventStore, title: "DJ's Test Event", startDate: startDate, endDate: endDate)
//            })
//        } else {
//            createEvent(eventStore, title: "DJ's Test Event", startDate: startDate, endDate: endDate)
//        }
//    }
    
    
//    // Responds to button to remove event. This checks that we have permission first, before removing the
//    // event
//    @IBAction func removeEvent(sender: UIButton) {
//        let eventStore = EKEventStore()
//        
//        if (EKEventStore.authorizationStatusForEntityType(.Event) != EKAuthorizationStatus.Authorized) {
//            eventStore.requestAccessToEntityType(.Event, completion: { (granted, error) -> Void in
//                self.deleteEvent(eventStore, eventIdentifier: self.savedEventId)
//            })
//        } else {
//            deleteEvent(eventStore, eventIdentifier: savedEventId)
//        }
//        
//    }
    
    
    
    // Responds to button to add event. This checks that we have permission first, before adding the event
    @IBAction func addCalendarEvent(sender: UIButton) {
        let eventStore = EKEventStore()
    
        let event = fetchedResultsController.objectAtIndexPath(eventIndexPath) as! Events
        
        //-Set the selected event start date & time
        let startDate = event.eventDate
        
        //-2 hours ahead for endtime
        let endDate = startDate!.dateByAddingTimeInterval(2 * 60 * 60)
    
        if (EKEventStore.authorizationStatusForEntityType(.Event) != EKAuthorizationStatus.Authorized) {
            eventStore.requestAccessToEntityType(.Event, completion: {
                granted, error in
                self.insertEvent(eventStore, startDate: startDate!, endDate: endDate)
            })
        } else {
            self.insertEvent(eventStore, startDate: startDate!, endDate: endDate)
        }
    }

    
    // Creates an event in the EKEventStore. The method assumes the eventStore is created and accessible
        func insertEvent(eventStore: EKEventStore, startDate: NSDate, endDate: NSDate) {
        //func createEvent() {
            //let event = EKEvent(eventStore: eventStore)
            
            let event = fetchedResultsController.objectAtIndexPath(eventIndexPath) as! Events
            
            //-Create Calendar Event
            let calendarEvent = EKEvent(eventStore: eventStore)
            calendarEvent.calendar = eventStore.defaultCalendarForNewEvents
            
            calendarEvent.title = event.textEvent!
            calendarEvent.startDate = startDate
            calendarEvent.endDate = endDate
            
            
            //-Set alert for 1 hour prior to Event
            let alarm = EKAlarm(relativeOffset: -3600.0)
            calendarEvent.addAlarm(alarm)
            
            do {
                try eventStore.saveEvent(calendarEvent, span: .ThisEvent)
                //-ReSave the event with the calendar Identifier
                event.textCalendarID = calendarEvent.eventIdentifier
                self.sharedContext.refreshObject(event, mergeChanges: true)
                CoreDataStackManager.sharedInstance().saveContext()
                
                
                //-Call Alert message
                self.alertTitle = "SUCCESS!"
                self.alertMessage = "Event added to your Calendar"
                self.calendarAlertMessage()
            } catch {
                print("Bad things happened")
                //-Call Alert message
                self.alertTitle = "NOTICE"
                self.alertMessage = "One of your Calendars may be restricted. Please check to see if the Calendar event is added or allow access to add events."
                self.calendarAlertMessage()
            }
        }
    
    
//    //-Authorize Calendar Event
//    @IBAction func addCalendarEvent(sender: UIButton) {
//        
//        let eventStore = EKEventStore()
//
//        switch EKEventStore.authorizationStatusForEntityType(EKEntityType.Event) {
//        case .Authorized:
//            print("authorized")
//            insertEvent(eventStore)
//        case .Denied:
//            print("Access denied")
//        case .NotDetermined:
//            
//            if (EKEventStore.authorizationStatusForEntityType(.Event) != EKAuthorizationStatus.Authorized) {
//                eventStore.requestAccessToEntityType(.Event, completion: {
//                    granted, error in
//                    self.insertEvent(eventStore)
//                })
//            } else {
//                self.insertEvent(eventStore)
//            }
//
//        default:
//            print("Case Default")
//        }
//        
//    }
    
    
//    //-Insert a new Calendar Event
//    func insertEvent(store: EKEventStore) {
//        
//        let calendars = store.calendarsForEntityType(EKEntityType.Event)
//        
//        for calendar in calendars {
//            if calendar.title == "Calendar" {
//                
//                let event = fetchedResultsController.objectAtIndexPath(eventIndexPath) as! Events
//                
//                //-Set the selected event start date & time
//                let startDate = event.eventDate
//                
//                //-2 hours ahead for endtime
//                let endDate = startDate!.dateByAddingTimeInterval(2 * 60 * 60)
//                
//                //-Create Calendar Event
//                let calendarEvent = EKEvent(eventStore: store)
//                calendarEvent.calendar = calendar
//                
//                calendarEvent.title = event.textEvent!
//                calendarEvent.startDate = startDate!
//                calendarEvent.endDate = endDate
//                
//                //-Set alert for 1 hour prior to Event
//                let alarm = EKAlarm(relativeOffset: -3600.0)
//                calendarEvent.addAlarm(alarm)
//                
//                
//                //-Save Event in Calendar
//                //let result: Bool
//                do {
//                    try store.saveEvent(calendarEvent, span: .ThisEvent)
//                    //-Call Alert message
//                    self.alertTitle = "SUCCESS!"
//                    self.alertMessage = "Event added to your Calendar"
//                    self.calendarAlertMessage()
//                } catch {
//                    //-Call Alert message
//                    self.alertTitle = "NOTICE"
//                    self.alertMessage = "One of your Calendars may be restricted. Please check to see if the Calendar event is added or allow access to add events."
//                    self.calendarAlertMessage()
//                }
//            }
//        }
//    }
    
    
    //-Alert Message function
    func calendarAlertMessage(){
        dispatch_async(dispatch_get_main_queue()) {
            let actionSheetController = UIAlertController(title: "\(self.alertTitle)", message: "\(self.alertMessage)", preferredStyle: .Alert)
            
            //-Update alert colors and attributes
            actionSheetController.view.tintColor = UIColor.blueColor()
            let subview = actionSheetController.view.subviews.first! 
            let alertContentView = subview.subviews.first! 
            alertContentView.backgroundColor = UIColor(red:0.66,green:0.97,blue:0.59,alpha:1.0)
            alertContentView.layer.cornerRadius = 5;
            
            //-Create and add the OK action
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
                
            }
            actionSheetController.addAction(okAction)
            
            //-Present the AlertController
            self.presentViewController(actionSheetController, animated: true, completion: nil)
        }
    }
}

