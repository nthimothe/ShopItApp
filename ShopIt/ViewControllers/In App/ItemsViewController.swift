//
//  ItemsViewController.swift
//  ShopIt
//
//  Created by Nathan Thimothe on 4/2/20.
//  Copyright © 2020 Nathan Thimothe. All rights reserved.
//

import UIKit
import Firebase

class ItemsViewController: UITableViewController, UserEditable {
    
    var controllerTitle : String = ""
    
    var itemsParentID : String = ""
    
    var ref : DatabaseReference?
    
    var items = [ShoppingItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = controllerTitle
        ref = ShoppingListManager.sharedManager.ref
        //loadData()
        observeAddition()
        observeDeletion()
        observeChange()
    }
    
    
    func observeAddition(){
        self.ref?.child("items").child(itemsParentID).observe(DataEventType.childAdded, with: { (snapshot) in
            if let dict = snapshot.value as? NSDictionary {
                print("(Addition) Received: \(dict)")
                let newItem = ShoppingItem()
                // safely unwrap
                if let parentAutoID = dict["parentAutoID"] as? String { newItem.parentAutoID = parentAutoID }
                if let autoID = dict["autoID"] as? String{ newItem.autoID = autoID }
                let containsItem = self.items.contains { (other) -> Bool in
                    return other.autoID == newItem.autoID && other.parentAutoID == newItem.parentAutoID
                }
                if !containsItem{
                    print("Adding: \(dict)")
                    // set the rest of the fields of newItem
                    if let content = dict["content"] as? String { newItem.content = content }
                    if let creationDate = dict["creationDate"] as? String { newItem.creationDate = Utilities.stringToDate(creationDate) }
                    if let dateModified = dict["dateModified"] as? String { newItem.dateModified = Utilities.stringToDate(dateModified) }
                    if let isCompleted = (dict["isCompleted"] as? NSString) { newItem.isCompleted = isCompleted.boolValue }
                    // add item to self.items, and add to tableView
                    self.items.insert(newItem, at: 0)
                    let indexPath = NSIndexPath(row: 0, section: 0) as IndexPath
                    self.tableView.insertRows(at: [indexPath], with: .fade)
                }
            }
        })
    }
    

    func observeDeletion(){
        self.ref?.child("items").child(itemsParentID).observe(DataEventType.childRemoved, with: { (snapshot) in
            if let dict = snapshot.value as? NSDictionary {
                print("(Deletion) Received: \(dict)")
                let newItem = ShoppingItem()
                if let parentAutoID = dict["parentAutoID"] as? String { newItem.parentAutoID = parentAutoID }
                if let autoID = dict["autoID"] as? String{ newItem.autoID = autoID }
                for i in 0 ..< self.items.count{
                    let currItem = self.items[i]
                    if newItem == currItem{
                        print("Removing: \(Utilities.formatDict(currItem.toDict()))")
                        // set the rest of the fields of newItem
                        if let content = dict["content"] as? String { newItem.content = content }
                        if let creationDate = dict["creationDate"] as? String { newItem.creationDate = Utilities.stringToDate(creationDate) }
                        if let dateModified = dict["dateModified"] as? String { newItem.dateModified = Utilities.stringToDate(dateModified) }
                        if let isCompleted = (dict["isCompleted"] as? NSString) { newItem.isCompleted = isCompleted.boolValue }
                        // make changes to tableView
                        let indexPath = NSIndexPath(row: i, section: 0) as IndexPath
                        // make changes to self.items
                        self.items.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                        break
                    }
                }
            }
        })
    }
    
    
    func observeChange(){
        self.ref?.child("items").child(itemsParentID).observe(DataEventType.childChanged, with: { (snapshot) in
            if let dict = snapshot.value as? NSDictionary {
                print("(Change) Received: \(dict)")
                let newItem = ShoppingItem()
                if let parentAutoID = dict["parentAutoID"] as? String { newItem.parentAutoID = parentAutoID }
                if let autoID = dict["autoID"] as? String{ newItem.autoID = autoID }
                for i in 0 ..< self.items.count{
                    let item = self.items[i]
                    if item == newItem {
                        print("Changing: \(Utilities.formatDict(item.toDict()))")
                        // set the rest of the fields of newItem
                        if let content = dict["content"] as? String { newItem.content = content }
                        if let creationDate = dict["creationDate"] as? String { newItem.creationDate = Utilities.stringToDate(creationDate) }
                        if let dateModified = dict["dateModified"] as? String { newItem.dateModified = Utilities.stringToDate(dateModified) }
                        if let isCompleted = (dict["isCompleted"] as? NSString) { newItem.isCompleted = isCompleted.boolValue }
                        // make changes to lists object
                        self.items[i] = item
                        // change tableView
                        let indexPath = NSIndexPath(row: i, section: 0) as IndexPath
                        let cell = self.tableView.cellForRow(at: indexPath)
                        // reassign the text and accessory type of that cell
                        cell?.textLabel!.text = newItem.content
                        cell?.accessoryType = newItem.isCompleted ? .checkmark : .none
                        break
                    }
                }
            }
        })
    }
    
