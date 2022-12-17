//
//  MultiLocationTableViewCell.swift
//  TranxitUser
//
//  Created by Somi on 30/05/2020.
//  Copyright © 2020 Appoets. All rights reserved.
//

import UIKit

class MultiLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var stopTitleLabel: UILabel!
    
    var delegate: locationButtonsDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func addButtonAction(_ sender: UIButton)
    {
        if delegate != nil
        {
            delegate?.addRow(row: sender.tag + 1)
        }
        print("Add button pressed")
    }
    @IBAction func crossButtonAction(_ sender: UIButton)
    {
        if delegate != nil
        {
            delegate?.removeRow(row: sender.tag)
        }
        print("cross button pressed")
    }
    @IBAction func onClear(_ sender: UIButton) {
        locationTextField.text = ""
    }
}

protocol locationButtonsDelegate {
    func addRow(row: Int)
    func removeRow(row: Int)
}
