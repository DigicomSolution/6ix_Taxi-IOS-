//
//  OfferCell.swift
//  TranxitUser
//
//  Created by Umer Tahir on 24/12/2022.
//  Copyright © 2022 Appoets. All rights reserved.
//

import UIKit

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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
   
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func acceptBtnTapped(_ sender: UIButton) {
    }
    @IBAction func declineBtnTapped(_ sender: UIButton) {
    }
    
    
    func setData(item: Offer, distane: String, time: String){
        
        priceLabel.text = "C$\(item.offerPrice ?? 0)"
       // timeLAbel.text =
        driverNameLabel.text = "\(item.provider?.firstName ?? "-" ) \(item.provider?.lastName ?? "-" )"
        vehicleNameLabel.text = item.provider?.service?.service_number ?? ""
        reviewLAbel.text = item.provider?.rating ?? ""
        
        distanceLabel.text = "\(distane)"
        timeLAbel.text = "\(time)"
    }
    
}
