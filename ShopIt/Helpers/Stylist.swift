//
//  Stylist.swift
//  ShopIt
//
//  Created by Nathan Thimothe on 10/13/20.
//  Copyright © 2020 Nathan Thimothe. All rights reserved.
//

import Foundation
import UIKit
class Stylist{
    /**
     Styles a button according to given parameters.
     - Parameters:
        - button : the button to be styled
        - color : background color to be set
     */
    static func style(button: UIButton, color: UIColor, titleColor: UIColor, borderColor: CGColor){
        button.layer.borderWidth = 1
        button.setTitleColor(titleColor, for: UIControl.State.normal)
        button.layer.borderColor = borderColor
        button.backgroundColor = color
        // button has layer because it inherits from UIView
        button.layer.cornerRadius = 15
        button.tintColor = UIColor.black
    }
    
}
