//
//  BudgetEditTableViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 10/10/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//

import UIKit
import CoreData

class BudgetEditTableViewController: UITableViewController, UITextFieldDelegate, NSFetchedResultsControllerDelegate {
    
    
    var events: Events!
    
    var budgetIndexPath: NSIndexPath!
    var budgetIndex: Int!
    
    
    //var data:[String]!
    
    //var price:[String]!
    
    //var index:Int?
    
    var dataString:String?
    var priceString:String?
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    
    //set the textfield delegates
    let priceTextDelegate = PriceTextDelegate()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-Textfield delegate values
        self.priceTextField.delegate = priceTextDelegate
        
        fetchedResultsController.performFetch(nil)
        fetchedResultsController.delegate = self
        
        let budget = fetchedResultsController.objectAtIndexPath(budgetIndexPath) as! Budget
        textField.text = budget.itemBudgetText
        priceTextField.text = budget.priceBudgetText
        
//        var item = data[index!]
//        textField.text = item
//        
//        var amount = price[index!]
//        priceTextField.text = amount

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    
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
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            textField.becomeFirstResponder()
        }
        else if indexPath.section == 1 && indexPath.row == 0 {
            priceTextField.becomeFirstResponder()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    
    //-Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "saveDataEdit" {
            dataString = textField.text
            priceString = priceTextField.text
        }
//        dataString = textField.text
//        priceString = priceTextField.text
        
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    
    
}

