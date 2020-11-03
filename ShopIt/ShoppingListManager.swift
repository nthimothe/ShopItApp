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
    
    private override init() {
        super.init()
        let user = Auth.auth().currentUser
        ref = Database.database().reference().child("users").child(user!.uid)
    }
    
    /* * * * * * * * * * * * *
     *                       *
     * SHOPPING LIST METHODS *
     *                       *
     * * * * * * * * * * * * *
     */
    
    
    /**
    Adds a ShoppingList to Firebase db
    - Parameters:
        - list : ShoppingList object that will be added to db
    */
    func addShoppingList(list : ShoppingList) {
        guard let key = ref?.child("lists").childByAutoId().key else { return }
        list.autoID = key
        self.ref!.child("lists/\(list.autoID)").setValue(list.toDict())
        print("Successfully added shopping list")
    }
    
    
    /**
    Deletes a ShoppingList from Firebase db and all of its children (all ShoppingItem's that belong to that list)
    - Parameters:
        - shoppingList : ShoppingList object that will be completely removed from database
    */
    func deleteShoppingList(shoppingList : ShoppingList) {
        // delete shopping list data
        let itemsRef = self.ref?.child("items").child(shoppingList.autoID)
        itemsRef?.removeValue { error, _ in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Successfully deleted all items belong to list...")
            }
        }
        // delete shopping list children data
        let listRef = self.ref?.child("lists").child(shoppingList.autoID)
        listRef?.removeValue { error, _ in
            if error != nil {
                print(error!.localizedDescription)
                
            } else {
                print("Successfully deleted list")
            }
        }
    }
    
    /**
    Renames shoppingList in db and updates its dateModified in db
    - Parameters:
        - shoppingList : renamed shoppingList
    */
    func renameShoppingList(shoppingList : ShoppingList) {
        // make changes to database
        self.ref!.child("lists/\(shoppingList.autoID)").child("name").setValue(shoppingList.name)
        
        self.ref!.child("lists/\(shoppingList.autoID)").child("dateModified").setValue(shoppingList.formatDate(shoppingList.dateModified))
        print("Successfully renamed shopping list and updated date modified \n")
    }
    
    /**
    Delete all shopping lists (and items) for a given user in db
     */
    func deleteAllShoppingLists(){
        self.ref!.removeValue { error, _ in
            if let err = error {
                print(err.localizedDescription)
            } else {
                print("Successfully deleted user's information from database")
            }
        }
    }

    
    /* * * * * * * * * * * * *
     *                       *
     * SHOPPING ITEM METHODS *
     *                       *
     * * * * * * * * * * * * *
     */
    
    /**
    Get all ShoppingItems that belong to a list
      - Parameters:
          - autoID : autoID of shoppingList (parent of shoppingItems)
     */
    func getShoppingItems(autoID : String, completion: @escaping ([ShoppingItem]) -> Void) {
        self.ref?.child("items").child(autoID).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            var items : [ShoppingItem] = []
            if let dict = snapshot.value as? NSDictionary {
                for (_,v) in dict{
                    let newItem = ShoppingItem()
                    if let attr = v as? NSDictionary{
                        if let content = attr["content"] as? String { newItem.content = content }
                        if let creationDate = attr["creationDate"] as? String { newItem.creationDate = Utilities.stringToDate(creationDate) }
                        if let dateModified = attr["dateModified"] as? String { newItem.dateModified = Utilities.stringToDate(dateModified) }
                        if let isCompleted = (attr["isCompleted"] as? NSString) { newItem.isCompleted = isCompleted.boolValue }
                        if let ID = (attr["autoID"] as? NSString) { newItem.autoID = ID as String }
                        if let parentAutoID = (attr["parentAutoID"] as? NSString) { newItem.parentAutoID = parentAutoID as String }
                    }
                    items.append(newItem)
                }
            }
            completion(items)
        })
    }

    
    /**
    Adds a ShoppingItem to Firebase db
      - Parameters:
          - item : ShoppingItem object that will be added to db
    */
    func addShoppingItem(item : ShoppingItem) {
        guard let key = ref?.child("lists").childByAutoId().key else { return }
        item.autoID = key
        self.ref!.child("items/\(item.parentAutoID)/").child(key).setValue(item.toDict())
        print("Successfully added shopping item \n")
    }
    
    
    /**
    Deletes a ShoppingItem from db
    - Parameters:
        - shoppingItem : shoppingItem object that will be completely removed from database
    */
    func deleteShoppingItem(item : ShoppingItem) {
        let reference = self.ref?.child("items").child(item.parentAutoID).child(item.autoID)
        reference?.removeValue { error, _ in
            if let err = error {
                print(err.localizedDescription)
            } else {
                print("Successfully deleted item")
            }
        }
    }
    
    /**
    Writes shoppingItem's date to db
        - Parameters:
            - shoppingItem : shoppingItem object
    */
    func updateDateModified(item: ShoppingItem){
        self.ref!.child("items/\(item.parentAutoID)").child(item.autoID).child("dateModified").setValue("\(item.formatDate(item.dateModified))")
    }
    
    /**
    Renames shoppingItem in db and updates its dateModified in db
     - Parameters:
         - shoppingItem : renamed ShoppingItem
    */
    func renameShoppingItem(item: ShoppingItem) {
        // persist changes to firebase
        updateDateModified(item: item)
        self.ref!.child("items/\(item.parentAutoID)").child(item.autoID).child("content").setValue("\(item.content)")
        print("Successfully updated item and updated date last modified\n")
    }
    
    /**
    Updates shoppingItem's isCompleted field in db and updates its dateModified in db
      - Parameters:
          - shoppingItem :ShoppingItem with new isCompleted flag
     */
    func markItem(item: ShoppingItem) {
        // persist changes to db
        updateDateModified(item: item)
        self.ref!.child("items/\(item.parentAutoID)").child(item.autoID).child("isCompleted").setValue("\(item.isCompleted)")
        print("Successfully marked item and updated date last modified\n")
    }
 
    
    /* * * * * * * * * * * * *
        *                       *
        * DELETE USER           *
        *                       *
        * * * * * * * * * * * * *
    */
    
    /**
     Deletes all info related for a given user from db
     - Parameters:
         - email : user's email
         - uid: user's unique ID
    */
    func deleteAllInfo(email: String, uid : String) {
        Database.database().reference().child("usernames").child(email).removeValue { error, _ in
            if let err = error {
                print(err.localizedDescription)
            } else {
                print("Successfully deleted user's email from database." )
            }
        }
       deleteAllShoppingLists()
    }
    
    
}

