//
//  EstimatedFareViewController.swift
//  TranxitUser
//
//  Created by Hexacrew on 17/04/2020.
//  Copyright © 2020 Appoets. All rights reserved.
//

import UIKit

class EstimatedFareViewController: UIViewController {
    
    
    @IBOutlet weak var estimatedFareAskLabel:UILabel!
    @IBOutlet weak var estimatedFareTagLabel:UILabel!
    @IBOutlet weak var estimatedFareLabel:UILabel!
    @IBOutlet weak var comfirmButton:UIButton!
    @IBOutlet weak var cancelButton:UIButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let viewControllerName = String.init(describing: self.classForCoder)
        print("VCName***: \(viewControllerName)")

        // Do any additional setup after loading the view.
    }


   
}
