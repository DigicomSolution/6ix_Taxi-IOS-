//
//  WaitTimeViewController.swift
//  TranxitUser
//
//  Created by Muhammad Yousaf on 21/02/2022.
//  Copyright © 2022 Appoets. All rights reserved.
//

import UIKit

class WaitTimeViewController: UIViewController {
    
    @IBOutlet weak var zeroMinButton:UIButton!
    @IBOutlet weak var fiveMinButton:UIButton!
    @IBOutlet weak var tenMinButton:UIButton!
    @IBOutlet weak var fifteenMinButton:UIButton!
    @IBOutlet weak var twentyMinButton:UIButton!
    
    
    private var waitMinutes:Int?
    
    var waitTimeDelegate:WaitTimeDelegate?
    
    
    var allTimeButton = [UIButton]()

    override func viewDidLoad() {
        super.viewDidLoad()
        allTimeButton = [zeroMinButton,fiveMinButton,tenMinButton,fifteenMinButton,twentyMinButton]

        // Do any additional setup after loading the view.
    }

    @IBAction func timeSelectAction(_ sender:UIButton){
        self.waitMinutes = sender.tag
        self.setUpButton(tag: sender.tag)
    }
    
    func setUpButton(tag:Int){
        for button in allTimeButton {
            if tag == button.tag{
                button.borderColor = .clear
                button.backgroundColor = UIColor.init(red: 246/255, green: 203/255, blue: 79/255, alpha: 1.0)
            }else{
                button.borderColor = .black
                button.backgroundColor = UIColor.white
            }
        }
    }
    
    
    @IBAction func confirmButtonAction(_ sender:UIButton){
        
        if let waitMinutes = waitMinutes {
            self.waitTimeDelegate?.confirmTimeAction(minutes: waitMinutes)
//            self.waitTimeDelegate?.confirmTimeAction(minutes: 0)
            return
        }
        self.view.make(toast: ErrorMessage.list.selectWaitTime.localize())
        
    }
    
    
    @IBAction func crossAction(_ sender:UIButton){
        self.waitTimeDelegate?.crossAction()
    }

    
}



protocol WaitTimeDelegate{
    func crossAction()
    func confirmTimeAction(minutes:Int)
}
