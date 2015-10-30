//
//  BeGoodCollectionViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 9/19/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class BeGoodCollectionViewController: UIViewController, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    //-Scene outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomButton: UIButton!
    
    
    //-Event variables
    
    var events = [Events]()
    var eventIndex: Int!
    
    //-Flag passed to determine editing function (add or edit). This flag allows reuse of the AddEvent view
    var editEventFlag: Bool!
    var editButtonFlag: Bool!
    
    //-Tab Bar variables
    var tabBarItemONE: UITabBarItem = UITabBarItem()
    var tabBarItemTWO: UITabBarItem = UITabBarItem()
    
    
    // The selected indexes array keeps all of the indexPaths for cells that are "selected". The array is
    // used inside cellForItemAtIndexPath to lower the alpha of selected cells.  You can see how the array
    // works by searchign through the code for 'selectedIndexes'
    var selectedIndexes = [NSIndexPath]()
    
    //-Keep the changes. We will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    var cancelButton: UIBarButtonItem!
    
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("Hello Collection View Controller")
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "editButton")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addEvent")
        
        
        //-Manage Top and Bottom bar colors
        self.navigationController!.navigationBar.barTintColor = UIColor(red:0.66,green:0.97,blue:0.59,alpha:1.0)
        self.tabBarController?.tabBar.barTintColor = UIColor(red:0.66,green:0.97,blue:0.59,alpha:1.0)
        
        bottomButton.hidden = true
        
        //-Start the fetched results controller
        var error: NSError?
        fetchedResultsController.performFetch(&error)
        
        if let error = error {
            println("Error performing initial fetch: \(error)")
        }
        
        fetchedResultsController.delegate = self
        
        // Unarchive the event when the list is first shown
        self.events = NSKeyedUnarchiver.unarchiveObjectWithFile(eventsFilePath) as? [Events] ?? [Events]()
        println("self.events: \(self.events)")
        
        
    }
    
    
    //-Layout the collection view cells
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Lay out the collection view so that there are 3 cells accrosse
        // with white space in between.
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 3
        layout.minimumInteritemSpacing = 3
        
        let screenWidth = self.collectionView?.bounds.size.width
        let totalSpacing = layout.minimumInteritemSpacing * 3.0
        let imageSize = (screenWidth! - totalSpacing)/3.0
        layout.itemSize = CGSize(width: imageSize, height: imageSize)
        
        collectionView.collectionViewLayout = layout
        
    }
    
    
    //-Perform when view appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //-Archive the graph any time this list of events is displayed.
        NSKeyedArchiver.archiveRootObject(self.events, toFile: eventsFilePath)
        
        //-Hide the tab bar
        self.tabBarController?.tabBar.hidden = false
        
        editButtonFlag = true
        
        //-Brute Force Reload the scene to view collection updates
        self.collectionView.reloadData()
        
        
    }
    
    
    //-Reset the collection Edit view when the view disappears
    override func viewWillDisappear(animated: Bool) {
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "editButton")
        self.navigationItem.leftBarButtonItem = newBackButton
        bottomButton.hidden = true
        editButtonFlag = true
        
        
        var index : Int = 0
        for item in selectedIndexes{
            selectedIndexes.removeAtIndex(index)
        }
        
        
    }
    
    
    //    //-Add the "sharedContext" convenience property
    //    lazy var sharedContext: NSManagedObjectContext = {
    //        return CoreDataStackManager.sharedInstance().managedObjectContext!
    //        }()
    
    
    func editButton(){
        println("Hello Edit Button")
        
        if self.navigationItem.leftBarButtonItem?.title == "Done" {
            
            //-Recreate navigation Back button and change name to "Edit"
            
            self.navigationItem.hidesBackButton = true
            let newBackButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "editButton")
            self.navigationItem.leftBarButtonItem = newBackButton
            bottomButton.hidden = true
            editButtonFlag = true
            
        } else {
            
            //-Recreate navigation Back button and change name to "Done"
            self.navigationItem.hidesBackButton = true
            let newBackButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "editButton")
            self.navigationItem.leftBarButtonItem = newBackButton
            
            bottomButton.hidden = false
            editButtonFlag = false
            //updateBottomButton()
        }
    }
    
    
    //-UICollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        
