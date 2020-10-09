//
//  LoginViewController.swift
//  TestPlayground
//
//  Created by Nathan Thimothe on 3/25/20.
//  Copyright © 2020 Nathan Thimothe. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI

// FUIAuthDelegate handles callback for authentication
class LoginViewController: UIViewController, UITextFieldDelegate, FUIAuthDelegate, UserEditable{
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    var username: String? {
        get {
            return usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }
    }
    
    var password: String? {
        get {
            return passwordField.text
        }
    }
    
    var authUI : FUIAuth?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField?.becomeFirstResponder()
        usernameField?.delegate = self
        passwordField?.delegate = self
        activityIndicator?.stopAnimating()
        
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        let providers : [FUIAuthProvider] = [FUIGoogleAuth()]
        authUI?.providers = providers
    }
    
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return true
    }
    
    // if the login button is pressed, catch any errors and log in
    @IBAction func loginWasPressed(_ sender: Any) {
        signIn(username: username!, password: password!)
    }
    
    
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        // if there is no error...
        if error == nil {
            print("SUCCESSFULLY LOGGED IN!!!")
        }
        
    }
    // Log in with the username and password, optionally registering a user.
    func signIn(username: String, password: String) {
        setLoading(loading: true, activityIndicator: activityIndicator, textFields: [usernameField, passwordField], buttons: [loginButton,forgotPasswordButton])
        
        changeBorderColors(fields: [usernameField, passwordField], color: UIColor.gray)
        Auth.auth().signIn(withEmail: username, password: password) { (user, err) in
   
            // if there is an error...
            if err != nil{
                // Auth error: user already exists? Try logging in as that user.
                print("\nLogin failed: \(String(describing: err))\n");
                // UI Changes associated with incorrect fields
                self.displayError(errorLabel: self.errorLabel, error: "Either the username or password provided is incorrect.", fields: [self.usernameField,self.passwordField])
                // if there are no errors,
            } else {
                print("Firebase login succeeded as \(String(describing: Auth.auth().currentUser))!")
                self.self.setLoading(loading: false, activityIndicator: self.activityIndicator, textFields: [self.usernameField, self.passwordField], buttons: [self.loginButton])
                self.transitionToHome()
            }
        } // CLOSE CLOSURE
        setLoading(loading: false, activityIndicator: activityIndicator, textFields: [usernameField, passwordField], buttons: [loginButton,forgotPasswordButton])
    }
    
    func transitionToHome() {
        let welcome = storyboard?.instantiateViewController(identifier: Constants.Storyboard.welcomeViewController)
        
        view.window?.rootViewController = welcome
        
        view.window?.makeKeyAndVisible()
    }
    
    // if there are no errors present on the page, return true, else false and display correct errors
    func pageIsValid() -> Bool {
        if username!.isEmpty || password!.isEmpty{
            displayError(errorLabel: errorLabel, error: "Both fields are required.", fontSize: 17.0, fields: [usernameField,passwordField])
            print("LoginViewController pageIsValid() is returning false: username field is empty and so was password.")
            return false;
        }
        print("LoginViewController pageIsValid() is returning true")
        return true
    }
    
    
    
    /* DESCRIBING TEXTFIELD BEHAVIOR UPON USER INTERACTION */
    
    // when user begins editing, change border color back to gray and remove any error message
    func textFieldDidBeginEditing(_ textField: UITextField) {
        changeBorderColors(fields: [usernameField,passwordField], color: UIColor.gray)
        errorLabel.text = ""
    }
    
    // if user stops editing emailField
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == passwordField {
            _ = pageIsValid()
        }
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



