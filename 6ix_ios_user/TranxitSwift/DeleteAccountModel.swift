//
//  DeleteAccountModel.swift
//  TranxitUser
//
//  Created by Umair Khan on 09/07/2022.
//  Copyright © 2022 Appoets. All rights reserved.
//

import Foundation

struct DeleteAccountModel: JSONSerializable {
    let password: String
    let reason: String
}

struct DeleteAccountResponseModel: Decodable {
    let status: Bool
    let message: String
}
