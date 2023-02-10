//
//  RaiseFareVc.swift
//  TranxitUser
//
//  Created by Umer Tahir on 26/12/2022.
//  Copyright © 2022 Appoets. All rights reserved.
//

import UIKit

class RaiseFareVc: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let viewControllerName = String.init(describing: self.classForCoder)
        print("VCName***: \(viewControllerName)")

        // Do any additional setup after loading the view.
    }
    

    @IBAction func raiseFareBtnTapped(_ sender: UIButton) {
   
        self.dismiss(animated: true)
    }
    

}
