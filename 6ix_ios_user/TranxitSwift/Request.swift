//
//  Request.swift
//  User
//
//  Created by CSS on 31/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

class Request : JSONSerializable {
    
    var s_latitude : Double?
    var s_longitude : Double?
//    var positions : [Positions]?
    var positions : String?
    
    var stops : [Stops]?
    var service_type : Int?
    var service_type_id : Int?
    var distance : String?
    var distanceInt : Float?
    var payment_mode : PaymentType?
    var card_id : String?
    var s_address : String?
    var use_wallet : Int?
    var schedule_date : String?
    var schedule_time : String?
    var request_id : Int?
    var current_provider : Int?
    var id : Int?
    var booking_id : String?
    var travel_time : String?
    
    var status : RideStatus?
    var provider : Provider?
    var service : Service?
   // var service_type : Service?
    var provider_service : Service?
    var payment : Payment?
    var otp : String?
    var assigned_at : String?
    var schedule_at : String?
    var static_map : String?
    var surge : Int?
    var rating : Rating?
    var message : String?
    var paid : Int?
    var cancel_reason : String?
    var latitude : Double?
    var longitude : Double?
    var address : String?
    var tips : Float?
    var promocode_id : Int?
    var unit : String?
    var is_scheduled : Bool?
    var is_round:Int?
    var waiting_minutes : Int?
    var instructions : String?
    var is_booster_cable : Int?
    
    
  /*
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case booking_id = "booking_id"
        case status = "status"
        case payment_mode = "payment_mode"
        case distance = "distance"
        case s_address = "s_address"
        case s_latitude = "s_latitude"
        case s_longitude = "s_longitude"
        case d_address = "d_address"
        case d_latitude = "d_latitude"
        case d_longitude = "d_longitude"
        case use_wallet = "use_wallet"
        case schedule_date = "schedule_date"
        case request_id = "request_id"
        case current_provider = "current_provider"
        case schedule_time = "schedule_time"
        case provider
        case service_type
        
    }
 
  */
    
 
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try? values.decode(Int.self, forKey: .id)
        status = try? values.decode(RideStatus.self, forKey: .status)
        booking_id = try? values.decode(String.self, forKey: .booking_id)
        s_address = try? values.decode(String.self, forKey: .s_address)
        s_latitude = try? values.decode(Double.self, forKey: .s_latitude)
        s_longitude = try? values.decode(Double.self, forKey: .s_longitude)
//        positions = try? values.decode([Positions].self, forKey: .positions)
        stops = try? values.decode([Stops].self, forKey: .stops)
        positions = try? values.decode(String.self, forKey: .positions)
        use_wallet = try? values.decode(Int.self, forKey: .use_wallet)
        provider = try? values.decode(Provider.self, forKey: .provider)
        distance = try? values.decode(String.self, forKey: .distance)
        distanceInt = try? values.decode(Float.self, forKey: .distance)
        service = try? values.decode(Service.self, forKey: .service_type)
        service_type =  try? values.decode(Int.self, forKey: .service_type)
//        service_type = try? values.decode(Service.self, forKey: .service_type)
        service_type_id =  try? values.decode(Int.self, forKey: .service_type_id)
        is_round =  try? values.decode(Int.self, forKey: .is_round)
        
        
        
        
        schedule_date = try? values.decode(String.self, forKey: .schedule_date)
        schedule_time = try? values.decode(String.self, forKey: .schedule_time)
        request_id = try? values.decode(Int.self, forKey: .request_id)
        current_provider = try? values.decode(Int.self, forKey: .current_provider)
        status = try? values.decode(RideStatus.self, forKey: .status)
        provider_service = try? values.decode(Service.self, forKey: .provider_service)
        payment = try? values.decode(Payment.self, forKey: .payment)
        travel_time = try? values.decode(String.self, forKey: .travel_time)
        payment_mode = try? values.decode(PaymentType.self, forKey: .payment_mode)
        otp = try? values.decode(String.self, forKey: .otp)
        assigned_at = try? values.decode(String.self, forKey: .assigned_at)
        schedule_at = try? values.decode(String.self, forKey: .schedule_at)
        static_map = try? values.decode(String.self, forKey: .static_map)
        surge = try? values.decode(Int.self, forKey: .surge)
        rating = try? values.decode(Rating.self, forKey: .rating)
        message = try? values.decode(String.self, forKey: .message)
        paid = try? values.decode(Int.self, forKey: .paid)
        unit = try? values.decode(String.self, forKey: .unit)
        is_scheduled = (try? values.decode(String.self, forKey: .is_scheduled) == "YES")
        
        
     
    }
 
    init() {   }
 
    
    
}

class Positions : JSONSerializable {
 
    var action: String?
    var d_address : String?
    var d_latitude : Double?
    var d_longitude : Double?
    var stop_id:Int?
 
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        action = try? values.decode(String.self, forKey: .action)
        d_address = try? values.decode(String.self, forKey: .d_address)
        d_latitude = try? values.decode(Double.self, forKey: .d_latitude)
        d_longitude = try? values.decode(Double.self, forKey: .d_longitude)
         stop_id = try? values.decode(Int.self, forKey: .stop_id)
    }
    
    init() {   }
}





class Stops : JSONSerializable {

    var d_latitude : Double?
    var d_longitude : Double?
    var d_address : String?
    var id : Int?
    var order : Int?
    var status : String?
    var user_request_id : Int?
    var updated_at : String?
    var created_at : String?
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        d_address = try? values.decode(String.self, forKey: .d_address)
        d_latitude = try? values.decode(Double.self, forKey: .d_latitude)
        d_longitude = try? values.decode(Double.self, forKey: .d_longitude)
        created_at = try? values.decode(String.self, forKey: .created_at)
        updated_at = try? values.decode(String.self, forKey: .updated_at)
        id =  try? values.decode(Int.self, forKey: .id)
        order =  try? values.decode(Int.self, forKey: .order)
        status =  try? values.decode(String.self, forKey: .status)
        user_request_id =  try? values.decode(Int.self, forKey: .user_request_id)
    }
    
    init() {   }
    
}

