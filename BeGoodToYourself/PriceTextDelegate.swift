//
//  PriceTextDelegate.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 10/10/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//

import Foundation
import UIKit

class PriceTextDelegate: NSObject, UITextFieldDelegate {
    
    //Ask the delegate if the textfield should change
    //    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    //
    //        var newText: NSString = textField.text
    //        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
    //        return true;
    //    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // return false to not change text
        // return true to accept change
        
        //What will be the final string
        let newString = textField.text! + string
        
        let array = Array(newString)
        var pointCount = 0 //count the decimal separator
        var unitsCount = 0 //count units
        var decimalCount = 0 // count decimals
        
        for character in array { //counting loop
            if character == "." {
                pointCount++
            } else {
                if pointCount == 0 {
                    unitsCount++
                } else {
                    decimalCount++
                }
            }
        }
        if unitsCount > 5 { return false } // units maximum : here 2 digits
        if decimalCount > 2 { return false } // decimal maximum
        switch string {
        case "0","1","2","3","4","5","6","7","8","9": // allowed characters
            return true
        case ".": // block to one decimal separator to get valid decimal number
            if pointCount > 1 {
                return false
            } else {
                return true
            }
        default: // manage delete key
            let array = Array(string)
            if array.count == 0 {
                return true
            }
            unitsCount--
            return false
        }
    }
    
    //    //Let the delegate know that editing has begun
    //    func textFieldDidBeginEditing(textField: UITextField) {
    //
    //        //Check to see if the initial value of the textfield is TOP. If it is, clear it.
    //        if textField.text == "Enter Event Description" {
    //            textField.text = ""
    //        }
    //
    //    }
    
    //Ask the delegate if the RETURN key should be processed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
    
    
}

