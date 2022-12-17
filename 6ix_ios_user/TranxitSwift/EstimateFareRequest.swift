//
//  EstimateFare.swift
//  User
//

//  Created by CSS on 31/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

struct EstimateFareRequest : JSONSerializable {
    
    var s_latitude : Double?
    var s_longitude : Double?
 
  //  var positions: [Positions]?
    var positions : String?
//    var d_latitude : Double?
//    var d_longitude : Double?
    var service_type : Int?
    var round_trip:Int?
    var waiting_minutes : Int = 0
    
}

struct LocationRequest  :JSONSerializable{
    var s_latitude : Double?
    var s_longitude : Double?
    var round_trip:Int?
    var is_round:Int?
}




func convertToJSONString(value: [AnyObject]) -> String? {
        if JSONSerialization.isValidJSONObject(value) {
            do{
                let data = try JSONSerialization.data(withJSONObject: value, options: [])
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            }catch{
            }
        }
        return nil
}
