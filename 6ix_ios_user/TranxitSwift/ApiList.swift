//
//  ApiList.swift
//  Centros_Camprios
//
//  Created by imac on 12/18/17.
//  Copyright © 2017 Appoets. All rights reserved.
//

import Foundation

//Http Method Types

enum HttpType : String{
    
    case GET = "GET"
    case POST = "POST"
    case PATCH = "PATCH"
    case PUT = "PUT"
    case DELETE = "DELETE"
    
}

// Status Code

enum StatusCode : Int {
    
    case notreachable = 0
    case success = 200
    case multipleResponse = 300
    case unAuthorized = 401
    case notFound = 404
    case ServerError = 500
    
}



enum Base : String{
  
    
    case signUp = "/api/user/signup"
    case login = "/api/user/oauth/token" // /oauth/token
    case googleLogin = "/api/user/auth/google"
    case facebookLogin = "/api/user/auth/facebook"
    case appleLogin = "/api/user/social/apple" //https://l7-stagging.6ixtaxi.com/api/user/social/apple
    case getProfile = "/api/user/details"
    case updateProfile = "/api/user/update/profile"
    case resetPassword = "/api/user/reset/password"
    case changePassword = "/api/user/change/password"
    case forgotPassword = "/api/user/forgot/password"
    case googleMaps = "https://maps.googleapis.com/maps/api/geocode/json"
    case servicesList = "/api/user/services"
    case estimateFare = "/api/user/v1/estimated/fare"
    case getProviders = "/api/user/v1/show/providers"
    case sendRequest = "/api/user/v2/send/request"
    case cancelRequest = "/api/user/v1/cancel/request"
    case checkRequest = "/api/user/v2/request/check"
    case updateRequest = "/api/user/v1/update/request"
    case payNow = "/api/user/payment"
    case rateProvider = "/api/user/rate/provider"
    case historyList = "/api/user/trips"
    case upcomingList = "/api/user/upcoming/trips"
    case locationService = "/api/user/location"
    case locationServicePostDelete = "//api/user/location"
    case addPromocode = "/api/user/promocode/add"
    case walletPassbook = "/api/user/wallet/passbook"
    case couponPassbook = "/api/user/promo/passbook"
    case logout = "/api/user/logout"
    case pastTripDetail = "/api/user/v1/trip/details"
    case upcomingTripDetail = "/api/user/upcoming/trip/details"
    case getCards = "//api/user/card"
    case postCards = "/api/user/card"
    case deleteCard = "/api/user/card/destory"
    case userVerify = "/api/user/verify"
    case addMoney = "/api/user/add/money"
    case chatPush = "/api/user/chat"
    case promocodes = "/api/user/promocodes_list"
    case updateLanguage = "/api/user/update/language"
    case versionCheck = "/api/user/checkversion"
    case help = "/api/user/help"
    case payNowElavon = "/api/user/elavonpayment"
    case companyList = "/api/user/companyList"
    case corporateUser = "/api/user/edit/corprofile"
    
    case sendCodeNo = "/api/user/send-mobile-verification-code"
    case verifyCodeNo = "/api/user/verify-mobile-verification-code"
    
    
    
    case addTip = "/api/user/payment/tips"
    
    
    
    
    case isMobileVerfiy = "/api/user/is-mobile-verified"
    
    
    case isAppleMobileVerify = "/api/user/is-mobile-verified/"

    case deleteAccount = "/api/user"

    init(fromRawValue: String){
        self = Base(rawValue: fromRawValue) ?? .signUp
    }
    
    static func valueFor(Key : String?)->Base{
        
        guard let key = Key else {
            return Base.signUp
        }
        
//        for val in iterateEnum(Base.self) where val.rawValue == key {
//            return val
//        }
        
        if let base = Base(rawValue: key) {
            return base
        }
        
        return Base.signUp
        
    }
    
}
