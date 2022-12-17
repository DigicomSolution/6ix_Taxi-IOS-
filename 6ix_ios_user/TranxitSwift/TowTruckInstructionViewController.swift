//
//  TowTruckInstructionViewController.swift
//  TranxitUser
//
//  Created by Hexacrew on 06/05/2020.
//  Copyright © 2020 Appoets. All rights reserved.
//

import UIKit

class TowTruckInstructionViewController: UIViewController {
    
    var isBooster:Int = 1
    
    @IBOutlet weak var boosterCableBtn:UIButton!
    @IBOutlet weak var noBoosterCableBtn:UIButton!
    @IBOutlet weak var doneBtn:UIButton!
    @IBOutlet weak var cancelBtn:UIButton!
      
      
    @IBOutlet weak var instructionText:UITextField!
  //  @IBOutlet weak var 

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func boosterAction(_ sender:UIButton){
        
        if sender.tag == 1 {
            
            noBoosterCableBtn.setImage(UIImage(named:"radio-on-button"), for: .normal)
            boosterCableBtn.setImage(UIImage(named:"circle-shape-outline"), for: .normal)
            isBooster = 0
         
            
        }else{
            boosterCableBtn.setImage(UIImage(named:"radio-on-button"), for: .normal)
            noBoosterCableBtn.setImage(UIImage(named:"circle-shape-outline"), for: .normal)
            isBooster = 1
        }
        
        
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
