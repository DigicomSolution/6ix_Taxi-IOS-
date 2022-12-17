//
//  User.swift
//  User
//
//  Created by CSS on 17/01/18.
//  Copyright © 2018 Appoets. All rights reserved.
//


import Foundation

class User : NSObject, NSCoding, JSONSerializable {
    
    static var main = initializeUserData()
    
    var id : Int?
    var accessToken : String?
    var firstName : String?
    var lastName :String?
    var picture : String?
    var email : String?
    var mobile : String?
    var currency : String?
    var refreshToken : String?
    var wallet_balance : Float?
    var sos : String?
    var loginType : String?
    var dispatcherNumber : String?
    var isCashAllowed : Bool
    var isCardAllowed : Bool
    var measurement : String?
    var stripeKey : String?
    var company_id : String?
    var corporate_id : String?
    var company_name : String?
    var emp_id : String?
    var corp_deleted : Int?
    var corporate_pin : Int?
    var walletLimit:String?
    
    init(id : Int?, accessToken : String?, firstName : String?, lastName : String?, mobile : String?, email : String?, currency : String?, picture : String?, refreshToken : String?, walletBalance : Float?, sos : String?, loginType : String?, dispatcherNumber : String?, isCardAllowed : Bool, isCashAllowed : Bool, measurement : String?, stripeKey : String?,companyId:String?, companyName:String?,corporate_id: String?,empId:String?,corp_deleted:Int?,corporate_pin:Int?,walletLimit:String?){
        
        self.id = id
        self.accessToken = accessToken
        self.firstName = firstName
        self.lastName = lastName
        self.mobile = mobile
        self.email = email
        self.currency = currency
        self.picture = picture
        self.refreshToken = refreshToken
        self.wallet_balance = walletBalance
        self.sos = sos
        self.loginType = loginType
        self.dispatcherNumber = dispatcherNumber
        self.isCardAllowed = isCardAllowed
        self.isCashAllowed = isCashAllowed
        self.measurement = measurement
        self.stripeKey = stripeKey
        self.company_id = companyId
        self.corporate_id = corporate_id
        self.company_name = companyName
        self.emp_id = empId
        self.corp_deleted = corp_deleted
        self.corporate_pin = corporate_pin
        self.walletLimit   = walletLimit
        
    }
    
    convenience
    override init(){
        self.init(id: nil, accessToken: nil, firstName : nil, lastName : nil, mobile : nil, email : nil, currency : nil, picture : nil, refreshToken : nil, walletBalance : nil, sos : nil, loginType : nil,dispatcherNumber : nil, isCardAllowed: false, isCashAllowed : true, measurement : "km", stripeKey : nil ,companyId:nil ,companyName:nil ,corporate_id:nil, empId:nil,corp_deleted:nil,corporate_pin:nil,walletLimit:nil)
    }
    
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        let id = aDecoder.decodeObject(forKey: Keys.list.idKey) as? Int
        let accessToken = aDecoder.decodeObject(forKey: Keys.list.accessToken) as? String
        let firstName = aDecoder.decodeObject(forKey: Keys.list.firstName) as? String
        let lastName = aDecoder.decodeObject(forKey: Keys.list.lastName) as? String
        let mobile = aDecoder.decodeObject(forKey: Keys.list.mobile) as? String
        let email = aDecoder.decodeObject(forKey: Keys.list.email) as? String
        let currency = aDecoder.decodeObject(forKey: Keys.list.currency) as? String
        let picture = aDecoder.decodeObject(forKey: Keys.list.picture) as? String
        let refreshToken = aDecoder.decodeObject(forKey: Keys.list.refreshToken) as? String
        let walletBalance = aDecoder.decodeObject(forKey: Keys.list.wallet) as? Float
        let sos = aDecoder.decodeObject(forKey: Keys.list.sos) as? String
        let loginType = aDecoder.decodeObject(forKey: Keys.list.loginType) as? String
        let dispatcherNumber = aDecoder.decodeObject(forKey: Keys.list.dispacher) as? String
        let isCardAllowed = aDecoder.decodeBool(forKey: Keys.list.card)
        let isCashAllowed = aDecoder.decodeBool(forKey: Keys.list.cash)
        let measurement = aDecoder.decodeObject(forKey: Keys.list.measurement) as? String
        let stripeKey = aDecoder.decodeObject(forKey: Keys.list.stripe) as? String
        let company_id = aDecoder.decodeObject(forKey: Keys.list.company_id) as? String
        let corporate_id = aDecoder.decodeObject(forKey: Keys.list.corporate_id) as? String
        let company_name = aDecoder.decodeObject(forKey: Keys.list.company_name) as? String
        let emp_id = aDecoder.decodeObject(forKey: Keys.list.emp_id) as? String
        let corp_deleted = aDecoder.decodeObject(forKey: Keys.list.corp_deleted) as? Int
        let corporate_pin = aDecoder.decodeObject(forKey: Keys.list.corporate_pin) as? Int
        let walletLimit = aDecoder.decodeObject(forKey: Keys.list.walletLimet) as? String
        
