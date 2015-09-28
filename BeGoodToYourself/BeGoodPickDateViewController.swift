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
    @IBOutlet weak var selectedDate: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var CountDownDescription: UILabel!
    @IBOutlet weak var pickDateButton: UIButton!
    
    //var delegate: SecondVCDelegate! = tempEventDate
    
    var timeAtPress = NSDate()
    var currentDateWithOffset = NSDate()
    
    var count = 15
    
    var eventText: String!
    
    //* - Flag passed to determine editing function (add or edit). This flag allows reuse of the AddEvent view
    var editEventFlag2: Bool!
    
    var pickEventDate: NSDate!
    var tempEventDate: NSDate!
    
    //var delegate: SecondVCDelegate! = nil
    
    //    var offset: Float
    //    var systemTimeZone = NSTimeZone()
    
    //    let offset = secondsFromGMTForDate(systemTimeZone) / 3600.0
    //    float offset = [timezone secondsFromGMTForDate:self.date] / 3600.0;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
        eventText = "until our NEXT WDW Vaction!"
        
        println("Pickdate viewDidLoad")
        
    }
    
    @IBAction func datePickerAction(sender: AnyObject) {
        
        var dateFormatter = NSDateFormatter()
        //dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        
        //        var strDate = dateFormatter.stringFromDate(myDatePicker.date)
        //        self.selectedDate.text = strDate
        let pickerDate = myDatePicker.date
        //        println("pickerDate", pickerDate) //* Future Date and Time  *//
        //        println(NSDate())   //* Current Date and Time *//
        
        //        let nowDate = NSDate()  //* Current Date and Time *//
        
        //*-----------------------------------*//
        
        let date = NSDate()
        let timeZone = NSTimeZone(name: "Local")
        
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateNew = dateFormatter.stringFromDate(date)
        
        println("-------------------")
        println("TEST", dateNew)
        
        
        //*-----------------------------------*//
        
        
        //        NSDate *currentDateWithOffset = [NSDate dateWithTimeIntervalSinceNow:[[NSTimeZone localTimeZone] secondsFromGMT]];
        //        let currentDateWithOffset =
        
        //let date = NSDate()
        //let dateFormatter = NSDateFormatter()
        //To prevent displaying either date or time, set the desired style to NoStyle.
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
        dateFormatter.timeZone = NSTimeZone()
        println(dateFormatter.timeZone)
        
        let localDate = dateFormatter.stringFromDate(date)
        let strDate = dateFormatter.stringFromDate(myDatePicker.date)
        //self.selectedDate.text = strDate
        self.tempEventDate = myDatePicker.date
        
        println("UTC Time")
        println(date)
        println("Local Time")
        println(localDate)
        
        println("----------------")
        let date1 = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute | .CalendarUnitSecond, fromDate: date1)
        let hour1 = components.hour
        let minutes1 = components.minute
        let seconds1 = components.second
        println(calendar)
        println(components)
        println(hour1)
        println(minutes1)
        println(seconds1)
        println("----------------")
        
        let elapsedTime = pickerDate.timeIntervalSinceDate(timeAtPress)  //* Event Date in seconds raw
        let durationSeconds = Int(elapsedTime)
        let durationMinutes = durationSeconds / 60
        let durationHours = (durationSeconds / 60) / 60
        let durationDays = ((durationSeconds / 60) / 60) / 24
        let durationWeeks = (((durationSeconds / 60) / 60) / 24) / 7
        
        println(timeAtPress)
        println(elapsedTime)
        println("\(durationSeconds) seconds")
        println("\(durationMinutes) minutes")
        println("\(durationHours) hours")
        println("\(durationDays) days")
        println("\(durationWeeks) weeks")
        
        count = durationSeconds
        
        //        let newValue = pickerDate.dateByAddingTimeInterval(60*24)
        //        let newValueSeconds = pickerDate * 60
        //        let newValueSeconds = pickerDate.date
        //        println("newValue:", newValue)
        
        //        let nowDate = NSDate()
        //        let daysToAdd = 1;
        //        newDate1 = dateByAddingTimeInterval(:60*60*24*daysToAdd];
        
        
        //        let newValue = pickerDate - NSDate()
        
        //        let secondsPickerDate = pickerDate.dateByAddingTimeInterval()
        //        pickerDate = pickerDate.dateByAddingTimeInterval(<#ti: NSTimeInterval#>)
        //        println(pickerDate)
        
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
            controller.tempEventDate2 = myDatePicker.date
            println("controller.tempEventDate2: \(controller.tempEventDate2)")
            self.navigationController?.popViewControllerAnimated(true)
            
        } else {
            let controller = self.navigationController!.viewControllers[1] as! BeGoodAddEventViewController
            //* - Forward selected event date to previous view
            controller.tempEventDate2 = myDatePicker.date
            println("controller.tempEventDate2: \(controller.tempEventDate2)")
            self.navigationController?.popViewControllerAnimated(true)
        }
    
    }

    //* - Countdown Time Viewer
    func update() {
        
        if(count > 0)
        {
            count = count - 1
            let minutes:Int = (count / 60)
            let hours:Int = ((count / 60) / 60) % 24
            let days:Int = ((count / 60) / 60) / 24
            let seconds:Int = count - (minutes * 60)
            let minutes2:Int = (count / 60) % 60
            
            let timerOutput = String(format: "%5d Days %2d:%2d:%02d", days, hours, minutes2, seconds) as String
            countDownLabel.text = timerOutput as String
            CountDownDescription.text = eventText
        }
        
    }
    
}


