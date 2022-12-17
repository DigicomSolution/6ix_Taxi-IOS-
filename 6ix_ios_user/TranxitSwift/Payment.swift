//
//  Payment.swift
//  User
//
//  Created by CSS on 01/06/18.
//  Copyright © 2018 Appoets. All rights reserved.
//
/*
distance
waiting_charges
fixed
commision
wallet
tax
minute
flat_rate
payable
total
 */
import Foundation

struct Payment : JSONSerializable {
    
    let id : Int?
    let request_id : Int?
    let promocode_id : Int?
    let payment_id : String?
    let payment_mode : String?
    let fixed : Float?
    let distance : Float?
    let waiting_charges : Double?
    let commision : Float?
    let discount : Float?
    let tax : Float?
    let wallet : Float?
    let surge : Float?
    let total : Float?
    let payable : Float?
    let provider_commission : Float?
    let provider_pay : Float?
    let minute : Float?
    let hour : Float?
    let tips : Float?
    let rate_type:String?
    let flat_rate:String?
    let total_kilometer:Double?
//    let per_kilometer:Int?
//    let base_distance:Int?
    
    let per_kilometer:Float?
    let base_distance:Float?
    
    
    
    let admin_fee:Float?
    
    
    
}


extension Payment {
    var isFlatRate:Bool{
        return rate_type == "Flat"
    }
    var distanceTravelledFare:Float{
        //((2.5 - 0) * 10)
        let totalKilometer:Float = Float((total_kilometer ?? 0))
        let distance:Float = Float((base_distance ?? 0))
        let perKilometer:Float = Float((per_kilometer ?? 0))
        return ((totalKilometer - distance) * perKilometer)
    }
}





//{"id":1858,"request_id":6305,"user_id":566,"provider_id":437,"fleet_id":0,"promocode_id":null,"payment_id":null,"payment_mode":"CASH","fixed":3.25,"distance":22.12,"minute":0,"hour":0,"commision":0.44,"commision_per":2,"fleet":0,"fleet_per":0,"discount":0,"discount_per":0,"tax":2.21,"tax_per":10,"wallet":0,"is_partial":0,"cash":24.92,"card":0,"online":0,"surge":0,"tips":0,"total":76.02,"payable":0,"provider_commission":0,"provider_pay":23.13,"waiting_charges":1,"rate_type":"Flat","flat_rate":"24.92","total_kilometer":7.55,"per_kilometer":2.5,"base_distance":0}
//
//
//
//{"id":1844,"request_id":6286,"user_id":566,"provider_id":437,"fleet_id":0,"promocode_id":null,"payment_id":null,"payment_mode":"CASH","fixed":30,"distance":35.7,"minute":0,"hour":0,"commision":0.72,"commision_per":2,"fleet":0,"fleet_per":0,"discount":0,"discount_per":0,"tax":3.57,"tax_per":10,"wallet":0,"is_partial":0,"cash":120.81,"card":0,"online":0,"surge":0,"tips":0,"total":120.81,"payable":0,"provider_commission":0,"provider_pay":36.7,"waiting_charges":1,"rate_type":"Flat","flat_rate":"40.32","total_kilometer":0.57,"per_kilometer":10,"base_distance":0}
