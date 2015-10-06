//
//  BeGoodAddEventViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 9/19/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//

import UIKit
import CoreData


class BeGoodAddEventViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate{
    
    //Edit Screen outlets
    @IBOutlet weak var currentDate: UILabel!
    @IBOutlet weak var datePickerLable: UILabel!
    @IBOutlet weak var datePickerButton: UIButton!
    @IBOutlet weak var imageViewPicker: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var flickrButton: UIBarButtonItem!
    @IBOutlet weak var textFieldEvent: UITextField!
//    @IBOutlet weak var textFieldBottom: UITextField!
    @IBOutlet weak var toolbarObject: UIToolbar!
    @IBOutlet weak var navbarObject: UINavigationBar!
    @IBOutlet weak var saveEventButton: UIBarButtonItem!
//    @IBOutlet weak var shareMemeButton: UIBarButtonItem!
    @IBOutlet weak var cancelEventButton: UIBarButtonItem!
    
    //set the textfield delegates
    let eventTextDelegate = EventTextDelegate()
    //let bottomTextDelegate = BottomTextDelegate()
    
    //Meme variables
    var eventImage : UIImage!
    var events: Events!
    //var events: [Events]!
    
    
    var eventIndex2:Int!
    var eventIndexPath2: NSIndexPath!
    var eventImage2: NSData!
    
    var todaysDate: NSDate!
    
    var editEventFlag: Bool!
    var tempEventDate2: NSDate!
    var flickrImageURL: String!
    var flickrImage: UIImage!
    
    //-Disney image based on flag (0-no pic, 1-library, 2-camera, 3-Flickr)
    var imageFlag: Int! = 0

    
    //-Event Description Font Attributes
    let eventTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blueColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 26)!,
        NSStrokeWidthAttributeName : -1.5
    ]
    
    
    //-Perform when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-Create buttons
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "saveEvent")
        
        //-Disable SAVE button if creating new Event
        //-Enable SAVE button if editing existing Event
        if editEventFlag == true {
            self.navigationItem.rightBarButtonItem?.enabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
        
        //-Hide the Tab Bar
        self.tabBarController?.tabBar.hidden = true
        
//        let datePickButton = UIButton.buttonWithType(.System) as! UIButton
//        datePickerButton.setTitle(title, forState: .Normal)
//        datePickerButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
//        datePickerButton.titleLabel?.textAlignment = NSTextAlignment.Center
//        datePickerButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        //Get shared model info
//        let object = UIApplication.sharedApplication().delegate
//        let appDelegate = object as! AppDelegate
//        events = appDelegate.events
        
        println("New Date1: \(tempEventDate2)")
        
        //-Date Picker Formatting -----------------------------------------------------
        var dateFormatter = NSDateFormatter()
        
        self.todaysDate = NSDate()
        let date = NSDate()
        let timeZone = NSTimeZone(name: "Local")
        
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateNew = dateFormatter.stringFromDate(date)
        
        println("-------------------")
        println("TEST", dateNew)

        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
        dateFormatter.timeZone = NSTimeZone()
        println(dateFormatter.timeZone)
        
        let localDate = dateFormatter.stringFromDate(date)
        //let strDate = dateFormatter.stringFromDate(myDatePicker.date)
        self.currentDate.text = localDate
        
        //-----------------------------------------------------------------------------
        
        //-Add font attributes to Event Description
        self.textFieldEvent.defaultTextAttributes = eventTextAttributes
        
        //-Set starting textfield default values
        self.textFieldEvent.text = "Enter Event Description"
        self.textFieldEvent.textAlignment = NSTextAlignment.Center
        
        //-Textfield delegate values
        self.textFieldEvent.delegate = eventTextDelegate
        
        
        fetchedResultsController.performFetch(nil)
        
        //-Set the view controller as the delegate
        fetchedResultsController.delegate = self
        
        if editEventFlag == false {
            datePickerLable.text = "Enter a New Date and Time"
        } else {
            
            let event = fetchedResultsController.objectAtIndexPath(eventIndexPath2) as! Events
            
            //-Add Selected Meme attributes and populate Editor fields
            self.textFieldEvent.text = event.textEvent
            imageViewPicker.image = UIImage(data: event.eventImage!)
            tempEventDate2 = event.eventDate
            
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
            dateFormatter.timeZone = NSTimeZone()
            println("New Date1: \(tempEventDate2)")
            let strDate = dateFormatter.stringFromDate(tempEventDate2)
            println("New Date1 String: \(strDate)")
            //datePickerButton.titleLabel?.text = strDate
            datePickerLable.text = strDate
            
        }

        
    }
    
    //-Perform when view appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        //-Archive the graph any time this list of events is displayed.
