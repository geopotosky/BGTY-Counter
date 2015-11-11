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
    
    //-View Outlets
    @IBOutlet weak var datePickerLable: UILabel!
    @IBOutlet weak var datePickerButton: UIButton!
    @IBOutlet weak var imageViewPicker: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var flickrButton: UIButton!
    @IBOutlet weak var textFieldEvent: UITextField!
    @IBOutlet weak var toolbarObject: UIToolbar!
    
    //-Set the textfield delegates
    let eventTextDelegate = EventTextDelegate()
    
    //-Global objects, properties & variables
    var events: Events!
    var eventIndex2:Int!
    var eventIndexPath2: NSIndexPath!
    var todaysDate: NSDate!
    var editEventFlag: Bool!
    var currentEventDate: NSDate!
    var flickrImageURL: String!
    var flickrImage: UIImage!
    
    //* - Alert variable
    var alertMessage: String!
    
    //-Disney image based on flag (0-no pic, 1-library, 2-camera, 3-Flickr)
    var imageFlag: Int! = 0
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    
    //-Perform when view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-Set Navbar Title
        self.navigationItem.title = "Event Creator"
        //-Create Navbar Buttons
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "saveEvent")
        self.toolbarObject?.backgroundColor = UIColor.greenColor()
        
        //-Disable SAVE button if creating new Event
        //-Enable SAVE button if editing existing Event
        if editEventFlag == true {
            self.navigationItem.rightBarButtonItem?.enabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
        
        //-Hide the Tab Bar
        self.tabBarController?.tabBar.hidden = true
        
        //-Initialize the tapRecognizer in viewDidLoad
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
        
        //-Date Picker Formatting -----------------------------------------------------
        
        let dateFormatter = NSDateFormatter()
        
        self.todaysDate = NSDate()
        //let date = NSDate()
        let timeZone = NSTimeZone(name: "Local")
        
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //let dateNew = dateFormatter.stringFromDate(date)
        
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
        dateFormatter.timeZone = NSTimeZone()
        
        //let localDate = dateFormatter.stringFromDate(date)
        
        //-----------------------------------------------------------------------------
        
        
        //-Set starting textfield default values
        self.textFieldEvent.text = "Enter Event Description"
        self.textFieldEvent.textAlignment = NSTextAlignment.Center
        
        //-Textfield delegate values
        self.textFieldEvent.delegate = eventTextDelegate
        
        
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
        }
        
        //-Set the view controller as the delegate
        fetchedResultsController.delegate = self
        
        if editEventFlag == false {
            //-Load default values for new event
            imageViewPicker.image = UIImage(named: "BG_Placeholder_Image.png")
            currentEventDate = NSDate()
            
            
        } else {
            
            let event = fetchedResultsController.objectAtIndexPath(eventIndexPath2) as! Events
            
            //-Add Selected Meme attributes and populate Editor fields
            self.textFieldEvent.text = event.textEvent
            imageViewPicker.image = UIImage(data: event.eventImage!)
            currentEventDate = event.eventDate
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
            dateFormatter.timeZone = NSTimeZone()
            let strDate = dateFormatter.stringFromDate(currentEventDate)
            datePickerLable.text = strDate
            
        }
        
        
    }
    
    //-Perform when view appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //-Add tap recognizer to dismiss keyboard
        self.addKeyboardDismissRecognizer()
        
        //-Recognize the Flickr image request
        if imageFlag == 3 {
            
            self.navigationItem.rightBarButtonItem?.enabled = true
            self.imageViewPicker.image = flickrImage
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
        dateFormatter.timeZone = NSTimeZone()
        if currentEventDate != nil {
            let strDate = dateFormatter.stringFromDate(currentEventDate)
            datePickerLable.text = strDate
            
        }
        
        //-Disable the CAMERA if you are using a simulator without a camera
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
    }
    
    //-Perform when view disappears
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //-Remove tap recognizer
        self.removeKeyboardDismissRecognizer()

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

    
    //-Pick Event Date
    @IBAction func pickEventDate(sender: UIButton) {
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BeGoodPickDateViewController") as! BeGoodPickDateViewController
        controller.editEventFlag2 = editEventFlag
        controller.currentEventDate = self.currentEventDate
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    
    //-Button to Pick an image from the library
    @IBAction func PickAnImage(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //-Select an image for the Event from your Camera Roll
    func imagePickerController(imagePicker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]){
            
            if let eventImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.imageViewPicker.image = eventImage
                imageFlag = 1
            }
            //Enable the Right Navbar Button
            self.navigationItem.rightBarButtonItem?.enabled = true
            
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //-Cancel the picked image
    func imagePickerControllerDidCancel(imagePicker: UIImagePickerController){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //-Select an image by taking a Picture
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imageFlag = 2
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    //-Call the Flickr VC
    @IBAction func getFlickrImage(sender: UIButton) {

        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BeGoodFlickrViewController") as! BeGoodFlickrViewController
        controller.editEventFlag2 = editEventFlag
        controller.eventIndexPath2 = self.eventIndexPath2
        controller.currentImage = imageViewPicker.image
        self.navigationController!.pushViewController(controller, animated: true)
    }

    
    //-Dismissing the keyboard methods
    
    func addKeyboardDismissRecognizer() {
        //-Add the recognizer to dismiss the keyboard
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        //-Remove the recognizer to dismiss the keyboard
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        //-End editing here
        self.view.endEditing(true)
    }
    
    
    //-Save the Event method
    func saveEvent() {
        
        let eventImage = UIImageJPEGRepresentation(imageViewPicker.image!, 100)
        
        //-If the edit event flag is set to true, save a existing event
        if editEventFlag == true {
            
            if textFieldEvent.text == "" {
                self.alertMessage = "Please Add an Event Description"
                self.textAlertMessage()
            } else {
                
                //-Update selected event
                let event = self.fetchedResultsController.objectAtIndexPath(self.eventIndexPath2) as! Events
                event.eventDate = self.currentEventDate
                event.textEvent = textFieldEvent.text!
                event.eventImage = eventImage
                self.sharedContext.refreshObject(event, mergeChanges: true)
                CoreDataStackManager.sharedInstance().saveContext()
            
                //-Pass event index info to Show scene
                let controller = self.navigationController!.viewControllers[1] as! BeGoodShowViewController
                controller.editEventFlag = true
                controller.eventIndexPath = self.eventIndexPath2
                controller.eventIndex = self.eventIndex2
            
                self.navigationController?.popViewControllerAnimated(true)
            }
            
        //-If the edit event flag is set to false, save a new event
        } else {
            if textFieldEvent.text == "" {
                self.alertMessage = "Please Add an Event Description"
                self.textAlertMessage()
            } else {
                
                //-Save new event
                let _ = Events(eventDate: self.currentEventDate, textEvent: textFieldEvent.text!, eventImage: eventImage, context: sharedContext)
                //let eventToBeAdded = Events(eventDate: self.currentEventDate, textEvent: textFieldEvent.text!, eventImage: eventImage, context: sharedContext)
            
                //-Save the shared context, using the convenience method in the CoreDataStackManager
                CoreDataStackManager.sharedInstance().saveContext()
            
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        
    }
    
    
    //-Alert Message function
    func textAlertMessage(){
        dispatch_async(dispatch_get_main_queue()) {
            let actionSheetController = UIAlertController(title: "Alert!", message: "\(self.alertMessage)", preferredStyle: .Alert)
            
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
    
    
    //-Saving the array Helper.
    var eventsFilePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        print(url.URLByAppendingPathComponent("events").path!)
        return url.URLByAppendingPathComponent("events").path!
    }
    
}



