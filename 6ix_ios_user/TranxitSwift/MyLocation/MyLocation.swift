//
//  MyLocation.swift
//  HouseUp
//
//  Created by Macbook on 29/09/2020.
//  Copyright © 2020 welldoneapps. All rights reserved.
//
import FlagPhoneNumber
import CoreLocation
import Foundation
public struct MyLocation {
    var address:String?
    var coordinate:CLLocationCoordinate2D?
    var lat: String?
    var lng: String?
    var city:String?
    var state:String?
    var country:String?
    var streetNumber:String?
    var streetName:String?
    var streetAddress:String?
    var postalCode:String?
    var redius:String?
    var rediusValue:String?
    var coordinateString: String?
}
extension MyLocation{
    var countryCode:FPNCountryCode{
        let countryRepository = FPNCountryRepository()
        return countryRepository.getCode(by: country ?? "Pakistan")
    }
}
extension MyLocation{
    var isPakistan:Bool{
        return country?.lowercased() == "Pakistan".lowercased()
    }
}
extension MyLocation{
    init(with adrress: String, coordinate: CLLocationCoordinate2D,city: String?) {
        self.address = adrress
        self.coordinate = coordinate
        self.coordinateString = "\(coordinate.latitude)" + "," + "\(coordinate.longitude)"
        self.lat = "\(coordinate.latitude)"
        self.lng = "\(coordinate.longitude)"
        self.city = city
    }
}
extension MyLocation{
    init(with adrress: String, coordinate: CLLocationCoordinate2D,city: String?,state:String?,country:String?) {
        self.address = adrress
        self.coordinate = coordinate
        self.coordinateString = "\(coordinate.latitude)" + "," + "\(coordinate.longitude)"
        self.lat = "\(coordinate.latitude)"
        self.lng = "\(coordinate.longitude)"
        self.city = city
        self.state = state
        self.country = country
    }
}
