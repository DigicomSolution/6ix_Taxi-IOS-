//
//  Service.swift
//  User
//
//  Created by CSS on 31/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

class Service : JSONSerializable {
    
    var id : Int?
    var name : String?
    var image : String?
    var address : String?
    var latitude :Double?
    var longitude :Double?
    var service_number : String?
    var service_model : String?
    var type : String?
    var capacity : Int?
    var pricing : EstimateFare?
    var calculator : ServiceCalculator?
    var promocode : PromocodeEntity?
    var price : Float?
    var calculation_format : String?
    var duration : String?
    var between_km : Double?
    var kilometer : Double?
    var instructions : String?
    var is_booster_cable : Int?
//    var waitingTime : String?
    var waiting_minutes : Int?
    var round_trip:Int?
    
    
    
}



