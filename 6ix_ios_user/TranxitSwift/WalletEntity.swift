//
//  WalletEntity.swift
//  User
//
//  Created by CSS on 02/08/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

class WalletEntity : JSONSerializable {
    var message : String?
    var balance : Float?
    var wallet_balance : Float?
    var wallet_transation : [WalletTransaction]?
}

struct WalletTransaction : JSONSerializable {
    var amount : Float?
    var close_balance : Float?
    var transaction_alias : String?
    var created_at : String?
    var transaction_desc : String?
}
