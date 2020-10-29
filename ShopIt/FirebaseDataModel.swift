//
//  FirebaseDataModel.swift
//  ShopIt
//
//  Created by Nathan Thimothe on 4/2/20.
//  Copyright © 2020 Nathan Thimothe. All rights reserved.
//

import Foundation


class ShoppingItem : Equatable, Comparable {
    
    
    var content : String = ""
    var creationDate = Date()
    var dateModified = Date()
    var isCompleted = false
    var parentAutoID = ""
    var autoID = ""

    
    func formatDate(_ date: Date) -> String {
      // format the date object
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = Constants.General.DATE_FORMAT
      return dateFormatter.string(from: date)
    }
    
    static func == (lhs: ShoppingItem, rhs: ShoppingItem) -> Bool {
        return lhs.parentAutoID == rhs.parentAutoID && lhs.autoID == rhs.autoID
    }
    
    static func > (lhs: ShoppingItem, rhs: ShoppingItem) -> Bool {
        return lhs.creationDate > rhs.creationDate
    }
    
    static func < (lhs: ShoppingItem, rhs: ShoppingItem) -> Bool {
        return lhs.creationDate < rhs.creationDate
    }
    
    func toDict() -> [String: String] {
        var dict : [String: String] = [:]
        dict["content"] = "\(self.content)"
        dict["creationDate"] = formatDate(self.creationDate)
        dict["dateModified"] = formatDate(self.dateModified)
        dict["isCompleted"] = "\(self.isCompleted)"
        dict["parentAutoID"] = self.parentAutoID
        dict["autoID"] = self.autoID
        return dict
    }
    
    func dump_item() -> String {
        return "\n\tname : \"\(self.content)\"\n\tcreationdate : \(formatDate(self.creationDate))\n\tmodifiedDate : \(formatDate(self.dateModified))\n\tisCompleted : \(self.isCompleted)\n\tparentAutoID : \(self.parentAutoID)\n\tautoID:\(self.autoID)"
    }
    
}



class ShoppingList : Equatable {
    
    var name : String = ""
    var creationDate = Date()
    var dateModified = Date()
    var items = [ShoppingItem]()
    var autoID : String = ""
    
    func formatDate(_ date : Date) -> String {
        // format the date object
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.General.DATE_FORMAT
        return dateFormatter.string(from: date)
    }
    
    
    func toDict() -> [String: String] {
        var dict : [String: String] = [:]
        dict["name"] = "\(self.name)"
        dict["creationDate"] = formatDate(self.creationDate)
        dict["dateModified"] = formatDate(self.dateModified)
        dict["autoID"] = self.autoID
        return dict
    }
    /// Two ShoppingLists are equal if their autoIDs are equal
    static func == (lhs: ShoppingList, rhs: ShoppingList) -> Bool {
        return lhs.autoID == rhs.autoID
    }
    
    func dump_list() -> String {
        var s = "ShoppingList Object Dump\n\nname : \"\(self.name)\"\ncreationDate : \(formatDate(self.creationDate))\ndateModifed : \(formatDate(self.dateModified))\nautoID : \(self.autoID)\n"
        for item in items{ s += "\titem: \(item.toDict())\n" }
        return s
    }
    
}


