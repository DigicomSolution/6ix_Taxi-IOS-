//
//  EstimateFare.swift
//  User
//
//  Created by CSS on 31/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

class EstimateFare : JSONSerializable {
    
    var estimated_fare : Float?
    var distance : Float?
    var time : String?
    var surge_value : String?
    var model :String?
    var surge :Int?
    var wallet_balance : Float?
    var useWallet : Int?
    var base_price : Float?
    var service_type : Int?
    
   /* required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let estimateFare = try? values.decode(Int.self, forKey: .estimated_fare) {
            estimated_fare = Float(estimateFare)
        } else {
            estimated_fare = try? values.decode(Float.self, forKey: .estimated_fare)
        }
        
        if let distanceValue = try? values.decode(Int.self, forKey: .distance) {
            distance = Float(distanceValue)
        } else {
            distance = try? values.decode(Float.self, forKey: .distance)
        }
        
        if let walletBalance = try? values.decode(Int.self, forKey: .wallet_balance) {
            wallet_balance = Float(walletBalance)
        } else {
            wallet_balance = try? values.decode(Float.self, forKey: .wallet_balance)
        }
        
        if let basePrice = try? values.decode(Int.self, forKey: .base_price) {
            base_price = Float(basePrice)
        } else {
            base_price = try? values.decode(Float.self, forKey: .base_price)
        }
        
        time = try? values.decode(String.self, forKey: .time)
        surge_value = try? values.decode(String.self, forKey: .surge_value)
        model = try? values.decode(String.self, forKey: .model)
        surge = try? values.decode(Int.self, forKey: .surge)
        useWallet = try? values.decode(Int.self, forKey: .useWallet)
        service_type = try? values.decode(Int.self, forKey: .service_type)
       
    } */
    
    
}


