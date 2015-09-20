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
    
    //var memedImage : UIImage!
    var events: [Events]!
    //    var memes: Memes!
    var eventIndex:Int!
    var eventIndexPath: NSIndexPath!
    //var memedImage: NSData!
    //    var memedImage2: NSData!
    //    var memedImage3: NSData!
    
    var editMemeFlag: Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get shared model info
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        events = appDelegate.events
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "deleteEvent")
        
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
        //        println("editMemeFlag: \(editMemeFlag)")
        
        
    }
    
    //Perform when view appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        println("MemeDetailVC viewWillAppear")
        
        //println("memes.count: \(memes.count)")
//        println("memeIndex: \(memeIndex)")
//        println("memeIndexPath: \(memeIndexPath)")
//        println("editMemeFlag: \(editMemeFlag)")
        
        //Get shared model info
        //        let object = UIApplication.sharedApplication().delegate
        //        let appDelegate = object as! AppDelegate
        //        memes = appDelegate.memes
        
        let event = fetchedResultsController.objectAtIndexPath(eventIndexPath) as! Events
        
        println(event.textEvent)
        
        let finalImage = UIImage(data: event.eventImage!)
        self.imageView!.image = finalImage
        
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
    
    
//    func editMeme(){
//        println("Getting ready to edit the Event")
//        let storyboard = self.storyboard
//        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BeGoodAddEventViewController") as! BeGoodAddEventViewController
//        
//        //controller.memes = memes[index]
//        //controller.memes = self.memes
//        
//        controller.memeIndexPath2 = memeIndexPath
//        controller.memeIndex2 = memeIndex
//        controller.editMemeFlag = true
//        
//        //controller.memedImage2 = meme.memedImage
//        
//        self.presentViewController(controller, animated: true, completion: nil)
//        //self.navigationController!.pushViewController(controller, animated: true)
//        
//        //        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
//        //        controller.memeIndexPath2 = memeIndexPath
//        //        controller.memeIndex2 = memeIndex
//        //        controller.editMemeFlag = true
//        //        self.navigationController!.pushViewController(controller, animated: true)
//        
//    }
    
    
    //function - Delete the selected meme
    //@IBAction func deleteMemeButton(sender: UIButton) {
    func deleteEvent(){
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

