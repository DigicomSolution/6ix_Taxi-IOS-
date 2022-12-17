//
//  LoginRequest.swift
//  User
//
//  Created by CSS on 07/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

struct  LoginRequest : JSONSerializable{

    var grant_type : String?
    var username : String?
    var password : String?
    var client_id : Int?
    var client_secret : String?
    var access_token : String?
    var refresh_token : String?
    var device_token : String?
    var device_id : String?
    var device_type : DeviceType?
}



struct SendCodeMobileNo : JSONSerializable{
    var mobile_no : String?
    var code : String?
        
    var status : Bool?
    var isVerified : Bool?
    var message : String?
        

    
}


struct SocialLoginMobileVerfied : JSONSerializable{
    var mobile_no : String?
    var code : String?
        
    var status : Bool?
    var isVerified : Int?
    var message : String?
        

    
}



struct TipModel : JSONSerializable{
    var request_id : Int?
    var tip:Float?
    
}


//struct LoginRequest<T1,T2,T3,T4,T5,T6,T7>{
//    var grant_type : T1
//    var username : T2
//    var password : T3
//    var client_id : T4
//    var client_secret : T5
//    var access_token : T6
//    var refresh_token : T7
//}
