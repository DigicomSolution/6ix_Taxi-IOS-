//
//  OfferCell.swift
//  TranxitUser
//
//  Created by Umer Tahir on 24/12/2022.
//  Copyright © 2022 Appoets. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

class OfferCell: UITableViewCell {

    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var reviewLAbel: UILabel!
    @IBOutlet weak var totalReviewCountLabel: UILabel!
    @IBOutlet weak var driverProfileImage: UIImageView!
    @IBOutlet weak var vehicleNameLabel: UILabel!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLAbel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var acceptBlock : (()->Void)?
    var rejectBlock : (()->Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
   
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func acceptBtnTapped(_ sender: UIButton) {
        acceptBlock?()
        
    }
    @IBAction func declineBtnTapped(_ sender: UIButton) {
        rejectBlock?()
    }
    
    
    func setData(item: Offer, currency: String, currentLocation: CLLocation?){
        
        priceLabel.text = "\(currency)\(item.offerPrice ?? 0)"
        driverNameLabel.text = "\(item.provider?.firstName ?? "-" ) \(item.provider?.lastName ?? "-" )"
        vehicleNameLabel.text = item.provider?.service?.service_number ?? ""
        reviewLAbel.text = item.provider?.rating ?? ""
        
        //distanceLabel.text = "\(distane)"
        timeLAbel.text = "\(2)"
        let provLocation = CLLocation(latitude: item.provider?.latitude ?? 0.0, longitude: item.provider?.longitude ?? 0.0)
        if let distanceInMeters = currentLocation?.distance(from: provLocation) {
        let disInMile = (distanceInMeters/1609.344)
        distanceLabel.text = String(format: "%.2f", disInMile) + "m"
            if let l1 = currentLocation {
                getTimeAndDistance(currLocation: l1, destLocatoon: provLocation)
            }
        }
    }
    
    
    func getTimeAndDistance(currLocation : CLLocation, destLocatoon:CLLocation) {
        
        let directionURL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(currLocation.coordinate.latitude),\(destLocatoon.coordinate.longitude)&destination=\(destLocatoon.coordinate.latitude),\(destLocatoon.coordinate.longitude)&key=AIzaSyDyn0l-4-daP476zj5wlVCvn7oi3fFgT7Q"

        Alamofire.request(directionURL, method: .get, encoding: JSONEncoding.default, headers: nil).downloadProgress(queue: DispatchQueue.global(qos: .utility)){
                            progress in
                            print("Progress: \(progress.fractionCompleted)")
        }
        .responseJSON {
            response in
                if response.result.isSuccess {
                    if let data = response.result.value {
                    let jsonResult = data as! [String:Any]
                        if let route = jsonResult["routes"] as? [String:Any] {
                            if let f = route.first as? [String:Any] {
                              if  let legs = f["legs"] as? [String:Any] {
                                 if let fi = legs.first as? [String:Any] {
                                     if let disDic = fi["distance"] as? [String:Any] {
                                         if let dis = disDic["text"] as? String {
                                             self.distanceLabel.text = dis
                                         }
                                         
                                     }
                                     if let durDic = fi["duration"] as? [String:Any] {
                                         if  let dur = durDic["text"] as? String {
                                             self.timeLAbel.text = dur
                                         }
                                     }
                                  }
                                }
                            }
                        }
                    }

                }
                    
        }
        
    }
}

