//
//  JailbrokenDeviceViewController.swift
//  TranxitUser
//
//  Created by Umair Khan on 28/09/2020.
//  Copyright © 2020 Appoets. All rights reserved.
//

import UIKit

class JailbrokenDeviceViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let viewControllerName = String.init(describing: self.classForCoder)
        print("VCName***: \(viewControllerName)")

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
