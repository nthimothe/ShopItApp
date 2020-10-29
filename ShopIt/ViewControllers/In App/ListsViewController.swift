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


class ListsViewController: UITableViewController, UserEditable {
    
    var lists = [ShoppingList]()
    var ref : DatabaseReference?
    let user : User? = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ref to database
        ref = ShoppingListManager.sharedManager.ref
        //loadData()
        observeAddition()
        observeDeletion()
        observeChange()
    }
    func dumpLists() {
        print("DUMPING LISTS...")
        for list in self.lists{
            print(list.name)
        }
        print("FINISHED DUMP...")
    }
    func observeAddition(){
        print("ADDITION!!")
        self.ref?.child("lists").observe(DataEventType.childAdded, with: { (snapshot) in
            if let dict = snapshot.value as? NSDictionary {
                print("ADDITION DICT: \(dict)")
                let newList = ShoppingList()
                if let autoID = dict["autoID"] as? String { newList.autoID = autoID }
                let containsList = self.lists.contains { (other) -> Bool in
                    return other.autoID == newList.autoID
                }
                if !containsList{
                    // set the rest of the fields of newList now that you know you have a new list
                    if let name = dict["name"] as? String { newList.name = name }
                    if let creationDate = dict["creationDate"] as? String { newList.creationDate = self.stringToDate(creationDate) }
                    if let dateModified = dict["dateModified"] as? String { newList.dateModified = self.stringToDate(dateModified) }
                    print("ADDITION: did not contain: \n\"\(newList.dump_list())\"\n****")
                    self.lists.insert(newList, at: 0)
                    let indexPath = NSIndexPath(row: 0, section: 0) as IndexPath
                    self.tableView.insertRows(at: [indexPath], with: .fade)
                }
            }
            print("ADDITION ENDDDD!!")
        })
    }
    
    func observeDeletion(){
        print("DELETION")
        self.ref?.child("lists").observe(DataEventType.childRemoved, with: { (snapshot) in
            if let dict = snapshot.value as? NSDictionary {
                print("DELETION DICT: \(dict)")
                let newList = ShoppingList()
                if let autoID = dict["autoID"] as? String { newList.autoID = autoID }
                for i in 0 ..< self.lists.count{
                    print("checking list in DELETION...")
                    let list = self.lists[i]
                    if list == newList{
                        // set the rest of the fields of newList now that you know you have a new list
                        if let name = dict["name"] as? String { newList.name = name }
                        if let creationDate = dict["creationDate"] as? String { newList.creationDate = self.stringToDate(creationDate) }
                        if let dateModified = dict["dateModified"] as? String { newList.dateModified = self.stringToDate(dateModified) }
                        print("DELETION: found the following to delete: \n\"\(newList.dump_list())\"\n****")
                        let indexPath = NSIndexPath(row: i, section: 0) as IndexPath
                        self.lists.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                        break
                    }
                }
            }
        })
    }
    
    func observeChange(){
        print("CHANGE")
        self.ref?.child("lists").observe(DataEventType.childChanged, with: { (snapshot) in
            if let dict = snapshot.value as? NSDictionary {
                print("CHANGE DICT: \(dict)")
                let newList = ShoppingList()
                if let autoID = dict["autoID"] as? String { newList.autoID = autoID }
                for i in 0 ..< self.lists.count{
                    let list = self.lists[i]
                    if list == newList{
                        // set the rest of the fields of newList now that you know you have a new list
                        if let name = dict["name"] as? String { newList.name = name }
                        if let creationDate = dict["creationDate"] as? String { newList.creationDate = self.stringToDate(creationDate) }
                        if let dateModified = dict["dateModified"] as? String { newList.dateModified = self.stringToDate(dateModified) }
                        print("CHANGE!!!: found the following to change: \n\"\(newList.dump_list())\"\n****")
                        // make changes to lists object
                        self.lists[i] = newList
                        self.dumpLists()
                        print("*****")
                        let indexPath = NSIndexPath(row: i, section: 0) as IndexPath
                        let cell = self.tableView.cellForRow(at: indexPath)
                        cell?.textLabel!.text = newList.name
                        break
                    }
                }
            }
        })
    }
    
    private func stringToDate(_ x : String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.General.DATE_FORMAT
        var date = String(x).trimmingCharacters(in: .whitespacesAndNewlines)
        date.removeFirst() // remove quotation
        date.removeLast() // remove quotation
        return dateFormatter.date(from: date)!
    }
    
    /// Allow addition of new shopping list via alert by AlertController
    @IBAction func addWasPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Create a Shopping List", message: "", preferredStyle: .alert)
        alert.addTextField { (textField : UITextField) in
            textField.addTarget(self, action: #selector(self.textChanged(_:)), for: .editingChanged)
            textField.placeholder = "Shopping List Title"
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            let newList = ShoppingList()
            // access the first element in the array and get its text
            if let shoppingListTitle = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines){
                // do not add empty shopping list titles
                if shoppingListTitle.isEmpty || shoppingListTitle.count > Constants.General.MAX_LEN { return }
                // do not allow duplicate shoppingList names
                let isDuplicate = self.lists.contains(where: { (otherList) -> Bool in
                    return otherList.name == shoppingListTitle
                })
                if isDuplicate{ return }
                newList.name = shoppingListTitle
            }
            // write newList to db
            ShoppingListManager.sharedManager.addShoppingList(list: newList)
            //self.lists.insert(newList, at: 0)
            //let indexPath = NSIndexPath(row: 0, section: 0) as IndexPath
            //self.tableView.insertRows(at: [indexPath], with: .fade)
        }))
        // add "Cancel" action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        // present UIAlertControlller
        self.present(alert, animated: true)
    }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return lists.count }
    
    /// Ddd arrows to each Shopping List cell to indicate each has a valid segue
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = lists[indexPath.row].name
        cell.accessoryType = .disclosureIndicator // add arrows to each shopping list to indicate each has a valid segue
        return cell
    }
    
    /// Define two swipe actions for each Shopping List Cell — delete and edit.
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = contextualDeleteAction(forRowAtIndexPath: indexPath)
        let editAction =   contextualEditAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction,editAction])
        return swipeConfig
    }
    
    /// Warn user that deletion of an entire shopping list will delete all elements contained in that object.
    func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            
            // warn the user about the permanent deletion of their data
            let alert = UIAlertController(title: "Delete \"\(self.lists[indexPath.row].name)?\"", message: "Deleting this list will delete all the items that you have stored in this list as well.", preferredStyle: .alert)
            // allow for cancelation
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            // allow for destructive deletion behavior
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (alert) in
                // write deletion to db
                ShoppingListManager.sharedManager.deleteShoppingList(shoppingList : self.lists[indexPath.row])
            }))
            self.present(alert, animated: true)
            completionHandler(true)
        }
        return action // returning UI Contextual Delete action
    }
    
    /// Allow user to edit the name of their shopping list
    func contextualEditAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        // define the UIContextual Action
        let action = UIContextualAction(style: .normal, title: "Edit") { (_, _, completionHandler) in
            // when "Edit" is pressed, the following should happen: Alert pops up, asking for new name
            
            let alert = UIAlertController(title: "Rename Shopping List", message: "", preferredStyle: .alert)
            
            alert.addTextField { (textField) in
                textField.addTarget(self, action: #selector(self.textChanged(_:)), for: .editingChanged)
                textField.placeholder = "New Shopping List Name"
            }
            // cancel action
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            // rename action
            alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { (action_x) in
                // retrieve text from text field and rename shopping list manager
                if let newName = alert.textFields?.first?.text{
                    // if the newContent is not the empty string, make changes to realm and global DS
                    if newName.isEmpty || newName.count > Constants.General.MAX_LEN { return }
                    // make a change to object so observeChange triggers
                    self.lists[indexPath.row].name = newName
                    self.lists[indexPath.row].dateModified = Date()
                    // write modified shoppingList to db
                    ShoppingListManager.sharedManager.renameShoppingList(shoppingList: self.lists[indexPath.row])
                    //let cell = self.tableView.cellForRow(at: indexPath)
                    //cell?.textLabel!.text = newName
                    completionHandler(true)
                }
            }))
            self.present(alert, animated: true)
        }
        return action
    }
    
    @objc func textChanged(_ sender: UITextField){
        // if there are more than Constants.General.MAX_LEN characters in the field, slice first Constants.General.MAX_LEN char
        if sender.text!.count > Constants.General.MAX_LEN {
            shake(sender)
            sender.text = String(Array(sender.text!)[0..<Constants.General.MAX_LEN]) // slices the first 32 characters
        }
        print("Text changed \(sender.text!)");
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
            seg.controllerTitle = selectedShoppingList.name
            seg.itemsParentID = selectedShoppingList.autoID
        }
    }
    
    
}
