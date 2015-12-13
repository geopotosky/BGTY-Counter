//
//  ActivitySquare.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 12/3/15.
//  Copyright © 2015 GeoWorld. All rights reserved.
//

import Foundation
import UIKit

//* - Create custom button
class ActivitySquare: UIButton {
    required init?(coder Decoder: NSCoder) {
        super.init(coder: Decoder)
        //let borderColor = UIColor(red:0.6,green:1.0,blue:0.6,alpha:1.0)
        let borderColor = UIColor.clearColor()
        let buttonColor = UIColor(red:0.0,green:0.51,blue:0.83,alpha:1.0)
        self.layer.cornerRadius = 12.0;
        self.layer.borderColor = borderColor.CGColor
        self.layer.borderWidth = 1.5
        self.backgroundColor = buttonColor
        self.tintColor = borderColor
    }
}