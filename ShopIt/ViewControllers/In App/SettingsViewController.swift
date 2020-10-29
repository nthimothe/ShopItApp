//
//  SettingstViewController.swift
//  ShopIt
//
//  Created by Nathan Thimothe on 3/31/20.
//  Copyright © 2020 Nathan Thimothe. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UITableViewController {
    let data = [ ["Account","Change Password", "Delete Account"],
                 ["Help","Help & FAQ"],
                 ["About The App","About the Programmer"] ]
    
    // storyIDs array to correspond to the elements of each array in data
    let storyIDs = ["changePass", "helpFAQ","aboutProgrammer"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(data.count)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // the count of an internal array in the global 2D array) -1 determines the number of rows in a section
        return data[section].count-1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // Configure the cell to not include the first element in each array
        cell.textLabel?.text = data[indexPath.section][indexPath.row+1]
        // everything except [0][2] should have a disclosure indicator
        if (cell.textLabel?.text != "Delete Account") {
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // return the first element in each of the arrays as the title
        return data[section][0]
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0))
        view.backgroundColor = .systemBlue
        // create label
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: view.frame.width-15, height: 40))
        label.text = data[section][0]
        // add label to view created
        view.addSubview(label)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // if delete account cell, present an UIAlertController asking for comfirmation
        if indexPath.section == 0 && indexPath.row == 1{
            presentDeleteAlert()
        }
        // if the cell that I selected is not [0][2] , ignore
        print("Selected row at: \(indexPath.row). At section: \(indexPath.section)\n")
        let viewControllerToPush = (storyboard?.instantiateViewController(identifier: storyIDs[indexPath.section]))!
        self.navigationController?.pushViewController(viewControllerToPush, animated: true)
        
    }
    
    func presentDeleteAlert(){
        let alert = UIAlertController(title: "Are you sure you would like to delete your account?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            let user = Auth.auth().currentUser
            user?.delete(completion: { (error) in
                // if there is an error, display another alert
                if error != nil {
                    let errorAlert = UIAlertController(title: "There was an error deleting your account. Please contact administrator.", message: "", preferredStyle: .alert)
                    self.present(errorAlert, animated: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                // if there is no error, instantiate the root view controller
                else {
                    var email = user?.email
                    print("email : \(email)")
                    ShoppingListManager.sharedManager.deleteAllInfo(email: self.revise(email ?? ""), uid : user!.uid)
                    self.transitionToRoot()
                }
            }) // end user delete closure
        })) // end alert.addAction closure
        self.present(alert, animated: true)
    }
    
    
    func revise(_ email : String) -> String{
        var revisedEmail = email
        revisedEmail.removeAll { (ch) -> Bool in
            return ch == "."
        }
        return revisedEmail
    }
    
    @IBAction func logoutWasPressed(_ sender: Any) {
        logOut()
    }
    
    func logOut() {
        do{
            try Auth.auth().signOut()
            print("Logging out : \(String(describing: Auth.auth().currentUser?.uid))")
            transitionToRoot()
        } catch {
            print(error.localizedDescription)
        }
    }
    func transitionToRoot() {
        let root = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.rootView) as! UINavigationController
        view.window?.rootViewController = root
        view.window?.makeKeyAndVisible()
    }
    
}
