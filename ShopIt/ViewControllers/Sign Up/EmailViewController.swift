//
//  EmailViewController.swift
//  TestPlayground
//
//  Created by Nathan Thimothe on 3/25/20.
//  Copyright © 2020 Nathan Thimothe. All rights reserved.
//

import UIKit
import Firebase

class EmailViewController: UIViewController, UITextFieldDelegate, UserEditable{
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var emailInDatabase = false
    var email: String{
        return emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        emailField.becomeFirstResponder()
        emailField.delegate = self

    }
    
    // shouldPerformSegue should depend on whether there are no errors on the page
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool { return false }
    
    @IBAction func nextWasPressed(_ sender: Any) {
        evaluatePage()
    }
    
    func evaluatePage(){
        if pageIsValid() {
            // upon completion, move on and perform the segue
            moveOn(email: email) {
                self.performSegue(withIdentifier: "toPasswordViewController", sender: self)
            }
        }
    }

    func moveOn(email : String, completion:@escaping () -> () ) {
        // get reference to databse
        let ref = Database.database().reference().child("usernames")
        // remove forbidden characters from email
        let revisedEmail = revise(email)
        
        
        // observeSingleEvent is an async provess
        // check if there is a user registered with the given email, return true if so
        ref.observeSingleEvent(of: .value) { (snapshot) in
            // if the email is not present in the database, it is okay to segue
            if !(snapshot.hasChild(revisedEmail)){
                print("EmailViewController pageIsValid() is returning true: email is NOT present in database")
                // the important step has been done...
                completion()
            // if the email is present in the database there should be no segue
            } else {
                self.displayError(errorLabel: self.errorLabel, error: "A user is already registered with that email address.", fontSize: 16.0, fields: [self.emailField])
                print("EmailViewController pageIsValid() is returning false: email present in database")
            }
        }
    }
    
    // if there are no errors present on the page, return true, else false and display correct errors
    func pageIsValid() -> Bool {
        if email.isEmpty {
            displayError(errorLabel: errorLabel, error: "Email field is required.", fontSize: 18.0, fields: [emailField])
            print("EmailViewController pageIsValid() is returning false: email field is empty")
            return false
        }
        if !(isValidEmail(email)){
            displayError(errorLabel: errorLabel, error: "Please enter a valid email address.", fontSize: 18.0, fields: [emailField])
            print("EmailViewController pageIsValid() is returning false: not a valid email address")
            return false
        }
        print("EmailViewController pageIsValid() has a non-empty email and a 'valid' email address")
        return true
    }

    
    // checks a given email address against a regular expression
    func isValidEmail(_ email: String) -> Bool{
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    func revise(_ email : String) -> String{
        var revisedEmail = email
        revisedEmail.removeAll { (ch) -> Bool in
            return ch == "."
        }
        return revisedEmail
    }
    
    /* DESCRIBING TEXTFIELD BEHAVIOR UPON USER INTERACTION */
    // when user begins editing, change border color back to gray and remove any error message 
    func textFieldDidBeginEditing(_ textField: UITextField) {
        changeBorderColors(fields: [emailField], color: UIColor.gray)
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
        emailField.resignFirstResponder()
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let seg = segue.destination as! PasswordViewController
        seg.email = email
    }
    
}
