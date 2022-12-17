//
//  Normal_Extensions.swift
//  User
//
//  Created by imac on 12/22/17.
//  Copyright © 2017 Appoets. All rights reserved.
//


extension Int {
    
    static func val(val : Int?)->Int{
        
        return val ?? 0
    }
    
    static func removeNil(_ val : Int?)->Int{
    
         return val ?? 0
    }
    
    
}


extension Float {
    
    static func removeNil(_ val : Float?)->Float{
        
        return val ?? 0
    }
    
}
