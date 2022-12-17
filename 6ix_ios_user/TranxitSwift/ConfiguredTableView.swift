//
//  ConfiguredTableView.swift
//  TranxitUser
//
//  Created by Umair Khan on 09/07/2022.
//  Copyright © 2022 Appoets. All rights reserved.
//

import UIKit

class ConfiguredTableView: UITableView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
        layoutSubviews()
        return contentSize
    }
}
