//
//  BudgetAddTableViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 10/10/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//

import UIKit
import CoreData


class BudgetAddTableViewController: UITableViewController, UITextFieldDelegate {
    
    //-View Outlets
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    
    //-Global objects, properties & variables
    var events: Events!
    var dataString:String?
    var priceString:String?
    
    //set the textfield delegates
    let priceTextDelegate = PriceTextDelegate()
    
    
    //-Perform when view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-Textfield delegate values
        self.priceTextField.delegate = priceTextDelegate
    }
    
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "saveDataAdd" {
            dataString = textField.text
            priceString = priceTextField.text
        }
        println("Segue Error")
    }

    
    
}
