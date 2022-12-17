//
//  FeedbackModels.swift
//  TranxitUser
//
//  Created by Umair Khan on 09/07/2022.
//  Copyright © 2022 Appoets. All rights reserved.
//

import Foundation

//MARK:- FeedbackDataModel

struct FeedbackOption {
    var optionTitle: String
    var optionDescription: String = ""
    var isOptionDescriptionHidden: Bool = true
}

struct FeedbackInterfaceData {
    var mainTitle: String
    var mainDescription: String
    var submitBtnTitle: String
}
