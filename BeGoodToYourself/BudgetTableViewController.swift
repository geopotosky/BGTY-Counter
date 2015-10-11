//
//  BudgetTableViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 10/10/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//

import UIKit

class BudgetTableViewController: UITableViewController {
    
    @IBOutlet weak var totalLabel: UILabel!
    
    //var tableData = ["iPhone 6 Plus Gold 128 GB", "iPhone 6 Plus Gold 64 GB", "iPhone 6 Plus Gold 16 GB", "iPhone 6 Gold 128 GB", "iPhone 6 Gold 64 GB", "iPhone 6 Gold 16 GB"]
    var tableData = ["iPhone 6 Plus Gold 128 GB", "iPhone 6 Plus Gold 64 GB", "iPhone 6 Plus Gold 16 GB", "Geo Phone 2"]
    
    var detailData = ["$1,079.00", "$949.88", "$811.99", "$909.00", "$846.00", "$736.00"]
    var detailNumbers = ["1.10","5.00","3.45", "3"]
    
    //var finalValue: Double! = 0.0
    
    @IBAction func editToTableData(segue:UIStoryboardSegue) {
        
        let detailViewController = segue.sourceViewController as! BudgetEditTableViewController
        
        let editedData = detailViewController.dataString
        
        //let changedPrice = String.localizedStringWithFormat("$%.2f", detailViewController.priceString!)
        let changedPrice = detailViewController.priceString
        
        let index = detailViewController.index
        
        tableData[index!] = editedData!
        
        //detailData[index!] = changedPrice!
        detailNumbers[index!] = changedPrice!
        
        
        tableView.reloadData()
    }
    
    @IBAction func saveToTableData(segue:UIStoryboardSegue) {
        
        let detailViewController = segue.sourceViewController as! BudgetAddTableViewController
        
        let editedData = detailViewController.dataString
        let changedPrice = detailViewController.priceString
        
        tableData.append(editedData!)
        detailNumbers.append(changedPrice!)
        
        tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //-Create buttons
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addBudgetList")
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //        println(detailNumbers.count)
        //        for value in detailNumbers{
        //
        //        }
        //
        //        if detailNumbers.count > 0 {
        //            var index : Int = 0
        //            for counter in detailNumbers{
        //
        //                //let counterInt = counter.toInt()!
        //                let counterInt = NSNumberFormatter().numberFromString(counter)?.doubleValue
        //                println(counter)
        //                println(counterInt)
        //                finalValue = finalValue + counterInt!
        //
        //            }
        //
        //            index++
        //        }
        //
        //        println("final value: \(finalValue)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        var finalValue: Float! = 0.0
        //var yourBudgetTotal: String!
        
        println(detailNumbers.count)
        for value in detailNumbers{
            
        }
        
        if detailNumbers.count > 0 {
            var index : Int = 0
            for counter in detailNumbers{
                
                //let counterInt = counter.toInt()!
                let counterInt = NSNumberFormatter().numberFromString(counter)?.floatValue
                println(counter)
                println(counterInt)
                finalValue = finalValue + counterInt!
                
                let runningTotal = 12.0
                let string = String(format:"%0.f", runningTotal)
                println(string)
                
                let value: Float = 0.30
                let unit: String = "mph"
                
                //let yourUILabel = String.localizedStringWithFormat("$%.2f %@", finalValue, unit)
                //                let yourBudgetTotal = String.localizedStringWithFormat("$%.2f", finalValue)
                //                println(yourBudgetTotal)
                
            }
            
            index++
        }
        //let finalValue2 = String(format: "$%4d", finalValue)
        println("final value: \(finalValue)")
        let totals: String = "Budget:"
        let yourBudgetTotal = String.localizedStringWithFormat("%@ $%.2f", totals, finalValue)
        println(yourBudgetTotal)
        totalLabel.text = yourBudgetTotal
        
        
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return tableData.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tableCell", forIndexPath: indexPath) as! UITableViewCell
        
        // Configure the cell...
        cell.textLabel?.text = tableData[indexPath.row]
        //cell.detailTextLabel?.text = detailData[indexPath.row]
        
        let newValue = NSNumberFormatter().numberFromString(detailNumbers[indexPath.row])?.floatValue
        cell.detailTextLabel?.text = String.localizedStringWithFormat("$%.2f", newValue!)
        //cell.detailTextLabel?.text = detailNumbers[indexPath.row]
        
        return cell
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "editBudget" {
            var path = tableView.indexPathForSelectedRow()
            var destination = segue.destinationViewController as! BudgetEditTableViewController
            destination.index = path?.row
            destination.data = tableData
            //destination.price = detailData
            destination.price = detailNumbers
        }
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    
    
    func addBudgetList(){
        println("Add to Budget")
        
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BudgetAddTableViewController") as! BudgetAddTableViewController
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
}

