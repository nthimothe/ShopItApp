//
//  PasswordViewController.swift
//  TestPlayground
//
//  Created by Nathan Thimothe on 3/25/20.
//  Copyright © 2020 Nathan Thimothe. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class PasswordViewController: UIViewController, UITextFieldDelegate, UserEditable {
    var email : String = ""
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var eightChars: UILabel!
    @IBOutlet weak var uppercaseLetter: UILabel!
    @IBOutlet weak var symbol: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    var password : String {
        return passwordField.text ?? ""
    }
    
    var confirmedPassword : String {
        return confirmPasswordField.text ?? ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        passwordField.becomeFirstResponder()
        passwordField.delegate = self
        confirmPasswordField.delegate = self
    }
    
    
    @IBAction func signUpWasPressed(_ sender: Any) {
        createUser()
    }
    
    // Turn on or off the activity indicator.
    func setLoading(_ loading: Bool) {
        if loading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        passwordField.isEnabled = !loading
        confirmPasswordField.isEnabled = !loading
        signUpButton.isEnabled = !loading
    }
    
    func createUser(){
        if !pageIsValid(){
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            self.setLoading(true);
            // if there is an error
            if error != nil{
                // Auth error: user already exists? Try logging in as that user.
                print("\nLogin failed: \(String(describing: error))\n");
                
                // UI Changes associated with incorrect fields
                
                self.displayError(errorLabel: self.errorLabel, error: "Either the username or password provided is incorrect.", fields: [self.passwordField])
 
            }
            else {
                print("Successfully creating user with Firebase!\n\temail: \(self.email)\n\tUser ID: \(String(describing: Auth.auth().currentUser?.uid))\n\n*******\n")
                self.writeEmailToDatabase(self.revise(self.email))
                self.transitionToHome()
            }
        }
    }
    
    func writeEmailToDatabase(_ email: String){
        let ref =  Database.database().reference()
        ref.child("usernames").child(email).setValue("")
    }
    
     func revise(_ email : String) -> String{
         var revisedEmail = email
         revisedEmail.removeAll { (ch) -> Bool in
             return ch == "."
         }
         return revisedEmail
     }
    
    // make the welcome VC the root view controller
    func transitionToHome(){
        let welcome = storyboard?.instantiateViewController(identifier: Constants.Storyboard.welcomeViewController)
        view.window?.rootViewController = welcome
        view.window?.makeKeyAndVisible()
    }

    
    // if there are no errors present on the page, return true, else false and display correct errors
    func pageIsValid() -> Bool {
        if password.isEmpty || confirmedPassword.isEmpty{
            displayError(errorLabel: errorLabel, error: "Both fields are required.", fontSize: 18.0, fields: [passwordField, confirmPasswordField])
            print("PasswordViewController pageIsValid() is returning false: a field is empty")
            return false
        }
        if password != confirmedPassword {
            displayError(errorLabel: errorLabel, error: "Passwords do not match.", fontSize: 18.0, fields: [passwordField, confirmPasswordField])
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


