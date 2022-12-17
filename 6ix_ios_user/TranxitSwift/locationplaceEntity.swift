//
//  locationplaceEntity.swift
//  TranxitUser
//
//  Created by ICM on 13/06/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import Foundation
import CoreLocation



class LocationPlaces: NSObject, NSCoding {
    var Location: CLLocationCoordinate2D
    
    
    
    init(Location: CLLocationCoordinate2D) {
        self.Location = Location
        
    }
    
    required convenience init(coder aDecoder: NSCoder) {
       
        let Location = (aDecoder.decodeObject(forKey: "Location") as? CLLocationCoordinate2D)!
         self.init(Location: Location)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(Location, forKey: "Location")
        
    }
}
