//
//  ViewController.swift
//  ShopIt
//
//  Created by Nathan Thimothe on 3/28/20.
//  Copyright © 2020 Nathan Thimothe. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
 
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        if let logButton = loginButton, let signButton = signUpButton{
            Stylist.style(button: logButton, color: UIColor.link, titleColor: UIColor.white, borderColor: UIColor.link.cgColor)
            Stylist.style(button: signButton, color: UIColor.white, titleColor: UIColor.black, borderColor: UIColor.black.cgColor)
        }
    }
    
    
}