//        NSKeyedArchiver.archiveRootObject(self.events, toFile: eventsFilePath)
        
        
//        println(self.flickrImageURL)
//        if self.flickrImageURL != nil {
//
//            let imageURL = NSURL(string: self.flickrImageURL)
//            if let imageData = NSData(contentsOfURL: imageURL!) {
//                self.imageViewPicker.image = UIImage(data: imageData)
//            
//            } else {
//                self.imageViewPicker.image = nil
//            }
//        }
        
        
//        if self.imageViewPicker.image != nil {
//            
//        }
        
        
//        if self.flickrImage != nil && self.imageViewPicker.image == nil {
//            println("Flickr Image is present")
//            self.imageViewPicker.image = flickrImage
//                
//        }
        
        if imageFlag == 3 {

            self.navigationItem.rightBarButtonItem?.enabled = true
            self.imageViewPicker.image = flickrImage
        }
        
        
//        if editEventFlag == true {
//            let event = fetchedResultsController.objectAtIndexPath(eventIndexPath2) as! Events
//
//            //* - Add Selected Meme attributes and populate Editor fields
//            self.textFieldEvent.text = event.textEvent
//            imageViewPicker.image = UIImage(data: event.eventImage!)
//            tempEventDate2 = event.eventDate
//        }
        
        //var tempEventDate2: NSDate!
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
        dateFormatter.timeZone = NSTimeZone()
        if tempEventDate2 != nil {
            println("New Date2: \(tempEventDate2)")
            let strDate = dateFormatter.stringFromDate(tempEventDate2)
            println("New Date2 String: \(strDate)")
            //datePickerButton.titleLabel?.text = strDate
            datePickerLable.text = strDate
            //datePickerButton.titleLabel?.adjustsFontSizeToFitWidth = true

            
//            let button = UIButton.buttonWithType(.System) as! UIButton
//            button.setTitle(title, forState: .Normal)
//            button.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
//            button.titleLabel?.textAlignment = NSTextAlignment.Center
//            button.setTranslatesAutoresizingMaskIntoConstraints(false)
            
        }
    
        
        //-Disable the CAMERA if you are using a simulator without a camera
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        //-Subscribe to the Keyboard notification
        self.subscribeToKeyboardNotifications()  //make the call to subscribe to keyboard notifications
    }
    
    //-Perform when view disappears
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //-Unsubscribe from the keyboard notifications
        self.unsubscribeFromKeyboardNotifications() //make the call to unsubscribe to keyboard notifications
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
    
    
//    func didFinishSecondVC(controller: BeGoodPickdateViewController) {
//        tempEventDate2 = controller.tempEventDate
//        println("New Date: \(tempEventDate2)")
//        controller.navigationController?.popViewControllerAnimated(true)
//    }
    
    
    @IBAction func pickEventDate(sender: UIButton) {
        println("pickEventDate")
        
        datePickerButton.titleLabel?.adjustsFontSizeToFitWidth = true
        datePickerButton.titleLabel?.textAlignment = NSTextAlignment.Center
        
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BeGoodPickdateViewController") as! BeGoodPickdateViewController
        controller.editEventFlag2 = editEventFlag
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    
    //Button to Pick an image from the library
    @IBAction func PickAnImage(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //Select an image for the Event from your Camera Roll
    func imagePickerController(imagePicker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
            
            if let eventImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.imageViewPicker.image = eventImage
                imageFlag = 1
            }
            //Enable the Sharing Button
            //shareMemeButton.enabled = true
            self.navigationItem.rightBarButtonItem?.enabled = true
            
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //Cancel the picked image
    func imagePickerControllerDidCancel(imagePicker: UIImagePickerController){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Select an image by taking a Picture
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imageFlag = 2
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    //Select a Flickr Image
    @IBAction func getFlickrImage(sender: UIBarButtonItem) {
        
        println("Get Flickr Image")
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BeGoodFlickrViewController") as! BeGoodFlickrViewController
        controller.editEventFlag2 = editEventFlag
        controller.eventIndexPath2 = self.eventIndexPath2
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    
    //Subscribe to Keyboard appearing and hiding notifications
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:"    , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //Move screen up to prevent keyboard overlap
    func keyboardWillShow(notification: NSNotification) {
        if textFieldEvent.isFirstResponder(){
//            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    //Move screen back down after done using keyboard
    func keyboardWillHide(notification: NSNotification) {
        if textFieldEvent.isFirstResponder(){
//            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    //Calculate the keyboard height and place in variable
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    //Unsubscribe from Keyboard Appearing and hiding notifications
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
//    //Generate the Meme
//    func generateMemedImage() -> UIImage {
//        
//        //Hide toolbar and navbar
//        navbarObject.hidden = true
//        toolbarObject.hidden = true
//        
//        //Render view to an image
//        UIGraphicsBeginImageContext(self.view.frame.size)
//        self.view.drawViewHierarchyInRect(self.view.frame,
//            afterScreenUpdates: true)
//        let memedImage : UIImage =
//        UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        //Show toolbar and navbar
//        navbarObject.hidden = false
//        toolbarObject.hidden = false
//        
//        return memedImage
//    }

    
    //-Save the Event
    //@IBAction func saveEvent(sender: UIBarButtonItem) {
    func saveEvent() {
        
        //-Create the Meme
        let eventImage = UIImageJPEGRepresentation(imageViewPicker.image, 100)
        
        // Add it to the shared Memes array in the Application Delegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate

        
        if editEventFlag == true {
            
            //-Update selected event
            println("Update Selected Event")
            let event = self.fetchedResultsController.objectAtIndexPath(self.eventIndexPath2) as! Events
            event.eventDate = self.tempEventDate2
            event.textEvent = textFieldEvent.text!
            event.eventImage = eventImage
            self.sharedContext.refreshObject(event, mergeChanges: true)
            CoreDataStackManager.sharedInstance().saveContext()
            
            //-Pass event index info to Show scene
            let controller = self.navigationController!.viewControllers[1] as! BeGoodShowViewController
            //controller.events = self.events
            controller.editEventFlag = true
            controller.eventIndexPath = self.eventIndexPath2
            controller.eventIndex = self.eventIndex2
            self.navigationController?.popViewControllerAnimated(true)
            
            
        } else {
            
            //-Save new event
            println("Save New Event")
            let eventToBeAdded = Events(eventDate: self.tempEventDate2, textEvent: textFieldEvent.text!, eventImage: eventImage, context: sharedContext)
            
//            appDelegate.events.append(eventToBeAdded)
            //events.append(eventToBeAdded)
//            self.events?.append(eventToBeAdded)
            
            
            //-Save the shared context, using the convenience method in the CoreDataStackManager
            CoreDataStackManager.sharedInstance().saveContext()

            self.navigationController?.popViewControllerAnimated(true)
        }

    }

    
    
//    //Share the Event
//    @IBAction func shareMyEvent(sender: AnyObject) {
//        
//        //Create a memed image, pass it to the activity view controller.
//        self.memedImage = generateMemedImage()
//        
//        let activityVC = UIActivityViewController(activityItems: [self.memedImage!], applicationActivities: nil)
//        
//        //If the user completes an action in the activity view controller,
//        //save the Meme to the shared storage.
//        activityVC.completionWithItemsHandler = {
//            activity, completed, items, error in
//            if completed {
//                self.saveMeme()
//                //println("Newly Saved Meme Index: \(appDelegate.memes.last)")
//                //self.dismissViewControllerAnimated(true, completion: nil)
//                
//                //                let storyboard = self.storyboard
//                //                let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
//                //
//                //                //let meme = self.fetchedResultsController.objectAtIndexPath(self.memeIndexPath2) as! Memes
//                //                controller.editEventFlag = true
//                //                //controller.memes = self.memes
//                //                controller.memeIndexPath = self.memeIndexPath2
//                //                controller.memeIndex = self.memeIndex2
//                //                //controller.memedImage = self.memedImage2
//                //                //println("controller.memedImage: \(controller.memedImage)")
//                //
//                //                self.presentViewController(controller, animated: true, completion: nil)
//                
//            }
//        }
//        
//        self.presentViewController(activityVC, animated: true, completion: nil)
//        
//    }
    
    //Cancel the Editor and go back to the previous scene
    @IBAction func CancelEventButton(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    //-Saving the array. Helper.
    
    var eventsFilePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        println(url.URLByAppendingPathComponent("events").path!)
        return url.URLByAppendingPathComponent("events").path!
    }
    
}