    @IBAction func addWasPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add an Item", message: "", preferredStyle: .alert)
        // add text field
        alert.addTextField { (textField : UITextField) in
            textField.addTarget(self, action: #selector(self.textChanged(_:)), for: .editingChanged)
            textField.placeholder = "Shopping Item"
        }
        // add "Add" action
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            let item = ShoppingItem()
            item.parentAutoID = self.itemsParentID
            if let itemName = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines){
                // do not add empty shopping item titles or titles that are too long
                if itemName.isEmpty || itemName.count > Constants.General.MAX_LEN { return }
                // do not allow for two shopping items within the same list to have duplicate names
                let isDuplicate = self.items.contains(where: { (otherItem) -> Bool in
                    return otherItem.content == itemName
                })

                if isDuplicate { return }
                // set the item's content
                item.content = itemName
            }
            // write new item to db
            ShoppingListManager.sharedManager.addShoppingItem(item: item)

        }))
        // add "Cancel" action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // present UIAlertControlller
        self.present(alert, animated: true)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return items.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].content
        cell.accessoryType = items[indexPath.row].isCompleted ? .checkmark : .none
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        cell.addGestureRecognizer(gestureRecognizer)
        return cell
    }
    
    @objc func longPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            // it was touched at this point in the view
            let touchPoint = sender.location(in: self.view)
            let indexPath = self.tableView.indexPathForRow(at: touchPoint)
            if indexPath != nil{
                // unwrap sender.view and superview
                guard let gestureView = sender.view, let superView = gestureView.superview else {
                    return
                }
                let menuController = UIMenuController.shared
                print("sender view: \(String(describing: sender.view))")
                print("can it become first responder? \(String(describing: sender.view?.canBecomeFirstResponder))")
                guard gestureView.canBecomeFirstResponder else {
                    return
                }
                // becomes first responder in its window
                gestureView.becomeFirstResponder()
                
                // configure menu items
                let copyItemitle = NSLocalizedString("Copy", comment: "Copy this item name")
                let copyAction = #selector(UITableViewCell.copyToClipboard(_:))
                let copyItem = UIMenuItem(title: copyItemitle, action: copyAction)
                
                // configure shared menu controller
                menuController.menuItems = [copyItem]
                
                // show menu
                menuController.showMenu(from: superView, rect: gestureView.frame)
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // deselect row — fade away the gray
        tableView.deselectRow(at: indexPath, animated: true)
        // change item object
        let item = items[indexPath.row]
        item.isCompleted = !item.isCompleted
        item.dateModified = Date()
        // change tableView
        let cell = tableView.cellForRow(at: indexPath)
        // flip checkmark to none, else flip none to checkmark
        cell?.accessoryType = cell?.accessoryType == .checkmark ? .none : .checkmark
        // write to db
        ShoppingListManager.sharedManager.markItem(item: item)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = contextualDeleteAction(forRowAtIndexPath: indexPath)
        let editAction =   contextualEditAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction,editAction])
        return swipeConfig
    }
    
    func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            // write deletion to db
            ShoppingListManager.sharedManager.deleteShoppingItem(item: self.items[indexPath.row])
            completionHandler(true)
        }
        return action
    }
    
    func contextualEditAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        // define the UIContextual Action
        let action = UIContextualAction(style: .normal, title: "Edit") { (_, _, completionHandler) in
            // when "Edit" is pressed, the following should happen: Alert pops up, asking for new name
            let alert = UIAlertController(title: "Rename Item", message: "", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.addTarget(self, action: #selector(self.textChanged(_:)), for: .editingChanged)
                textField.text = self.items[indexPath.row].content
            }
            // cancel action
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            // rename action
            alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { (action_x) in
                // retrieve text from text field and rename shopping list manager
                if let newContent = alert.textFields?.first?.text{
                    if newContent.isEmpty || newContent.count > Constants.General.MAX_LEN { return }
                    // update item object to observe Change triggers
                    let item = self.items[indexPath.row]
                    item.content = newContent
                    item.dateModified = Date()
                    // write changes to db
                    ShoppingListManager.sharedManager.renameShoppingItem(item: item)
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
            sender.text = String(Array(sender.text!)[0..<Constants.General.MAX_LEN])
        }
        print("Text changed \(sender.text!)");
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        //allow list to do be able to be reordered
        return true
    }
    
}
