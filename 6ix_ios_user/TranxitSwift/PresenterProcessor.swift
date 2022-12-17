//
//  PresenterProcessor.swift
//  User
//
//  Created by imac on 1/1/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

class PresenterProcessor {

    static let shared = PresenterProcessor()

    func success(api : Base, response : Data)->String? {
        return response.getDecodedObject(from: DefaultMessage.self)?.message
    }
    
    // MARK:- Send Oath
    
    func loginRequest(data : Data)->LoginRequest? {
        let string = String(decoding: data, as: UTF8.self)
        print(string)
        return data.getDecodedObject(from: LoginRequest.self)
    }
    
    // MARK:- Send Profile
    
    func profile(data : Data)->Profile? {
        return data.getDecodedObject(from: Profile.self)
    }
    
    // MARK:- UserData
    
    func userData(data : Data)->UserDataResponse? {
        return data.getDecodedObject(from: ForgotResponse.self)?.user
    }
    
    // MARK:- Service List
    
    func serviceList(data : Data)->[Service] {
        return data.getDecodedObject(from: [Service].self) ?? []
    }
    
    // MARK:- Estimate Fare
    
    func estimateFare(data : Data)->EstimateFare? {
        let fare =  data.getDecodedObject(from: EstimateFare.self)
        return fare
    }
    
    // MARK:- Send Request
    
    func request(data : Data)->Request?{
        return data.getDecodedObject(from: Request.self)
    }
    
    // MARK:- Your Trips Modal
    
    func requestArray (data : Data)->[Request] {
        return data.getDecodedObject(from: [Request].self) ?? []
    }
    
    // MARK:- Location Service
    
    func locationService(data : Data)->LocationService? {
        return data.getDecodedObject(from: LocationService.self)
    }
    
    // MARK:- Coupon Wallet
    
    func couponWallet(data : Data)->[CouponWallet]{
        return data.getDecodedObject(from: [CouponWallet].self) ?? []
    }
    
    // MARK:- Get Card
    
    func getCards(data : Data)->[CardEntity] {
        return data.getDecodedObject(from: [CardEntity].self) ?? []
    }
    
    // MARK:- Send Wallet Entity
    
    func getWalletEntity(data : Data)->WalletEntity? {
        return data.getDecodedObject(from: WalletEntity.self)
    }
    
    // MARK:- Send Promocodes
    
    func getPromocodes(data : Data)->[PromocodeEntity] {
        return data.getDecodedObject(from: PromoCodeList.self)?.promo_list ?? []
    }
    
    // MARK:- Help
    
    func getHelpAPI(data : Data)->HelpEntity? {
        return data.getDecodedObject(from: HelpEntity.self)
    }
    
    // MARK:- Company List
    
    func getCompanyEntity(data : Data)->[CompanyModalObj]? {
        return data.getDecodedObject(from: [CompanyModalObj].self) ?? []
    }
    
    
    
    func mobileVerification(data : Data)->SendCodeMobileNo? {
        return data.getDecodedObject(from: SendCodeMobileNo.self)
    }
    
    
    func socialMobileVerification(data : Data)->SocialLoginMobileVerfied? {
           return data.getDecodedObject(from: SocialLoginMobileVerfied.self)
    }
    
    
    func addTipValue(data : Data)->TipModel? {
           return data.getDecodedObject(from: TipModel.self)
    }
    
    func deleteAccount(data : Data)->DeleteAccountResponseModel? {
           return data.getDecodedObject(from: DeleteAccountResponseModel.self)
    }
    
    
}