        self.init(id: id, accessToken : accessToken, firstName : firstName, lastName : lastName, mobile : mobile, email: email, currency : currency, picture : picture, refreshToken : refreshToken, walletBalance : walletBalance, sos : sos,loginType : loginType, dispatcherNumber : dispatcherNumber, isCardAllowed : isCardAllowed, isCashAllowed : isCashAllowed, measurement : measurement, stripeKey : stripeKey,companyId:company_id ,companyName:company_name ,corporate_id:corporate_id, empId:emp_id,corp_deleted:corp_deleted,corporate_pin:corporate_pin, walletLimit: walletLimit)
        
    }
    
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.id, forKey: Keys.list.idKey)
        aCoder.encode(self.accessToken, forKey: Keys.list.accessToken)
        aCoder.encode(self.firstName, forKey: Keys.list.firstName)
        aCoder.encode(self.lastName, forKey: Keys.list.lastName)
        aCoder.encode(self.mobile, forKey: Keys.list.mobile)
        aCoder.encode(self.email, forKey: Keys.list.email)
        aCoder.encode(self.currency, forKey: Keys.list.currency)
        aCoder.encode(self.picture, forKey: Keys.list.picture)
        aCoder.encode(self.refreshToken, forKey: Keys.list.refreshToken)
        aCoder.encode(self.wallet_balance, forKey: Keys.list.wallet)
        aCoder.encode(self.sos, forKey: Keys.list.sos)
        aCoder.encode(self.loginType, forKey: Keys.list.loginType)
        aCoder.encode(self.dispatcherNumber, forKey: Keys.list.dispacher)
        aCoder.encode(self.isCashAllowed, forKey: Keys.list.cash)
        aCoder.encode(self.isCardAllowed, forKey: Keys.list.card)
        aCoder.encode(self.measurement, forKey: Keys.list.measurement)
        aCoder.encode(self.stripeKey, forKey: Keys.list.stripe)
        aCoder.encode(self.company_id, forKey: Keys.list.company_id)
        aCoder.encode(self.company_name, forKey: Keys.list.company_name)
        aCoder.encode(self.emp_id, forKey: Keys.list.emp_id)
        aCoder.encode(self.corp_deleted, forKey: Keys.list.corp_deleted)
        aCoder.encode(self.corporate_id, forKey: Keys.list.corporate_id)
        aCoder.encode(self.corporate_pin, forKey: Keys.list.corporate_pin)
        aCoder.encode(self.walletLimit, forKey: Keys.list.walletLimet)
        
        
    }
    
    
    
    
}





extension User{
    var walletBalance:String{
        return "\(User.main.currency ?? "Rs") \(User.main.wallet_balance ?? 0.00)"
    }
    var isShowOutstanding:Bool{
        let value: Double = Double(User.main.wallet_balance ?? 0.00)
        let limet: Double = User.main.walletLimit?.double ?? 0.00
        let isGreatThenOrEqual:Bool = limet.greaterThanOrEqual(value,precise:2)
        return isGreatThenOrEqual
    }
    
}



