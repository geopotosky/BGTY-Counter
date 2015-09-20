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
    @IBOutlet weak var imageViewPicker: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
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
    //var events: Events!
    var events: [Events]!
    
    
    var eventIndex2:Int!
    var eventIndexPath2: NSIndexPath!
    var eventImage2: NSData!
    
    var todaysDate: NSDate!
    
    var editMemeFlag: Bool!

    
    //Event Font Attributes
    let eventTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blueColor(),
        NSForegroundColorAttributeName : UIColor.blackColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 16)!,
        NSStrokeWidthAttributeName : -2.0
    ]
    
    //setup the Meme Editor text fields
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get shared model info
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        events = appDelegate.events
        
        //-----------------------------------------------------
        var dateFormatter = NSDateFormatter()
        //let pickerDate = myDatePicker.date
        self.todaysDate = NSDate()
        println("todaysDate: \(todaysDate)")
        
        let localDate = dateFormatter.stringFromDate(todaysDate)
        //let strDate = dateFormatter.stringFromDate(myDatePicker.date)
        self.currentDate.text = localDate
        //-----------------------------------------------------
        
        //Add font attributes to top and bottom text fields
        self.textFieldEvent.defaultTextAttributes = eventTextAttributes
        
        //Set starting textfield default values
        self.textFieldEvent.text = "Enter Event Description"
        self.textFieldEvent.textAlignment = NSTextAlignment.Center
        
        //textfield delegate values
        self.textFieldEvent.delegate = eventTextDelegate
        
        fetchedResultsController.performFetch(nil)
        
        // Set the view controller as the delegate
        fetchedResultsController.delegate = self
        
//        println("editMemeFlag: \(self.editMemeFlag)")
//        
//            if events.count == 0 {
//                
//                cancelEventButton.enabled = false
//            } else {
//                cancelEventButton.enabled = true
//            }
        
    }
    
    //Perform when view appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Disable the CAMERA if you are using a simulator without a camera
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        //Subscribe to the Keyboard notification
        self.subscribeToKeyboardNotifications()  //make the call to subscribe to keyboard notifications
    }
    
    //Perform when view disappears
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Unsubscribe from the keyboard notifications
        self.unsubscribeFromKeyboardNotifications() //make the call to unsubscribe to keyboard notifications
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
    
    
    
    //Button to Pick an image from the library
    @IBAction func PickAnImage(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //Select an image for the Meme
    func imagePickerController(imagePicker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [NSObject : AnyObject]){
            
            if let eventImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.imageViewPicker.image = eventImage
            }
            //Enable the Sharing Button
            //shareMemeButton.enabled = true
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //Cancel the picked image
    func imagePickerControllerDidCancel(imagePicker: UIImagePickerController){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //Button to Take a Picture with Camera
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //Subscribe to Keyboard appearing and hiding notifications
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:"    , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //Move screen up to prevent keyboard overlap
    func keyboardWillShow(notification: NSNotification) {
        if textFieldEvent.isFirstResponder(){
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    //Move screen back down after done using keyboard
    func keyboardWillHide(notification: NSNotification) {
        if textFieldEvent.isFirstResponder(){
            self.view.frame.origin.y += getKeyboardHeight(notification)
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
    
    //Save the Meme
    @IBAction func saveEvent(sender: UIBarButtonItem) {
        
        //Create the Meme
        let eventImage = UIImageJPEGRepresentation(imageViewPicker.image, 100)
        //let memedImage2 = UIImageJPEGRepresentation(memedImage, 100)
        
        println("eventDate: \(self.todaysDate)")
        println("textEvent: \(textFieldEvent.text!)")
        //println("eventImage: \(eventImage)")
        
        let eventToBeAdded = Events(eventDate: self.todaysDate, textEvent: textFieldEvent.text!, eventImage: eventImage, context: sharedContext)
        
        // Add it to the shared Memes array in the Application Delegate
//        let object = UIApplication.sharedApplication().delegate
//        let appDelegate = object as! AppDelegate
        
        // And add append the actor to the array as well
        println("Save Event")
        //appDelegate.memes.append(memeToBeAdded)
//        events.append(eventToBeAdded)
        
        // Finally we save the shared context, using the convenience method in
        // The CoreDataStackManager
        println("Saving Memes")
        CoreDataStackManager.sharedInstance().saveContext()
            
        self.dismissViewControllerAnimated(true, completion: nil)

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
//                //                controller.editMemeFlag = true
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
}