//        //-Check to see if you have any events. If not, go directly to the Add Event Screen.
//        if sectionInfo.numberOfObjects == 0 {
//            
//            self.navigationItem.hidesBackButton = true
//            let newBackButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.Plain, target: self, action: "editButton")
//            self.navigationItem.leftBarButtonItem = newBackButton
//            bottomButton.hidden = true
//            
//            println("Collection Empty")
//            
//            let actionSheetController: UIAlertController = UIAlertController(title: "Zippo!", message: "No Events. Press OK to create an Event", preferredStyle: .Alert)
//            
//            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
//                
//                //let storyboard = self.storyboard
//                let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BeGoodAddEventViewController") as! BeGoodAddEventViewController
//                controller.editEventFlag = false
//                self.navigationController!.pushViewController(controller, animated: true)
//            }
//            actionSheetController.addAction(okAction)
//            
//            //-Present the AlertController
//            self.presentViewController(actionSheetController, animated: true, completion: nil)
//            
//        }
        
        return sectionInfo.numberOfObjects
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BeGoodCollectionViewCell", forIndexPath: indexPath) as! BeGoodCollectionViewCell

        configureCell(cell, atIndexPath: indexPath)
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if editButtonFlag == false {
            
            println("editButtonFlag: \(editButtonFlag)")
            
            let cell = collectionView.cellForItemAtIndexPath(indexPath) as! BeGoodCollectionViewCell
            
            //-Whenever a cell is tapped we will toggle its presence in the selectedIndexes array
            if let index = find(selectedIndexes, indexPath) {
                selectedIndexes.removeAtIndex(index)
            }
            else {
                selectedIndexes.append(indexPath)
            }
            
            // Then reconfigure the cell
            configureCell(cell, atIndexPath: indexPath)
            
            
            //-And update the buttom button
            //updateBottomButton()
            
        } else {
            
            println("editButtonFlag: \(editButtonFlag)")
            
            let controller =
            storyboard!.instantiateViewControllerWithIdentifier("BeGoodShowViewController") as! BeGoodShowViewController

            let event = fetchedResultsController.objectAtIndexPath(indexPath) as! Events

            controller.eventIndexPath = indexPath
            controller.eventIndex = indexPath.row
            
            self.navigationController!.pushViewController(controller, animated: true)
            
        }
        
    }
    
    //-Configure Cell
    func configureCell(cell: BeGoodCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        
        let event = fetchedResultsController.objectAtIndexPath(indexPath) as! Events
        
        //-Format the Date for the cell
        var dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle //Set time style
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle //Set date style
        dateFormatter.timeZone = NSTimeZone()
        
        cell.eventDateCellLabel!.text = dateFormatter.stringFromDate(event.eventDate!)
        println(cell.eventDateCellLabel!.text)
        
        let eventImage2 = event.eventImage
        let finalImage = UIImage(data: eventImage2!)
        cell.eventImageView!.image = finalImage
        
        if let index = find(self.selectedIndexes, indexPath) {
            cell.eventImageView!.alpha = 0.5
        } else {
            cell.eventImageView!.alpha = 1.0
        }
    }
    
    
    //-NSFetchedResultsController
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Events")
        //fetchRequest.predicate = NSPredicate(format: "pins == %@", self.pins);
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "textEvent", ascending: true)]
        //fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
        }()
    
    
    //-Fetched Results Controller Delegate
    
    // Whenever changes are made to Core Data the following three methods are invoked. This first method is used to
    // create three fresh arrays to record the index paths that will be changed.
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
        //println("in controllerWillChangeContent")
    }
    
    // The second method may be called multiple times, once for each picture object that is added, deleted, or changed.
    // We store the index paths into the three arrays.
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            //println("Insert an item")
            // Here we are noting that a new picture instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            //println("Delete an item")
            // Here we are noting that a picture instance has been deleted from Core Data. We keep remember its index
            // path so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath"
            // parameter has value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            //println("Update an item.")
            // We don't expect picture instances to change after they are created. But Core Data would
            // notify us of changes if any occured. This can be useful if you want to respond to changes
            // that come about after data is downloaded. For example, when an images is downloaded from
            // Flickr in the Virtual Tourist app
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            //println("Move an item. We don't expect to see this in this app.")
            break
        default:
            break
        }
    }
    
    // This method is invoked after all of the changed in the current batch have been collected
    // into the three index path arrays (insert, delete, and upate). We now need to loop through the
    // arrays and perform the changes.
    //
    // The most interesting thing about the method is the collection view's "performBatchUpdates" method.
    // Notice that all of the changes are performed inside a closure that is handed to the collection view.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        //println("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
    }
    
    
    //* - Click Button Decision function
    
    @IBAction func buttonButtonClicked() {
        
        deleteSelectedEvents()

    }
    
    //* - Delete All Pictures before adding new pictures function
    
    func deleteAllEvents() {
        
        for event in self.fetchedResultsController.fetchedObjects as! [Events] {
            
            self.sharedContext.deleteObject(event)
        }
        
    }
    
    //* - Delete Selected Picture function
    
    func deleteSelectedEvents() {
        var eventsToDelete = [Events]()
        
        for indexPath in selectedIndexes {
            eventsToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Events)
            
        }
        
        for event in eventsToDelete {
            sharedContext.deleteObject(event)
        }
        
        selectedIndexes = [NSIndexPath]()
        CoreDataStackManager.sharedInstance().saveContext()
        
        //-Archive the graph any time this list of events changes
        NSKeyedArchiver.archiveRootObject(self.events, toFile: eventsFilePath)
    }
    
    
    //* - Update the button label based on selection criteria
    
//    func updateBottomButton() {
//        if selectedIndexes.count > 0 {
//            //bottomButton.title = "Remove Selected Pictures"
//            bottomButton.titleLabel?.text = "Remove Selected Events"
//            
//            
//        } else {
//            //bottomButton.title = "New Collection"
//            bottomButton.titleLabel?.text = "Clear All Events"
//        }
//    }

    
    
    
    //Button Function - Create a New Event
    //@IBAction func addEventButton(sender: UIBarButtonItem) {
    func addEvent() {
        
        //let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BeGoodAddEventViewController") as! BeGoodAddEventViewController
        controller.editEventFlag = false
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    
    //-Saving the array. Helper.
    
    var eventsFilePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        println(url.URLByAppendingPathComponent("events").path!)
        return url.URLByAppendingPathComponent("events").path!
    }
    
}


