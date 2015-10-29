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
    
    //-Add/Edit Screen outlets
    @IBOutlet weak var currentDate: UILabel!
    @IBOutlet weak var datePickerLable: UILabel!
    @IBOutlet weak var datePickerButton: UIButton!
    @IBOutlet weak var imageViewPicker: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var flickrButton: UIButton!
    @IBOutlet weak var textFieldEvent: UITextField!
    @IBOutlet weak var toolbarObject: UIToolbar!
    
    //-Set the textfield delegates
    let eventTextDelegate = EventTextDelegate()
    
    //-Global Variables
    var events: Events!
    
    //    var eventImage : UIImage!
    var eventIndex2:Int!
    var eventIndexPath2: NSIndexPath!
    //    var eventImage2: NSData!
    
    var todaysDate: NSDate!
    //
    var editEventFlag: Bool!
    var currentEventDate: NSDate!
    var flickrImageURL: String!
    var flickrImage: UIImage!
    
    //-Disney image based on flag (0-no pic, 1-library, 2-camera, 3-Flickr)
    var imageFlag: Int! = 0
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    
    //-Perform when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-Create buttons
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
        
        
        //        var pinchGestureRecognizer: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "pinchGestureDetected:")
        //        pinchGestureRecognizer.setDelegate(self)
        //        imageView.addGestureRecognizer(pinchGestureRecognizer)
        
        
        //-Date Picker Formatting -----------------------------------------------------
        
        var dateFormatter = NSDateFormatter()
        
        self.todaysDate = NSDate()
        let date = NSDate()
        let timeZone = NSTimeZone(name: "Local")
        
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateNew = dateFormatter.stringFromDate(date)
        
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
        dateFormatter.timeZone = NSTimeZone()
        println(dateFormatter.timeZone)
        
        let localDate = dateFormatter.stringFromDate(date)
        self.currentDate.text = localDate
        
        //-----------------------------------------------------------------------------
        
        
        //-Set starting textfield default values
        self.textFieldEvent.text = "Enter Event Description"
        self.textFieldEvent.textAlignment = NSTextAlignment.Center
        
        //-Textfield delegate values
        self.textFieldEvent.delegate = eventTextDelegate
        
        
        fetchedResultsController.performFetch(nil)
        
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
            
            var dateFormatter = NSDateFormatter()
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
        
        //-Subscribe to the Keyboard notification
        self.subscribeToKeyboardNotifications()  //make the call to subscribe to keyboard notifications
        
        //-Recognize the Flickr image request
        if imageFlag == 3 {
            
            self.navigationItem.rightBarButtonItem?.enabled = true
            self.imageViewPicker.image = flickrImage
        }
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
        dateFormatter.timeZone = NSTimeZone()
        if currentEventDate != nil {
            let strDate = dateFormatter.stringFromDate(currentEventDate)
            println("New Date2 String: \(strDate)")
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
    
    
    //-Pinch Gesture method
    @IBAction func scaleImage(recognizer: UIPinchGestureRecognizer) {
        recognizer.view!.transform = CGAffineTransformScale(recognizer.view!.transform, recognizer.scale, recognizer.scale)
        recognizer.scale = 1
    }
    
    //-Pan Gesture method
    @IBAction func panImage(recognizer: UIPanGestureRecognizer) {
        //var state: UIGestureRecognizerState = recognizer.state
        //if state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged {
            var translation: CGPoint = recognizer.translationInView(recognizer.view!)
            //recognizer.view.setTransform(CGAffineTransformTranslate(recognizer.view!.transform, translation.x, translation.y))
            recognizer.view!.transform = CGAffineTransformTranslate(recognizer.view!.transform, translation.x, translation.y)
            recognizer.setTranslation(CGPointZero, inView: recognizer.view)
        //}
    }

    
    //-Pick Event Date
    @IBAction func pickEventDate(sender: UIButton) {
        println("pickEventDate")
        
        //datePickerButton.titleLabel?.adjustsFontSizeToFitWidth = true
        //datePickerButton.titleLabel?.textAlignment = NSTextAlignment.Center
        
        //let storyboard = self.storyboard
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
        didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
            
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
    
    
    @IBAction func getFlickrImage(sender: UIButton) {
        
        println("Get Flickr Image")
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BeGoodFlickrViewController") as! BeGoodFlickrViewController
        controller.editEventFlag2 = editEventFlag
        controller.eventIndexPath2 = self.eventIndexPath2
        controller.currentImage = imageViewPicker.image
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    
    //-Subscribe to Keyboard appearing and hiding notifications
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:"    , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //-Move screen up to prevent keyboard overlap
    func keyboardWillShow(notification: NSNotification) {
        if textFieldEvent.isFirstResponder(){
            //            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    //-Move screen back down after done using keyboard
    func keyboardWillHide(notification: NSNotification) {
        if textFieldEvent.isFirstResponder(){
            //            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    //-Calculate the keyboard height and place in variable
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
    
    //-Dismissing the keyboard
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
    
    
    //-Save the Event
    func saveEvent() {
        
        let eventImage = UIImageJPEGRepresentation(imageViewPicker.image, 100)
        
        if editEventFlag == true {
            
            //-Update selected event
            println("Update Selected Event")
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
            
            
        } else {
            
            //-Save new event
            println("Save New Event")
            let eventToBeAdded = Events(eventDate: self.currentEventDate, textEvent: textFieldEvent.text!, eventImage: eventImage, context: sharedContext)
            
            //-Save the shared context, using the convenience method in the CoreDataStackManager
            CoreDataStackManager.sharedInstance().saveContext()
            
            self.navigationController?.popViewControllerAnimated(true)
        }
        
    }
    
    
    
    //-Saving the array Helper.
    var eventsFilePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        println(url.URLByAppendingPathComponent("events").path!)
        return url.URLByAppendingPathComponent("events").path!
    }
    
}



