//
// Protocols.swift
//  ShopIt
//
//  Created by Nathan Thimothe on 5/4/20.
//  Copyright © 2020 Nathan Thimothe. All rights reserved.
//

import Foundation
import UIKit

protocol UserEditable {
    func displayError(errorLabel : UILabel, error: String, fontSize: Float, seconds: Float, fields: [UITextField])
    func changeBorderColors(fields : [UITextField], color: UIColor)
    func setLoading(loading : Bool, activityIndicator: UIActivityIndicatorView, textFields: [UITextField], buttons : [UIButton])
}

extension UserEditable{
    // change the border colors of given text fields
    func changeBorderColors(fields: [UITextField], color: UIColor) {
        for field in fields{
            field.layer.borderColor = color.cgColor
            field.layer.borderWidth = 1.0
        }
    }
    
    // animate a display of an erorr in an errorLabel; change border colors of textfield to red
    func displayError(errorLabel : UILabel, error: String, fontSize: Float = 14.0, seconds: Float = 5.8, fields: [UITextField]){
        errorLabel.alpha = 1
        // set text
        errorLabel.text = error
        // set text size
        errorLabel.font = errorLabel.font.withSize(CGFloat(fontSize))
        // UI Changes associated with incorrect text fields
        changeBorderColors(fields: fields, color: UIColor.red)
        UIView.animate(withDuration: TimeInterval(seconds)) {
            errorLabel.alpha = 0
        }
    }
    
    // Turn on or off the activity indicator.
    func setLoading(loading: Bool, activityIndicator: UIActivityIndicatorView, textFields: [UITextField], buttons : [UIButton]) {
        if loading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        for field in textFields {
            field.isEnabled = !loading
        }
        for button in buttons {
            button.isEnabled = !loading
        }
    }
    
    
}


