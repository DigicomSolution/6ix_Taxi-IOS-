//
//  String.swift
//  User
//
//  Created by imac on 12/22/17.
//  Copyright © 2017 Appoets. All rights reserved.
//

import Foundation

extension String {
    
    static var Empty : String {
        return ""
    }
    
    static func removeNil(_ value : String?) -> String{
        return value ?? String.Empty
    }
    
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    // Localization
    
    func localize()->String{
        
        return NSLocalizedString(self, bundle: currentBundle, comment: "")
        
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }

    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
}
extension String {
    func replace(string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespace() -> String {
        return self.replace(string: " ", replacement: "")
    }
    
    var first:String{
        let array = self.components(separatedBy: " ")
        return array.first!
    }
    var last:String{
        let array = self.components(separatedBy: " ")
        return array.last!
    }
}
extension String{
    var double:Double{
        return (self as NSString).doubleValue
    }
    var float:Float{
        return (self as NSString).floatValue
    }
   
}
