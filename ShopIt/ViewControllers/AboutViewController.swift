//
//  AboutViewController.swift
//  ShopIt
//
//  Created by Nathan Thimothe on 4/11/20.
//  Copyright © 2020 Nathan Thimothe. All rights reserved.
//

import UIKit

class AboutViewController: ViewController {
    let info : String = "Nathan Thimothe is a college student who really cannot remember his shopping lists. Thus, from Nathan's desire to try his hand at iOS app development comes this very basic app with a very limited interface and capabilites. Nevertheless, please enjoy creating shopping lists and potentially streamlining your shopping experience."
    
    @IBOutlet weak var textField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "About"
        configureTextField()
    }
    
    func configureTextField() {
        // change UI as deemed necessary
        textField.isEditable = false
        textField.isScrollEnabled = true
        textField.textAlignment = NSTextAlignment(rawValue: 0)!
        textField.font = textField.font?.withSize(CGFloat(20.0))
        textField.text = info
    }
}
