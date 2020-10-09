//
//  ListsViewController.swift
//  ShopIt
//
//  Created by Nathan Thimothe on 3/31/20.
//  Copyright © 2020 Nathan Thimothe. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI


class ListsViewController: UITableViewController {
    
    var lists = [ShoppingList]()
    var ref : DatabaseReference?
    let user : User? = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // ref to database
        ref = ShoppingListManager.sharedManager.ref
        loadData()
    }
    
    // load the shopping lists and items relevant to user
    func loadData() {
        self.ref?.child("lists").observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? NSDictionary {
                for (k,v) in dict {
                    let shoppingList = ShoppingList()
                    if let attr = v as? NSDictionary{
                        shoppingList.name = attr["name"] as! String
                        shoppingList.creationDate = self.stringToDate(attr["creationDate"] as! String)!
                        shoppingList.dateModified = self.stringToDate(attr["dateModified"] as! String)!
                    }
                    shoppingList.autoID = (k as? String)!
                    self.lists.append(shoppingList)
                }
                
               // the most recently created shoppingList should be the first one in the tableView
                self.lists.sort { (prev, next) -> Bool in
                    if prev.creationDate >= next.creationDate { return true }
                    return false
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    private func stringToDate(_ x : String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd h:mm:ss a"
        let date = String(x).trimmingCharacters(in: .whitespacesAndNewlines)
        if let toRet = dateFormatter.date(from: date) {
            return toRet
        } else {
            print("There was an error decoding the string")
            return nil
        }
    }
    
    // Allow addition of new shopping list via alert by AlertController
    @IBAction func addWasPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Create a Shopping List", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField : UITextField) in
            textField.placeholder = "Shopping List Title"
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            let newList = ShoppingList()
            // access the first element in the array and get its text
            if let shoppingListTitle = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines){
                // do not add empty shopping list titles
                if shoppingListTitle.isEmpty {
                    return
                }
                
                // do not allow duplicate shoppingList names
                let isDuplicate = self.lists.contains(where: { (otherList) -> Bool in
                    if otherList.name == shoppingListTitle{
                        return true
                    }
                    return false
                })
                if isDuplicate{
                    return
                }
                
                newList.name = shoppingListTitle
            }
            // make appropriate additions to database, global DS, and tableView
            ShoppingListManager.sharedManager.addShoppingList(list: newList)
            self.lists.insert(newList, at: 0)
            let indexPath = NSIndexPath(row: 0, section: 0) as IndexPath
            self.tableView.insertRows(at: [indexPath], with: .fade)
        }))
        
        // add "Cancel" action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // present UIAlertControlller
        self.present(alert, animated: true)
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return lists.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = lists[indexPath.row].name
        cell.accessoryType = .disclosureIndicator // add arrows to each shopping list to indicate each has a valid segue
        return cell
    }
     
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = contextualDeleteAction(forRowAtIndexPath: indexPath)
        let editAction =   contextualEditAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction,editAction])
        return swipeConfig
    }

    // Warn user that deletion of an entire shopping list will delete all elements contained in that object.
    func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            
            // warn the user about the permanent deletion of their data
            let alert = UIAlertController(title: "Delete \"\(self.lists[indexPath.row].name)?\"", message: "Deleting this list will delete all the items that you have stored in this list as well.", preferredStyle: .alert)
                // allow for cancelation
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                // allow for destructive deletion behavior
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (alert) in
                    // make appropriate deletions to FB, global DS, and tableView
                    ShoppingListManager.sharedManager.deleteShoppingList(shoppingList : self.lists[indexPath.row])
                    self.lists.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }))
            self.present(alert, animated: true)
            completionHandler(true)
        }
        return action // returning UI Contextual Delete action
        }
        
     // Allow user to edit the name of their shopping list
    func contextualEditAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        // define the UIContextual Action
        let action = UIContextualAction(style: .normal, title: "Edit") { (_, _, completionHandler) in
            // when "Edit" is pressed, the following should happen: Alert pops up, asking for new name
            
            let alert = UIAlertController(title: "Rename Shopping List", message: "", preferredStyle: .alert)
            
            alert.addTextField { (textField) in
                textField.placeholder = "New Shopping List Name"
            }
            
            // cancel action
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            // rename action
            alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { (action_x) in
                // retrieve text from text field and rename shopping list manager
                if let newName = alert.textFields?.first?.text{
                    // if the newContent is not the empty string, make changes to realm and global DS
                    if newName.isEmpty{
                        return
                    }
                    // make appropriate changes to FB and tableView and global DS
                    ShoppingListManager.sharedManager.renameShoppingList(shoppingList: self.lists[indexPath.row], newName: newName)
                    let cell = self.tableView.cellForRow(at: indexPath)
                    cell?.textLabel!.text = newName
                    completionHandler(true)
                }
            }))
            self.present(alert, animated: true)
        }
        return action
    }
    


    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    


    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // get the index path for the item the user tapped
        if let selectedShoppingListIndexPath = self.tableView.indexPathForSelectedRow{
            // get the corresponding shoppingList from the lists array
            let selectedShoppingList = lists[selectedShoppingListIndexPath.row]
            let seg = segue.destination as! ItemsViewController
            seg.shoppingList = selectedShoppingList
        }
    }


}
