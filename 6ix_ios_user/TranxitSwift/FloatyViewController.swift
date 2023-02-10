//
//  KCFABViewController.swift
//  KCFloatingActionButton-Sample
//
//  Created by LeeSunhyoup on 2015. 10. 13..
//  Copyright © 2015년 kciter. All rights reserved.
//

import UIKit

/**
    KCFloatingActionButton dependent on UIWindow.
*/
open class FloatyViewController: UIViewController {
    public let floaty = Floaty()
    var statusBarStyle: UIStatusBarStyle = .default

    override open func viewDidLoad() {
        super.viewDidLoad()
        let viewControllerName = String.init(describing: self.classForCoder)
        print("VCName***: \(viewControllerName)")
        view.addSubview(floaty)
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return statusBarStyle
        }
    }
}
