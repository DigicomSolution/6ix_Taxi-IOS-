//
//  FPNCountryRepositoryExtension.swift
//  Provider
//
//  Created by syed zia on 02/12/2021.
//  Copyright © 2021 Appoets. All rights reserved.
//
import FlagPhoneNumber
import Foundation
extension FPNCountryRepository {
    func getCode(by name: String) -> FPNCountryCode {
        let allcountries = countries
        if let conutry = allcountries.filter({$0.name == name}).first{
            return conutry.code
        }
        return .PK
    }
}
