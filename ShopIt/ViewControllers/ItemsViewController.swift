//
//  ItemsViewController.swift
//  ShopIt
//
//  Created by Nathan Thimothe on 4/2/20.
//  Copyright © 2020 Nathan Thimothe. All rights reserved.
//

import UIKit
import Firebase

class ItemsViewController: UITableViewController {
    
    var shoppingList : ShoppingList = ShoppingList()
    
    var ref : DatabaseReference?
    
    var items = [ShoppingItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = shoppingList.name
        print("view did load")
        ref = ShoppingListManager.sharedManager.ref
        loadData()
  }
    
    
    // load the shopping items relevant to one shoppingList
    func loadData() {
        self.ref?.child("items").child(shoppingList.autoID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? NSDictionary {
                for (k,v) in dict {
                    let shoppingItem = ShoppingItem()
                    if let attr = v as? NSDictionary{
                        // safely unwrap all members of the shopping Item and set them
                        
                        if let content = attr["content"] as? String{
                            shoppingItem.content = content
                        }
                        
                        if let creationDate = attr["creationDate"] as? String{
                            shoppingItem.creationDate = self.stringToDate(creationDate)
                        }
                        
                        
                        if let dateModified = attr["dateModified"] as? String {
                            shoppingItem.dateModified = self.stringToDate(dateModified)
                        }
                        
                        
                        if let isCompleted = (attr["isCompleted"] as? NSString) {
                            shoppingItem.isCompleted = isCompleted.boolValue
                        }
                        
                        // the item's autoID is the key of the dictionary
                        shoppingItem.autoID = (k as? String)!
                        //print(shoppingItem.dump_item())
                        self.items.append(shoppingItem)
                    }
                } // end for loop
                self.items.sort(by: >)
                
                self.shoppingList.items = self.items
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }) // end observeSingleEvent closure
    }
    
    func formatDate(_ date: Date) -> String {
        // format the date object
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.General.DATE_FORMAT
        return dateFormatter.string(from: date)
    }
    
    
    private func stringToDate(_ x : String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.General.DATE_FORMAT
        var date = String(x).trimmingCharacters(in: .whitespacesAndNewlines)
        date.removeFirst() // remove quotation
        date.removeLast() // remove quotation
        return dateFormatter.date(from: date)!
    }
    
    @IBAction func addWasPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add an Item", message: "", preferredStyle: .alert)
        
        // add text field
        alert.addTextField { (textField : UITextField) in
            textField.placeholder = "Shopping Item"
        }

        // add "Add" action
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            let item = ShoppingItem()
            item.parentAutoID = self.shoppingList.autoID
            if let itemName = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines){
                // do not add empty shopping item titles
                if itemName.isEmpty {
                    return;
                }
                // do not allow for two shopping items within the same list to have duplicate names
                let isDuplicate = self.items.contains(where: { (otherItem) -> Bool in
                    if otherItem.content == itemName{
                        return true
                    }
                    return false
                })
                if isDuplicate{
                    return
                }
                // set the item's content
                item.content = itemName
            }

            // make appropriate additions to firebase, global DS, and tableView
            ShoppingListManager.sharedManager.addShoppingItem(shoppingList: self.shoppingList, item: item)
            self.items.insert(item, at: 0)
            let indexPath = NSIndexPath(row: 0, section: 0) as IndexPath
            self.tableView.insertRows(at: [indexPath], with: .fade)
            print("shopping list's items: \n")
            for x in self.shoppingList.items{
                print(x.dump_item())
            }
            print("****")
            
            print("self.items's items: \n")
            for x in self.items{
                print(x.dump_item())
            }
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
        return items.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].content
        cell.accessoryType = items[indexPath.row].isCompleted ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // deselect row — fade away the gray
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        // flip checkmark to none, else flip none to checkmark
        if cell?.accessoryType == .checkmark {
            cell?.accessoryType = .none
        } else {
            cell?.accessoryType = .checkmark
        }
        // make the Realm reflect user changes
        let item = items[indexPath.row]
        // flip the flag on the item
        ShoppingListManager.sharedManager.markItem(shoppingList: shoppingList, index: indexPath.row , isCompleted: !item.isCompleted)
        print("Item is now marked completed: \(item.isCompleted)")
    }

//
//    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // make appropriate deletions to realm, global DS, and tableView
//            ShoppingListManager.sharedManager.deleteShoppingItem(item: (shoppingList?.list[indexPath.row])!)
//            items.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//        }
//     }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = contextualDeleteAction(forRowAtIndexPath: indexPath)
        let editAction =   contextualEditAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction,editAction])
        return swipeConfig
    }

    func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            // make appropriate deletions to realm, global DS, and tableView
            ShoppingListManager.sharedManager.deleteShoppingItem(shoppingList: self.shoppingList, index: indexPath.row)
            self.items.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
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
                textField.placeholder = "New Item Name"
            }
            
            // cancel action
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            // rename action
            alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { (action_x) in
                // retrieve text from text field and rename shopping list manager
                if let newContent = alert.textFields?.first?.text{
                    // if the newContent is not the empty string, make changes to realm and global DS
                    if newContent.isEmpty{
                        return
                    }
                    // update the global DS and firebase via sharedManager and tableView
                    ShoppingListManager.sharedManager.renameShoppingItem(shoppingList: self.shoppingList, index: indexPath.row, content: newContent)
                    let cell = self.tableView.cellForRow(at: indexPath)
                    cell?.textLabel!.text = newContent
                    
                    completionHandler(true)
                }
            }))
            self.present(alert, animated: true)
        }
        return action
    }
    
 
    
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }

    
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        //allow list to do be able to be reordered
        return true
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
