//
//  ForgotPasswordViewController.swift
//  ShopIt
//
//  Created by Nathan Thimothe on 3/28/20.
//  Copyright © 2020 Nathan Thimothe. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate, UserEditable {
    
    @IBOutlet weak var resetEmailField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var resetButton: UIButton!
    
    var email : String {
        return resetEmailField.text ?? ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Forgot Password"
        resetEmailField.becomeFirstResponder()
        resetEmailField.delegate = self
    }
    /*
     Please enter the email that you remember signing up with to reset your password.
     */
    @IBAction func resetWasPressed(_ sender: Any){
        // IMPLEMENT WITH FIREBASE
        if pageIsValid(){
            setLoading(loading: true, activityIndicator: activityIndicator, textFields: [resetEmailField], buttons: [resetButton])
            sendPasswordReset()
            setLoading(loading: false, activityIndicator: activityIndicator, textFields: [resetEmailField], buttons: [resetButton])
        }
    }
    
    func sendPasswordReset() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if error != nil{
                self.displayError(errorLabel: self.errorLabel, error: "Could not send email. Please try again later!", fontSize: 16.0, fields: [self.resetEmailField])
            } else {
                print("Successfully sent email.")
                
                // display email sent alert
                let alert = UIAlertController(title: "Email Sent!", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                
                // pop this view controller from the navigation controller after 2 seocnds
                self.present(alert, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        // dismiss the alert
                        self.dismiss(animated: true, completion: nil)
                        // pop current view controller
                        self.navigationController?.popViewController(animated: true)
                        // pop the previous view controller as well
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                
            }
        } // end closure
    }

    // if there are no errors present on the page, return true, else false and display correct errors
    func pageIsValid() -> Bool {
        if email.isEmpty {
            displayError(errorLabel: errorLabel, error: "Please fill out the email field.", fontSize: 18.0, fields: [resetEmailField])
            print("ForgotPasswordViewController pageIsValid() is returning false: email field is empty")
            return false
        } else if !isValidEmail(email){
            displayError(errorLabel: errorLabel, error: "Please enter a valid email address.", fontSize: 18.0, fields: [resetEmailField])
            print("ForgotPasswordViewController pageIsValid() is returning false: not a valid email")
            return false
        }
        
        print("ForgotPasswordViewController pageIsValid() is returning true")
        return true
    }
    
    // checks if an email address is valid
    func isValidEmail(_ email: String) -> Bool{
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
       

    
 
    /* DESCRIBING TEXTFIELD BEHAVIOR UPON USER INTERACTION */
    // when user begins editing, change border color back to gray and remove any error message
    func textFieldDidBeginEditing(_ textField: UITextField) {
        changeBorderColors(fields: [resetEmailField], color: UIColor.gray)
        errorLabel.text = ""
    }
    
    // if user finishes editing emailField
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
