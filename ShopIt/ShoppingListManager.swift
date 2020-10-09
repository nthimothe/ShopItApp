//
//  ShoppingListManager.swift
//  ShopIt
//
//  Created by Nathan Thimothe on 4/2/20.
//  Copyright © 2020 Nathan Thimothe. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class ShoppingListManager : NSObject {
    
    static let sharedManager = ShoppingListManager()
    var ref : DatabaseReference?
    let user : User? = Auth.auth().currentUser
    
    private override init() {
        super.init()
        ref = Database.database().reference().child("users").child(user!.uid)
    }
    
    /* * * * * * * * * * * * *
     *                       *
     * SHOPPING LIST METHODS *
     *                       *
     * * * * * * * * * * * * *
     */
    
    
    // add a ShoppinsgList to Google's Firebase as JSON Object
    func addShoppingList(list : ShoppingList) {
        guard let key = ref?.child("lists").childByAutoId().key else { return }
        list.autoID = key
        self.ref!.child("lists/\(list.autoID)").setValue(list.toDict())
        print("Successfully added shopping list")
    }
    
    
    // delete a ShoppingList from Firebase database and all of its children
    func deleteShoppingList(shoppingList : ShoppingList) {
        let itemsRef = self.ref?.child("items").child(shoppingList.autoID)
        itemsRef?.removeValue { error, _ in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Successfully deleted all items belong to list...")
            }
        }
        
        let listRef = self.ref?.child("lists").child(shoppingList.autoID)
        listRef?.removeValue { error, _ in
            if error != nil {
                print(error!.localizedDescription)
                
            } else {
                print("Successfully deleted list")
            }
        }
        
    }
    
    // change the name of a ShoppingLsit and update its dateModified
    func renameShoppingList(shoppingList : ShoppingList, newName : String) {
        // make changes to object
        shoppingList.name = newName
        shoppingList.dateModified = Date()
        // make changes to database
        self.ref!.child("lists/\(shoppingList.autoID)").child("name").setValue(shoppingList.name)
        
        // change the shoppingList's datemModified
        self.ref!.child("lists/\(shoppingList.autoID)").child("dateModified").setValue(shoppingList.formatDate(shoppingList.dateModified))
        print("Successfully renamed shopping list and updated date modified \n")
    }
    
    /* * * * * * * * * * * * *
     *                       *
     * SHOPPING ITEM METHODS *
     *                       *
     * * * * * * * * * * * * *
     */
    
    
    // add a ShoppingItem to Google's Firebase as JSON Object
    func addShoppingItem(shoppingList : ShoppingList, item : ShoppingItem) {
        // insert the most recently created object to the beginning of the list
        shoppingList.items.insert(item, at: 0)
        guard let key = ref?.child("lists").childByAutoId().key else { return }
        item.autoID = key
        self.ref!.child("items/\(shoppingList.autoID)/").child(key).setValue(item.toDict())
        print("Successfully added shopping item \n")
    }
    
    
    // delete a shoppingItem from Firebase
    func deleteShoppingItem(shoppingList: ShoppingList, index: Int) {
        let item = shoppingList.items.remove(at: index)
        let reference = self.ref?.child("items").child(shoppingList.autoID).child(item.autoID)
        reference?.removeValue { error, _ in
            if let err = error {
                print(err.localizedDescription)
            } else {
                print("Successfully deleted item")
            }
        }
    }
    
    // change the content of a ShoppingItem and update its access date
    func renameShoppingItem(shoppingList: ShoppingList, index : Int, content: String) {
        let item = shoppingList.items[index]
        item.content = content
        item.dateModified = Date()
        print(item.dump_item())
        // persist changes to firebase
    self.ref!.child("items/\(shoppingList.autoID)").child(item.autoID).child("dateModified").setValue("\(item.formatDate(item.dateModified))")
        self.ref!.child("items/\(shoppingList.autoID)").child(item.autoID).child("content").setValue("\(item.content)")
        print("Successfully updated item and updated date last modified\n")
    }
    
    // mark item as either completed or not and update its access date
    func markItem(shoppingList: ShoppingList, index: Int, isCompleted : Bool) {
        let item = shoppingList.items[index]
        item.dateModified = Date()
        item.isCompleted = isCompleted
        
        // persist changes to firebase
        self.ref!.child("items/\(shoppingList.autoID)").child(item.autoID).child("dateModified").setValue("\(item.formatDate(item.dateModified))")
        self.ref!.child("items/\(shoppingList.autoID)").child(item.autoID).child("isCompleted").setValue("\(isCompleted)")
        print("Successfully marked item and updated date last modified\n")
    }
 
    
    /* * * * * * * * * * * * *
        *                       *
        * DELETE USER           *
        *                       *
        * * * * * * * * * * * * *
    */
    
    func deleteAllInfo(email: String, uid : String) {
        Database.database().reference().child("usernames").child(email).removeValue { error, _ in
            if let err = error {
                print(err.localizedDescription)
            } else {
                print("Successfully deleted user's email from database." )
            }
        }
        self.ref!.removeValue { error, _ in
            if let err = error {
                print(err.localizedDescription)
            } else {
                print("Successfully deleted user's information from database")
            }
        }
    }
    
    
}

