//
//  WaitingTimeSelectionViewController.swift
//  TranxitUser
//
//  Created by syed zia on 11/01/2022.
//  Copyright © 2022 Appoets. All rights reserved.
//

import UIKit
protocol  WaitingTimeSelectionViewControllerDelegate{
    func waitingTimeSelected(_ service: Service)
}

class WaitingTimeSelectionViewController: UIViewController {

    @IBOutlet var selectionLabel: UILabel!
    
    @IBOutlet var minutesButton: [Button]!
  
    var service : Service?
    var delegate:WaitingTimeSelectionViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewControllerName = String.init(describing: self.classForCoder)
        print("VCName***: \(viewControllerName)")
        Common.setFont(to: selectionLabel!, isTitle: true, size: 25)
        minutesButton.forEach { button in
            Common.setFont(to: button, isTitle: false)
        }
        // Do any additional setup after loading the view.
    }
    
    
    
}

// MARK: - IBaction -
extension WaitingTimeSelectionViewController {
    @IBAction func minButtonPressed(_ sender: Button) {
        setSelection(sender)
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        self.delegate.waitingTimeSelected(self.service!)
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - Privete Functions -

extension WaitingTimeSelectionViewController {
    func setSelection(_ sender: Button){
        if let selectedText = sender.currentTitle{
        selectionLabel.text = selectedText.replace(string: "min", replacement: "Minutes")
//        service?.waitingTime = selectedText
        }
    }
    
    func setSelectedColor(_ sender: Button) {
        let buttonTextColor = sender.titleLabel?.textColor
        minutesButton.forEach { button in
            if sender == button {
                let color = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
                button.setTitleColor(color, for: .normal)
            }else{
                button.setTitleColor(buttonTextColor, for: .normal)
            }
        }
    }
}
