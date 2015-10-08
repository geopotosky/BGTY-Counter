//
//  SearchButton.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 10/8/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//

import Foundation
import UIKit

//* - Create custom button
class SearchButton: UIButton {
    required init(coder Decoder: NSCoder) {
        super.init(coder: Decoder)
        let borderColor = UIColor(red:0.6,green:1.0,blue:0.6,alpha:1.0)
        //let buttonColor = UIColor(red:0.6,green:0.9,blue:0.4,alpha:0.5)
        let buttonColor = UIColor.whiteColor()
        self.layer.cornerRadius = 7.0;
        self.layer.borderColor = borderColor.CGColor
        self.layer.borderWidth = 1.5
        self.backgroundColor = UIColor.whiteColor()
        self.backgroundColor = buttonColor
        self.tintColor = borderColor
    }
}
