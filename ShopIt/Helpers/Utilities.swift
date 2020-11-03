//
//  Utilities.swift
//  ShopIt
//
//  Created by Nathan Thimothe on 11/1/20.
//  Copyright © 2020 Nathan Thimothe. All rights reserved.
//

import Foundation

struct Utilities{
    static func stringToDate(_ x : String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.General.DATE_FORMAT
        var date = String(x).trimmingCharacters(in: .whitespacesAndNewlines)
        date.removeFirst() // remove 1st quotation
        date.removeLast() // remove 2nd quotation
        return dateFormatter.date(from: date)!
    }
    
    static func formatDict(_ dict: [String: String]) -> String {
        var ret : String = "{\n"
        for (k,v) in dict{
            ret += "\t\(k) = \(v)\n"
        }
        ret += "}"
        return ret
    }
}
