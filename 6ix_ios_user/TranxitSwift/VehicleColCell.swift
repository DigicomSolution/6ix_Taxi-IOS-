//
//  VehicleColCell.swift
//  TranxitUser
//
//  Created by Umer Tahir on 26/12/2022.
//  Copyright © 2022 Appoets. All rights reserved.
//

import UIKit

class VehicleColCell: UICollectionViewCell {

    @IBOutlet weak var vehicleNAme: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var selectedButton: UIButton!
    
    
    var onClickProceed : ((Service)->Void)? // Onlclick Ride Now
    var onClickService : ((Service?)->Void)? // Onclick each servicetype
    
    
    
    var onClickTowService : ((Service?)->Void)? // Onclick each servicetype
    var onClickBoatService : ((Service?)->Void)? // Onclick each servicetype
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        
        
    }

    @IBAction func selectBtnTapped(_ sender: UIButton) {
        
    }
    
    func setData(ride : Service, indexPath: IndexPath){
        
        
        desLabel.text = "\(ride.capacity ?? 0) Persons Can Ride"
        
//        self.service = value
       vehicleNAme.text = ride.name
        
        if indexPath.row % 2 == 0
        {
            self.imageLabel.image = UIImage(named: "car2")
        }
        else
        {
            self.imageLabel.image = UIImage(named: "car")
        }
        
        //self.imageLabel.setImage(with: ride.image, placeHolder: #imageLiteral(resourceName: "sedan-car-model"))
                                    //.withRenderingMode(.alwaysTemplate))
    }
}
