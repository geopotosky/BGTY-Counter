//
//  BeGoodPickDateViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 9/20/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//

import UIKit

class BeGoodPickDateViewController: UIViewController {
    
    //-Class outlets
    @IBOutlet weak var myDatePicker: UIDatePicker!
    @IBOutlet weak var pickDateButton: UIButton!
    @IBOutlet weak var eventDateLabel: UILabel!
    
    //-Global variables
    var timeAtPress = NSDate()
    var currentEventDate: NSDate!
    var eventText: String!
    
    //-Flag passed to determine editing function (add or edit). This flag allows reuse of the AddEvent view
    var editEventFlag2: Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-Set Navbar Title
        self.navigationItem.title = "Date Picker"
        
        //-Preset the event date is editing an existing event
        //-Otherwise set the current date
        if editEventFlag2 == true {
            
            var dateFormatter = NSDateFormatter()
            
            //-Set the selected event date
            myDatePicker.date = currentEventDate
            
            let date = NSDate()
            let timeZone = NSTimeZone(name: "Local")
            dateFormatter.timeZone = timeZone
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateNew = dateFormatter.stringFromDate(date)
            dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
            dateFormatter.timeZone = NSTimeZone()
            let localDate = dateFormatter.stringFromDate(date)
            let strDate = dateFormatter.stringFromDate(myDatePicker.date)
            self.eventDateLabel.text = strDate
        }
        else {
            var dateFormatter = NSDateFormatter()
            
            let date = NSDate()
            let timeZone = NSTimeZone(name: "Local")
            dateFormatter.timeZone = timeZone
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateNew = dateFormatter.stringFromDate(date)
            dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
            dateFormatter.timeZone = NSTimeZone()
            let localDate = dateFormatter.stringFromDate(date)
            let strDate = dateFormatter.stringFromDate(myDatePicker.date)
            self.eventDateLabel.text = localDate
        }
        
        
    }
    
    //-Date Picker function
    @IBAction func datePickerAction(sender: AnyObject) {
        
        var dateFormatter = NSDateFormatter()
        
        let pickerDate = myDatePicker.date
        
        let date = NSDate()
        let timeZone = NSTimeZone(name: "Local")
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateNew = dateFormatter.stringFromDate(date)
        //-To prevent displaying either date or time, set the desired style to NoStyle.
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
        dateFormatter.timeZone = NSTimeZone()
        println(dateFormatter.timeZone)
        
        let localDate = dateFormatter.stringFromDate(date)
        let strDate = dateFormatter.stringFromDate(myDatePicker.date)
        self.eventDateLabel.text = strDate
        self.currentEventDate = myDatePicker.date
        
    }
    
    
    //-Choose the popViewController level (1 or 2) based on whether the user is adding a new event or editing an
    //-existing event
    @IBAction func pickEventDate(sender: UIButton) {
        
        if editEventFlag2 == true {
            let controller = self.navigationController!.viewControllers[2] as! BeGoodAddEventViewController
            //-Forward selected event date to previous view
            controller.currentEventDate = myDatePicker.date
            self.navigationController?.popViewControllerAnimated(true)
            
        } else {
            let controller = self.navigationController!.viewControllers[1] as! BeGoodAddEventViewController
            //-Forward selected event date to previous view
            controller.currentEventDate = myDatePicker.date
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
}



