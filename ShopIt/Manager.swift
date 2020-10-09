//
//  Manager.swift
//  ShopIt
//
//  Created by Nathan Thimothe on 4/11/20.
//  Copyright © 2020 Nathan Thimothe. All rights reserved.
//

import Foundation
import UIKit
class Manager {
    
    static func updateRootVC(status : Bool) {
        let rootVC : UIViewController?
        
        if status{
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "")
        } else{
           rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "rootView")
        }
        let sceneDel = SceneDelegate()
        sceneDel.window?.rootViewController = rootVC
    }
    
    
}
