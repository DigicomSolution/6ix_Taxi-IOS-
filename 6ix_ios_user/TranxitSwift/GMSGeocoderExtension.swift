//
//  GMSGeocoderExtension.swift
//  HouseUp
//
//  Created by Macbook on 30/09/2020.
//  Copyright © 2020 welldoneapps. All rights reserved.
//
import GoogleMaps
import Foundation
public typealias KMyLocationComplitaion =  (_ myLocation: MyLocation?, _ error: String?) -> Void
extension GMSGeocoder{
   class func addressFormCoordinate(coordinate: CLLocationCoordinate2D,complition:@escaping KMyLocationComplitaion) -> Void {
        GMSGeocoder().reverseGeocodeCoordinate(coordinate) { (response, error) in
            var currentaddress = ""
            if error == nil{
                if let addressObj: GMSReverseGeocodeResult = response!.firstResult(){
                let thoroughfare = addressObj.thoroughfare ?? ""
                let subLocality  = addressObj.subLocality ?? ""
                if thoroughfare.isEmpty {
                    currentaddress = subLocality + " " + (addressObj.locality ?? " ")
                }else if subLocality.isEmpty {
                    currentaddress = thoroughfare + " " + (addressObj.locality ?? " ")
                    
                }else{
                     currentaddress = thoroughfare + " " + subLocality + " " + addressObj.locality!
                }
                let myLocation = MyLocation(with: currentaddress, coordinate: addressObj.coordinate,city: (addressObj.locality ?? " ") ,state:addressObj.administrativeArea,country: addressObj.country)
                complition(myLocation,nil)
                }
                complition(nil,"No Address found")
            }else{
                complition(nil,error?.localizedDescription)
            }
            
        }
       
    }
}
