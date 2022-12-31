//
//  Offers.swift
//  TranxitUser
//
//  Created by Umer Tahir on 31/12/2022.
//  Copyright © 2022 Appoets. All rights reserved.
//

import Foundation


// MARK: - Offer
struct Offer: JSONSerializable {
    var id, requestID, providerID, status: Int?
    var dropped: Int?
    var offerPrice: Double?
    var provider: OfferProvider?

    enum CodingKeys: String, CodingKey {
        case id
        case requestID = "request_id"
        case providerID = "provider_id"
        case status, dropped
        case offerPrice = "offer_price"
        case provider
    }
}

// MARK: - Provider
struct OfferProvider: JSONSerializable {
    var id: Int?
    var firstName, lastName, email, gender: String?
    var mobile, avatar, rating, status: String?
    var fleet: Int?
    var latitude, longitude: Double?
    var stripeAccID, stripeCustID: String?
    var otp: Int?
    var walletBalance: Double?
    var createdAt, updatedAt, loginBy, socialUniqueID: String?
    var isMobileVerified: Int?
    var deleteProfileReason: String?
    var service: Service?
    var profile: String?

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email, gender, mobile, avatar, rating, status, fleet, latitude, longitude
        case stripeAccID = "stripe_acc_id"
        case stripeCustID = "stripe_cust_id"
        case otp
        case walletBalance = "wallet_balance"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case loginBy = "login_by"
        case socialUniqueID = "social_unique_id"
        case isMobileVerified = "is_mobile_verified"
        case deleteProfileReason = "delete_profile_reason"
        case service, profile
    }
}

