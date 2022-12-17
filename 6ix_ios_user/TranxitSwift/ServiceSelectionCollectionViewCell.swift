//
//  ServiceSelectionCollectionViewCell.swift
//  User
//
//  Created by CSS on 11/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class ServiceSelectionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var parentView: UIView!
    @IBOutlet private weak var imageViewService : UIImageView!
    @IBOutlet private weak var viewBackground : UIView!
    @IBOutlet private weak var labelETA : UILabel!
    @IBOutlet weak var kilometr: UILabel!
    @IBOutlet weak var capacityLabel: UILabel!
    @IBOutlet weak var carTypeLabel: UILabel!
    
    private var service : Service?
    
    override var isSelected: Bool {
        
        didSet{
            self.viewBackground.layer.masksToBounds = self.isSelected
            self.imageViewService.layer.masksToBounds = self.isSelected
            if #available(iOS 13.0, *) {
                
                if traitCollection.userInterfaceStyle == .dark{
                    
                    if isSelected{
                        self.parentView.backgroundColor = UIColor.white
                        self.parentView.colorShadow = .lightGray
                        self.parentView.layer.cornerRadius = 11
                        self.carTypeLabel.textColor = UIColor.black
                        self.labelETA.textColor = UIColor.black
                        self.viewBackground.borderColor = UIColor.black
                    }else{
                        self.parentView.backgroundColor = UIColor.secondarySystemBackground
                        self.parentView.colorShadow = .clear
                        self.parentView.layer.cornerRadius = 0
                        self.carTypeLabel.textColor = UIColor.white
                        self.labelETA.textColor = UIColor.white
                        self.viewBackground.borderColor = UIColor.clear
                    }
                    
                    
                }else{
                    
                    if isSelected{
                        self.parentView.backgroundColor = UIColor.white
                        self.parentView.colorShadow = .lightGray
                        self.parentView.layer.cornerRadius = 11
                        self.carTypeLabel.textColor = UIColor.black
                        self.labelETA.textColor = UIColor.black
                        self.viewBackground.borderColor = UIColor.black
                    }else{
                        self.parentView.backgroundColor = UIColor.secondarySystemBackground
                        self.parentView.colorShadow = .clear
                        self.parentView.layer.cornerRadius = 0
                        self.carTypeLabel.textColor = UIColor.black
                        self.labelETA.textColor = UIColor.black
                        self.viewBackground.borderColor = UIColor.clear
                    }
                    
                }
                
               
            } else {
                if isSelected{
                    self.parentView.backgroundColor = UIColor.white
                    self.parentView.colorShadow = .lightGray
                    self.parentView.layer.cornerRadius = 11
                }else{
                    self.parentView.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.00)
                    self.parentView.colorShadow = .clear
                    self.parentView.layer.cornerRadius = 0
                }
                
            }
            
            self.layoutIfNeeded()
            self.viewBackground.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.00)
            
            self.setLabelPricing()
        }
    }
    
    func set(value : Service) {
        
        capacityLabel.text = "\(value.capacity ?? 0)"
        
        self.service = value
        carTypeLabel.text = value.name
        
        let distance = Double(value.kilometer ?? 0.0)
        print("distance>>>>",distance)
        kilometr.text = "\(String(distance))\(" Km")"
        
        self.imageViewService.setImage(with: value.image, placeHolder: #imageLiteral(resourceName: "sedan-car-model").withRenderingMode(.alwaysTemplate))
        self.setLabelPricing()
        

    }
    
    func setLabelPricing() {
        self.labelETA.text =  isSelected ? {
            if let fare = self.service?.pricing?.estimated_fare {
                return "\(User.main.currency!) \(String(format: "%.2f", fare))"
                // - \(String(format: "%.2f", fare+3))
            }
            return nil
            }() : nil
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialLoads()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.viewBackground.cornerRadius = self.viewBackground.frame.width/2
    }
    
}


private extension ServiceSelectionCollectionViewCell {
    
    // MARK:- Set Designs
    
    private func setDesign() {
    }
    
    
    private func initialLoads(){
        self.imageViewService.image = #imageLiteral(resourceName: "sedan-car-model").withRenderingMode(.alwaysTemplate)
        self.viewBackground.borderColor = .clear
        self.viewBackground.borderLineWidth = 1
        self.setDesign()
    }
}
