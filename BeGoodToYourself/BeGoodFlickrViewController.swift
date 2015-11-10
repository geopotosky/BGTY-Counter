//
//  BeGoodFlickrViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 9/26/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//

import UIKit

class BeGoodFlickrViewController: UIViewController {
    
    //-View Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var phraseTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var pickImageButton: UIButton!
    @IBOutlet weak var flickrActivityIndicator: UIActivityIndicatorView!
    
    //-Global objects, properties & variables
    var events: [Events]!
    var editEventFlag2: Bool!
    var searchFlag: Bool!
    var flickrImageURL: String!
    var eventIndexPath2: NSIndexPath!
    var eventImage2: NSData!
    var currentImage: UIImage!
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    //-set the textfield delegates
    let flickrTextDelegate = FlickrTextDelegate()
    
    //-Get the app delegate (used for Flickr API)
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //-Alert variable
    var alertMessage: String!
    
    
    //-Perform when view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-Set Navbar Title
        self.navigationItem.title = "Flicker Picker"
        
        //-Initialize the tapRecognizer in viewDidLoad
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
        searchFlag = false
        //searchButtonLabel.text = "Search"
        pickImageButton.hidden = true
        flickrActivityIndicator.hidden = true
        
        //-Textfield delegate values
        self.phraseTextField.delegate = flickrTextDelegate
        
    }
    
    
    //-Perform when view will appear
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //-Add tap recognizer to dismiss keyboard
        self.addKeyboardDismissRecognizer()
        
        if editEventFlag2 == false {
            self.photoImageView.image = UIImage(named: "BG_Placeholder_Image.png")
        } else {
            self.photoImageView.image = currentImage
        }
    }
    
    
    //-Perform when view will disappear
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //-Remove tap recognizer
        self.removeKeyboardDismissRecognizer()

    }
    
    
    //-Call the Flicker Search API
    @IBAction func searchFlicker(sender: UIButton) {
        
        searchFlag = true
        pickImageButton.hidden = true
        
        self.flickrActivityIndicator.hidden = false
        self.flickrActivityIndicator.startAnimating()
        
        //-Set the Flickr Text Phrase for API search
        appDelegate.phraseText = self.phraseTextField.text
        
        //-Added from student request -- hides keyboard after searching
        self.dismissAnyVisibleKeyboards()
        
        //-Verify Phrase Textfield in NOT Empty
        if !self.phraseTextField.text.isEmpty {
            
            //-Call the Get Flickr Images function
            BGClient.sharedInstance().getFlickrData(self) { (success, pictureURL, errorString) in
                
                if success {
                    
                    self.flickrImageURL = pictureURL
                    let imageURL = NSURL(string: pictureURL!)
                    
                    //-If an image exists at the url, set the image and title
                    if let imageData = NSData(contentsOfURL: imageURL!) {
                        //let finalImage = UIImage(data: imageData)
                        self.eventImage2 = imageData
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            //self.defaultLabel.alpha = 0.0
                            self.photoImageView.image = UIImage(data: imageData)
                            self.pickImageButton.hidden = false
                            self.flickrActivityIndicator.hidden = true
                            self.flickrActivityIndicator.stopAnimating()
                            
                        })
                        
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.photoImageView.image = UIImage(named: "BG_Placeholder_Image.png")
                        })
                    }
                    
                } else {
                    //-Call Alert message
                    self.alertMessage = "Flickr Error Message! \(errorString)"
                    self.errorAlertMessage()
                } //-End success
            
            } //-End VTClient method
        
        } else {
            self.flickrActivityIndicator.hidden = true
            self.flickrActivityIndicator.stopAnimating()
            //-If Phrase is empty, display Empty message
            self.alertMessage = "Search Phrase is Missing"
            self.errorAlertMessage()
        }

    }

    //-Pick the selected image button
    @IBAction func pickFlickrImage(sender: UIButton) {
        
        //-If edit event flag is set to true, then prep for return to Add VC for existing event
        if editEventFlag2 == true {
            let controller = self.navigationController!.viewControllers[2] as! BeGoodAddEventViewController
            //-Forward selected event date to previous view
            controller.flickrImageURL = self.flickrImageURL
            controller.flickrImage = self.photoImageView.image
            controller.imageFlag = 3

            self.navigationController?.popViewControllerAnimated(true)
            
        //-If edit event flag is set to false, then prep for return to Add VC for new event
        } else {
            let controller = self.navigationController!.viewControllers[1] as! BeGoodAddEventViewController
            //-Forward selected event date to previous view
            controller.flickrImageURL = self.flickrImageURL
            controller.flickrImage = self.photoImageView.image
            controller.imageFlag = 3

            self.navigationController?.popViewControllerAnimated(true)
        }
        
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
    
    
    //-Alert Message function
    func errorAlertMessage(){
        dispatch_async(dispatch_get_main_queue()) {
            let actionSheetController: UIAlertController = UIAlertController(title: "Alert!", message: "\(self.alertMessage)", preferredStyle: .Alert)
            
            //-Update alert colors and attributes
            actionSheetController.view.tintColor = UIColor.blueColor()
            let subview = actionSheetController.view.subviews.first! as! UIView
            let alertContentView = subview.subviews.first! as! UIView
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

//-This extension was added as a fix based on student comments
extension BeGoodFlickrViewController {
    func dismissAnyVisibleKeyboards() {
        if phraseTextField.isFirstResponder() {
            self.view.endEditing(true)
        }
    }
}

