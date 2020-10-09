//
//  UsernameViewController.swift
//  TestPlayground
//
//  Created by Nathan Thimothe on 3/25/20.
//  Copyright © 2020 Nathan Thimothe. All rights reserved.
//

import UIKit


class UsernameViewController: UIViewController, UITextFieldDelegate, UserEditable{
    var email : String = ""
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var username: String {
        return usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        usernameField.becomeFirstResponder()
        usernameField.delegate = self
    }
    
    @IBAction func nextWasPressed(_ sender: Any) {
        print("\n\nNEXT WAS PRESSED")
        if pageIsValid(){
            self.performSegue(withIdentifier: "toPasswordViewController", sender: self)
        }
    }
    
    
    // only move on if nextWasPressed performs the segue
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool { return false
    }
    
    // if there are no errors present on the page, return true, else false and display correct errors
    func pageIsValid() -> Bool {
        if username.isEmpty {
            displayError(errorLabel: errorLabel, error: "Username field is required", fontSize: 18.0, fields: [usernameField])
            print("UsernameviewController pageIsValid() is returning false: username field is empty")
            return false
        }
        if !(isValid(username)) {
            displayError(errorLabel: errorLabel, error: "Please create a username without any symbols.", fontSize: 16.0, fields: [usernameField])
            print("UsernameviewController pageIsValid() is returning false: username field contains symbol")
            return false
        }
        if (usernameInDataBase(username)){
            displayError(errorLabel: errorLabel, error: "That username is already taken", fontSize: 18.0, fields: [usernameField])
            print("UsernameViewController pageIsValid() is returning false: username is already in database")
            return false
        }
        
        print("UsernameViewController pageIsValid() is returning true")
        return true
    }
    
    func usernameInDataBase(_ username: String) -> Bool {
        // IMPLEMENT THIS
        return false
    }
    
    func isValid(_ username: String) -> Bool{
        for char in username {
            // if the username contains a char that's not a letter, period, number, or underscore, then the username is not valid
            if !(char.isLetter) && (char != ".") && !(char.isWholeNumber) && (char != "_") {
                return false
            }
        }
        return true
    }
    
    
    /* DESCRIBING TEXTFIELD BEHAVIOR UPON USER INTERACTION */
    
    // when user begins editing, change border color back to gray and remove any error message
    func textFieldDidBeginEditing(_ textField: UITextField) {
        changeBorderColors(fields: [usernameField], color: UIColor.gray)
        errorLabel.text = ""
    }
    
    // if user stops editing emailField
    func textFieldDidEndEditing(_ textField: UITextField) {
        _ = pageIsValid()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with
        event: UIEvent?) {
        usernameField.resignFirstResponder()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let seg = segue.destination as! PasswordViewController
        seg.email = email
        // Pass the selected object to the new view controller.
    }
    
    
}
