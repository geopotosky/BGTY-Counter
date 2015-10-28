//
//  BudgetTableViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 10/10/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//

import UIKit
import CoreData


class BudgetTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var totalLabel: UILabel!
    
    var events: Events!
    var eventIndexPath2: NSIndexPath!
    var eventIndex: Int!
    
    
    //var tableData = ["iPhone 6 Plus Gold 128 GB", "iPhone 6 Plus Gold 64 GB", "iPhone 6 Plus Gold 16 GB", "iPhone 6 Gold 128 GB", "iPhone 6 Gold 64 GB", "iPhone 6 Gold 16 GB"]
    //var tableData = ["iPhone 6 Plus Gold 128 GB", "iPhone 6 Plus Gold 64 GB", "iPhone 6 Plus Gold 16 GB", "Geo Phone 2"]
    
    //var detailData = ["$1,079.00", "$949.88", "$811.99", "$909.00", "$846.00", "$736.00"]
    //var detailNumbers = ["1.10","5.00","3.45", "3"]
    
    //var finalValue: Double! = 0.0
    
    @IBAction func editToTableData(segue:UIStoryboardSegue) {
        
        let detailViewController = segue.sourceViewController as! BudgetEditTableViewController
        
        //let editedData = detailViewController.dataString
        
        //let changedPrice = String.localizedStringWithFormat("$%.2f", detailViewController.priceString!)
        //let changedPrice = detailViewController.priceString
        
        //let index = detailViewController.index
        
        //tableData[index!] = editedData!
        
        //detailData[index!] = changedPrice!
        //detailNumbers[index!] = changedPrice!
        
        let budget = fetchedResultsController.objectAtIndexPath(tableView.indexPathForSelectedRow()!) as! Budget
        budget.itemBudgetText = detailViewController.dataString!
        budget.priceBudgetText = detailViewController.priceString!
        self.sharedContext.refreshObject(budget, mergeChanges: true)
        CoreDataStackManager.sharedInstance().saveContext()
        
        tableView.reloadData()
    }
    
    @IBAction func saveToTableData(segue:UIStoryboardSegue) {
        
        let detailViewController = segue.sourceViewController as! BudgetAddTableViewController
        
        let editedData = detailViewController.dataString
        let changedPrice = detailViewController.priceString
        println("saving....")
//        tableData.append(editedData!)
//        detailNumbers.append(changedPrice!)
        
        let budget = Budget(itemBudgetText:  editedData, priceBudgetText: changedPrice, context: self.sharedContext)
        budget.events = self.events
        CoreDataStackManager.sharedInstance().saveContext()
        
        tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //-Create buttons
        self.navigationController!.navigationBar.barTintColor = UIColor(red:0.66,green:0.97,blue:0.59,alpha:1.0)
        
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "cancelBudgetList")
        let newBackButton = UIBarButtonItem(title: "Event", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelBudgetList")
        self.navigationItem.leftBarButtonItem = newBackButton
        
        let b1 = self.editButtonItem()
        let b2 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addBudgetList")
        let buttons = [b2, b1] as NSArray
        self.navigationItem.rightBarButtonItems = [b2, b1]
        
        
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var finalValue: Float! = 0.0
        
        if events.budget.count > 0 {
            var index : Int = 0
            for counter in events.budget{
                let priceCount = counter.priceBudgetText
                let counterInt = NSNumberFormatter().numberFromString(priceCount!)?.floatValue
                finalValue = finalValue + counterInt!
            }
            index++
        }
        let totals: String = "Budget:"
        let yourBudgetTotal = String.localizedStringWithFormat("%@ $%.2f", totals, finalValue)
        totalLabel.text = yourBudgetTotal
        
        
    }
    
    
    //-Reset the Table Edit view when the view disappears
    override func viewWillDisappear(animated: Bool) {
        
        resetEditing(false, animated: false)
        
    }
    
    //-Force set editing toggle (delete line items)
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
    
    
    //-Reset the Table Edit view when the view disappears
    func resetEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
    
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    
    //-Fetch Budget data
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Budget")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "itemBudgetText", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "events == %@", self.events);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
        }()
    
    //-Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete method implementation.
//        // Return the number of rows in the section.
//        return tableData.count
//    }
    
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let CellIdentifier = "tableCell"
            
            let budget = fetchedResultsController.objectAtIndexPath(indexPath) as! Budget
            
            let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as!
            UITableViewCell
            
            configureCell(cell, withList: budget)
            
            return cell
    }

    
    override func tableView(tableView: UITableView,
        commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            
            switch (editingStyle) {
            case .Delete:
                
                //-Here we get the budget item, then delete it from core data
                let budget = fetchedResultsController.objectAtIndexPath(indexPath) as! Budget
                sharedContext.deleteObject(budget)
                CoreDataStackManager.sharedInstance().saveContext()
                
                //-Update Budget total on view
                var finalValue: Float! = 0.0
                if events.budget.count > 0 {
                    var index : Int = 0
                    for counter in events.budget{
                        let priceCount = counter.priceBudgetText
                        let counterInt = NSNumberFormatter().numberFromString(priceCount!)?.floatValue
                        finalValue = finalValue + counterInt!
                    }
                    index++
                }
                let totals: String = "Budget:"
                let yourBudgetTotal = String.localizedStringWithFormat("%@ $%.2f", totals, finalValue)
                totalLabel.text = yourBudgetTotal
                
                
            default:
                break
            }
    }
    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType) {
            
            switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                
            default:
                return
            }
    }
    
    //
    // This is the most interesting method. Take particular note of way the that newIndexPath
    // parameter gets unwrapped and put into an array literal: [newIndexPath!]
    //
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
            switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                
            case .Update:
                let cell = tableView.cellForRowAtIndexPath(indexPath!) as UITableViewCell!
                let budget = controller.objectAtIndexPath(indexPath!) as! Budget
                self.configureCell(cell, withList: budget)
                
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                
            default:
                return
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    
    func configureCell(cell: UITableViewCell, withList budget: Budget) {
        
        //cell.detailTextLabel?.text = detailData[indexPath.row]
        
        cell.textLabel?.text = budget.itemBudgetText
        let newValue = NSNumberFormatter().numberFromString(budget.priceBudgetText!)?.floatValue
        cell.detailTextLabel?.text = String.localizedStringWithFormat("$%.2f", newValue!)
        
    }

    
    
    
    //-Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "editBudget" {
            
            var path = tableView.indexPathForSelectedRow()
            var detailViewController = segue.destinationViewController as! BudgetEditTableViewController
            
            detailViewController.events = self.events
            detailViewController.budgetIndexPath = path
            detailViewController.budgetIndex = path?.row
            
        }
        
    }
    
    //-Add Budget item function
    func addBudgetList(){
        println("Add to Budget")
        
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BudgetAddTableViewController") as! BudgetAddTableViewController
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    //-Cancel Budget List item function
    func cancelBudgetList(){
        println("Cancel Budget List")
        
        var tmpController :UIViewController! = self.presentingViewController;
        
        self.dismissViewControllerAnimated(false, completion: {()->Void in
            println("done");
            tmpController.dismissViewControllerAnimated(false, completion: nil);
        });
        
    }
    
}

