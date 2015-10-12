//
//  TodoAddTableViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 10/1/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//


import UIKit
import CoreData


class TodoAddTableViewController: UITableViewController {
    
    @IBOutlet weak var editModelTextField: UITextField!
    
//    var index:Int?
//    
//    var modelArray:[String]!
    var events: Events!
    
    var editedModel:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //-Table view data source
    
    // This one is also fairly easy. You can get the actor in the same way as cellForRowAtIndexPath above.
    override func tableView(tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath) {
            if indexPath.section == 0 && indexPath.row == 0 {
                editModelTextField.becomeFirstResponder()
            }
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    //-Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "save" {
            editedModel = editModelTextField.text
        }
        editedModel = editModelTextField.text

    }
    
    
}


