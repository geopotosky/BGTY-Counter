//
//  BeGoodPickdateViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 9/20/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//

import UIKit

//protocol SecondVCDelegate {
//    func didFinishSecondVC(controller: BeGoodPickdateViewController)
//}

class BeGoodPickdateViewController: UIViewController {
    
    @IBOutlet weak var myDatePicker: UIDatePicker!
    @IBOutlet weak var pickDateButton: UIButton!
    @IBOutlet weak var eventDateLabel: UILabel!
    
    //var delegate: SecondVCDelegate! = tempEventDate
    
    var timeAtPress = NSDate()
    var currentDateWithOffset = NSDate()
    
    var count = 15
    
    var eventText: String!
    
    //* - Flag passed to determine editing function (add or edit). This flag allows reuse of the AddEvent view
    var editEventFlag2: Bool!
    
    var pickEventDate: NSDate!
    var currentEventDate: NSDate!
    
    //var delegate: SecondVCDelegate! = nil
    
    //    var offset: Float
    //    var systemTimeZone = NSTimeZone()
    
    //    let offset = secondsFromGMTForDate(systemTimeZone) / 3600.0
    //    float offset = [timezone secondsFromGMTForDate:self.date] / 3600.0;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

//        let date1 = NSDate()
//        let calendar = NSCalendar.currentCalendar()
//        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond, fromDate: date1)
//        let hour1 = components.hour
//        let minutes1 = components.minute
//        let seconds1 = components.second
//        println(calendar)
//        println(components)
//        println(hour1)
//        println(minutes1)
//        println(seconds1)
//        println("----------------")
        
        let elapsedTime = pickerDate.timeIntervalSinceDate(timeAtPress)  //* Event Date in seconds raw
        let durationSeconds = Int(elapsedTime)
        let durationMinutes = durationSeconds / 60
        let durationHours = (durationSeconds / 60) / 60
        let durationDays = ((durationSeconds / 60) / 60) / 24
        let durationWeeks = (((durationSeconds / 60) / 60) / 24) / 7
        
//        println(timeAtPress)
//        println(elapsedTime)
//        println("\(durationSeconds) seconds")
//        println("\(durationMinutes) minutes")
//        println("\(durationHours) hours")
//        println("\(durationDays) days")
//        println("\(durationWeeks) weeks")
        
//        count = durationSeconds
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func pickEventDate(sender: UIButton) {
        println("pickEventDate Button selected")
        
        if editEventFlag2 == true {
            let controller = self.navigationController!.viewControllers[2] as! BeGoodAddEventViewController
            //* - Forward selected event date to previous view
            controller.currentEventDate = myDatePicker.date
            self.navigationController?.popViewControllerAnimated(true)
            
        } else {
            let controller = self.navigationController!.viewControllers[1] as! BeGoodAddEventViewController
            //* - Forward selected event date to previous view
            controller.currentEventDate = myDatePicker.date
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
}


