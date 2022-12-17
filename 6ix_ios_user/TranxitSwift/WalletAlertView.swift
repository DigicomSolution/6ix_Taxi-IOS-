//
//  WalletAlertView.swift
//  TranxitUser
//
//  Created by syed zia on 26/11/2021.
//  Copyright © 2021 Appoets. All rights reserved.
//

import UIKit
import Alamofire

class WalletAlertView: UIView {

    @IBOutlet var titleLabel: UILabel!{
        didSet{
            titleLabel.attributedText = attributedtitle
            titleLabel.textAlignment  = .center
        }
        
    }
    
    private var attributedtitle: NSAttributedString{
        let outstandine =  "\(User.main.walletBalance)"
        let heading = "Please Pay your outstandine balance."
        let attributted = (outstandine + "\n\n" + heading).getAttributedString()
        let mediumFont = UIFont(name:FontCustom.Bold.rawValue, size: 18)
        let boldFont = UIFont(name:FontCustom.Medium.rawValue , size: 16)
        attributted.apply(font:mediumFont! , subString: outstandine)
        attributted.apply(font:boldFont! , subString: heading)
        return attributted
    }
    
    var onOkButtonClick : (()->Void)! //
    var onPayClick : (()->Void)!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBAction func okayButtonPressed(_ sender: UIButton) {
        self.onOkButtonClick!()
    }
    @IBAction func payButtonPressed(_ sender: UIButton) {
        self.onPayClick!()
    }
}
