//
//  ChangePasswordViewController.swift
//  ShopIt
//
//  Created by Nathan Thimothe on 4/11/20.
//  Copyright © 2020 Nathan Thimothe. All rights reserved.
//

import UIKit
import Firebase

class ChangePasswordViewController: ViewController, UITextFieldDelegate, UserEditable {
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var eightChars: UILabel!
    @IBOutlet weak var uppercaseLetter: UILabel!
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var changePasswordButton: UIButton!
    
    
    var password : String {
        return passwordField.text ?? ""
    }
    
    var confirmedPassword : String {
        return confirmPasswordField.text ?? ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Change Password"
        passwordField.becomeFirstResponder()
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        errorLabel.text = ""
        Stylist.style(button: changePasswordButton, color: UIColor.link, titleColor: UIColor.white, borderColor: UIColor.link.cgColor)
    }

    
    @IBAction func changeButtonWasPressed(_ sender: Any) {
        if pageIsValid(){
            setLoading(loading: true, activityIndicator: activityIndicator, textFields: [passwordField,confirmPasswordField], buttons: [changePasswordButton])
            changePassword()
            setLoading(loading: false, activityIndicator: activityIndicator, textFields: [passwordField,confirmPasswordField], buttons: [changePasswordButton])
        }
    }
    
    
    // change password
    func changePassword() {
        Auth.auth().currentUser?.updatePassword(to: password) { (error) in
            if error != nil {
                self.displayError(error: "Something went wrong changing your password. Please try again later.")
            }
            else{
                let alert = UIAlertController(title: "Password Changed!", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action) in
                    self.navigationController?.popViewController(animated: true)
                }))
                // dismiss the alert in two seconds and pop the view controller from the nav controller
                self.present(alert, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.dismiss(animated: true, completion: nil)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }

    

    // if there are no errors present on the page, return true, else false and display correct errors
    func pageIsValid() -> Bool {
        if password.isEmpty || confirmedPassword.isEmpty{
            displayError(error: "Both fields are required.", fontSize: 18.0)
            print("PasswordViewController pageIsValid() is returning false: a field is empty")
            return false
        }
        if password != confirmedPassword {
            displayError(error: "Passwords do not match.", fontSize: 18.0)
            print("PasswordViewController pageIsValid() is returning false: passwords do not match")
            return false
        }
        if password.count < 8  {
            eightChars.textColor = UIColor.red
            print("******PasswordViewController pageIsValid() is returning false: password is less than 8 chars")
        }
        if !(containsUpperCaseLetter(password)){
            uppercaseLetter.textColor = UIColor.red
            print("******PasswordViewController pageIsValid() is returning false: password has no uppercase letter")
        }
        if !(containsSymbol(password)){
            symbol.textColor = UIColor.red
            print("******PasswordController pageIsValid() is returning false: password does not contain symbol")
        }
        if !(containsSymbol(password)) ||  !(containsUpperCaseLetter(password)) || password.count < 8{
            return false
        }
        print("PasswordViewController pageIsValid() is returning true")
        return true
    }
    
    func containsUpperCaseLetter(_ password : String) -> Bool {
        for char in password{
            if char.isUppercase {
                return true
            }
        }
        return false
    }
    
    func containsSymbol(_ password : String) -> Bool {
        for char in password{
            if char.isPunctuation {
                return true
            }
        }
        return false
    }
    
    // change the border color and width of [UITextField]
    func changeBorderColors(_ UITextFields : [UITextField], color: UIColor) {
        for field in UITextFields{
            field.layer.borderColor = color.cgColor
            field.layer.borderWidth = 1.0
        }
    }
    
    // animate a display of an erorr in errorLabel; change border colors of textfield
    func displayError(error: String, fontSize: Float = 14.0, seconds: Float = 5.8){
        errorLabel.alpha = 1
        // set text
        errorLabel.text = error
        // set text size
        errorLabel.font = errorLabel.font.withSize(CGFloat(fontSize))
        // UI Changes associated with incorrect fields
        changeBorderColors([passwordField, confirmPasswordField], color: UIColor.red)
        UIView.animate(withDuration: TimeInterval(seconds)) {
            self.errorLabel.alpha = 0
        }
    }
    
    /* DESCRIBING TEXTFIELD BEHAVIOR UPON USER INTERACTION */
    // when user begins editing, change border color back to gray and remove any error message
    func textFieldDidBeginEditing(_ textField: UITextField) {
        changeBorderColors([passwordField, confirmPasswordField], color: UIColor.gray)
        eightChars.textColor = UIColor.gray
        uppercaseLetter.textColor = UIColor.gray
        symbol.textColor = UIColor.gray
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
        view.endEditing(true)
    }

}
