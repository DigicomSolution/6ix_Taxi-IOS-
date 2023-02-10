//
//  ConvergeElavonViewController.swift
//  TranxitUser
//
//  Created by CSS09 on 18/03/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import UIKit
import WebKit

class ConvergeElavonViewController: UIViewController,WKUIDelegate {

    @IBOutlet weak var paymentWebView: WKWebView!
    var urlStr : String?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewControllerName = String.init(describing: self.classForCoder)
        print("VCName***: \(viewControllerName)")

        
        let myURL = URL(string:urlStr!)
        let myRequest = URLRequest(url: myURL!)
        paymentWebView.load(myRequest)
        // Do any additional setup after loading the view.
    }
    

    

}
