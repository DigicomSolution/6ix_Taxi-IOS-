//
//  WalkThroughPreviewController.swift
//  User
//
//  Created by CSS on 27/04/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class WalkThroughPreviewController: UIViewController {
    
    @IBOutlet private weak var imageView : UIImageView!
    @IBOutlet private weak var labelTitle : UILabel!
    @IBOutlet private weak var labelSubTitle : UILabel!
    
    private var arrayData : (UIImage?,String?,String?)?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewControllerName = String.init(describing: self.classForCoder)
        print("VCName***: \(viewControllerName)")
        self.intialLoads()
    }

}

//MARK:- Methods

extension WalkThroughPreviewController {
    
    private func intialLoads(){
        
//        self.labelTitle.textColor = .primary
        self.imageView.image = arrayData?.0
        self.labelTitle.text = arrayData?.1?.localize()
        self.labelSubTitle.text = arrayData?.2?.localize()
        self.design()
        
    }
    
    func set(image : UIImage?, title : String?, description descriptionText : String?){
        
       self.arrayData = (image,title,descriptionText)
        
    }
    
    
    private func design(){
        
        Common.setFont(to: self.labelTitle, isTitle: true, size: 20)
        Common.setFont(to: self.labelSubTitle)
    }
    
}
