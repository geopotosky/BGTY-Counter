//
//  BeGoodPopoverViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 10/15/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//


import UIKit
import CoreData

enum AdaptiveMode{
    case Default
    case LandscapePopover
    case AlwaysPopover
}

class BeGoodPopoverViewController: UITableViewController, UIPopoverPresentationControllerDelegate, NSFetchedResultsControllerDelegate {
    
    
    @IBInspectable var popoverOniPhone:Bool = false
    @IBInspectable var popoverOniPhoneLandscape:Bool = true
    
    //var events: [Events]!
    var events: Events!
    //var eventIndex:Int!
    var eventIndexPath2: NSIndexPath!
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //cancel button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "tapCancel:")
        
        // popover settings
        modalPresentationStyle = .Popover
        popoverPresentationController!.delegate = self
        
        self.preferredContentSize = CGSize(width:200,height:100)
    }
    
    func tapCancel(_ : UIBarButtonItem) {
        //tap cancel
        dismissViewControllerAnimated(true, completion:nil);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.popoverPresentationController?.backgroundColor = UIColor.whiteColor()
        
        fetchedResultsController.performFetch(nil)
        
        // Set the view controller as the delegate
        fetchedResultsController.delegate = self

        
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        //selected a school
        let schoolName = tableView.cellForRowAtIndexPath(indexPath)!.textLabel!.text
        if schoolName == "To Do List" {
            
//            let storyboard = self.storyboard
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("TodoTableViewController") as! TodoTableViewController
            
            let event = fetchedResultsController.objectAtIndexPath(eventIndexPath2) as! Events
            
            controller.eventIndexPath2 = eventIndexPath2
            controller.events = event
            
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            self.presentViewController(navController, animated: true, completion: nil)
            
            
        } else if schoolName == "Budget Sheet" {
            println("did select school: \(schoolName)")
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BudgetTableViewController") as! BudgetTableViewController
            
            let event = fetchedResultsController.objectAtIndexPath(eventIndexPath2) as! Events
            
            controller.eventIndexPath2 = eventIndexPath2
            controller.events = event
            
            let navController = UINavigationController(rootViewController: controller)
            navController.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            self.presentViewController(navController, animated: true, completion: nil)
            //self.navigationController!.pushViewController(navController, animated: true)
        }
        
    }
    
    // popover settings, adaptive for horizontal compact trait
    // #pragma mark - UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyleForPresentationController(PC: UIPresentationController) -> UIModalPresentationStyle{
        
        //this methods is only called by System when the screen has compact width
        
        //return .None means we still want popover when adaptive on iPhone
        //return .FullScreen means we'll get modal presetaion on iPhone
        
        switch(popoverOniPhone, popoverOniPhoneLandscape){
        case (true, _): // always popover on iPhone
            return .None
            
        case (_, true): // popover only on landscape on iPhone
            let size = PC.presentingViewController.view.frame.size
            if(size.width>320.0){ //landscape
                return .None
            }else{
                return .FullScreen
            }
            
        default: // no popover on iPhone
            return .FullScreen
        }
        
        
    }
    
    func presentationController(_: UIPresentationController, viewControllerForAdaptivePresentationStyle _: UIModalPresentationStyle)
        -> UIViewController?{
            return UINavigationController(rootViewController: self)
    }
}

