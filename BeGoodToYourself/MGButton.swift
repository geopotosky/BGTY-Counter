//
//  MGButton.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 10/6/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//


import Foundation
import UIKit

//* - Create custom button
class MGButton: UIButton {
    required init(coder Decoder: NSCoder) {
        super.init(coder: Decoder)
        let borderColor = UIColor(red:0.0,green:0.5,blue:0.8,alpha:1.0)
        let buttonColor = UIColor(red:0.6,green:0.2,blue:0.9,alpha:0.4)
        //let buttonColor = UIColor(red:0.7,green:1.0,blue:0.6,alpha:1.0)
        //let buttonColor = UIColor.greenColor()
        self.layer.cornerRadius = 10.0;
        self.layer.borderColor = borderColor.CGColor
        self.layer.borderWidth = 1.5
        self.backgroundColor = UIColor.whiteColor()
        //self.backgroundColor = buttonColor
        self.tintColor = borderColor
    }
}