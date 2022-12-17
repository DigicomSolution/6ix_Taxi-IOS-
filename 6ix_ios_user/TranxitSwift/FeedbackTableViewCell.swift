//
//  FeedbackTableViewCell.swift
//  TranxitUser
//
//  Created by Umair Khan on 09/07/2022.
//  Copyright © 2022 Appoets. All rights reserved.
//

import UIKit

class FeedbackTableViewCell: UITableViewCell {

    @IBOutlet weak var optionTitleLabel: UILabel!
    @IBOutlet weak var optionDescriptionLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populateData(optionData: FeedbackOption, isSelected: Bool){
        optionTitleLabel.text = optionData.optionTitle
        optionDescriptionLabel.isHidden = optionData.isOptionDescriptionHidden
        optionDescriptionLabel.text = optionData.optionDescription
        
       updateIsOptionSelected(isSelected: isSelected)
    }
    
    func updateIsOptionSelected(isSelected: Bool){
        if isSelected{
            checkmarkImageView.image = UIImage(named: "Checkmark Round")
        }else{
            checkmarkImageView.image = UIImage(named: "Empty")
        }
    }
    
}

