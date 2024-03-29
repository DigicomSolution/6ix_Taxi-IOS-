//
//  ForgotPasswordViewController.swift
//  User
//
//  Created by CSS on 28/04/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet private var viewNext: UIView!
    @IBOutlet private var textFieldEmail : HoshiTextField!
    @IBOutlet private var scrollView : UIScrollView!
    @IBOutlet private var viewScroll : UIView!
    
    private lazy var loader : UIView = {
        return createActivityIndicator(UIScreen.main.focusedView ?? self.view)
    }()
    
    var emailString : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewControllerName = String.init(describing: self.classForCoder)
        print("VCName***: \(viewControllerName)")
        self.initialLoads()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.viewNext.makeRoundedCorner()
//        self.setFrame()
    }
    
}

//MARK:- Methods

extension ForgotPasswordViewController {
    
    private func initialLoads(){
        
        self.setDesigns()
        self.localize()
        self.view.dismissKeyBoardonTap()
        self.viewNext.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.nextAction)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(self.backButtonClick))
        if #available(iOS 13.0, *) {
            self.navigationController?.navigationBar.barTintColor = UIColor.systemBackground
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
            self.navigationController?.navigationBar.tintColor = UIColor.label
        }else{
            self.navigationController?.navigationBar.tintColor = UIColor.black
        }
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationItem.largeTitleDisplayMode = .never
        }
        self.scrollView.addSubview(viewScroll)
        self.scrollView.isDirectionalLockEnabled = true
        self.setFrame()
        self.textFieldEmail.text = emailString
        
    }
    
    private func setFrame() {
        
        self.viewScroll.frame = self.scrollView.bounds
        self.scrollView.contentSize = self.viewScroll.bounds.size
    }
    
    
    private func setDesigns(){
        
         if #available(iOS 13.0, *) {
            self.textFieldEmail.borderActiveColor = .label
         } else {
            self.textFieldEmail.borderActiveColor = .primary
         }
        self.textFieldEmail.borderInactiveColor = .lightGray
        self.textFieldEmail.placeholderColor = .gray
        self.textFieldEmail.delegate = self
        Common.setFont(to: textFieldEmail)
    }
    
    
    private func localize(){
        
        self.textFieldEmail.placeholder = Constants.string.emailPlaceHolder.localize()
        self.navigationItem.title = Constants.string.enterYourMailIdForrecovery.localize()
    }
    
    
    //MARK:- Next View Tap Action
    
    @IBAction private func nextAction(){
        
        self.viewNext.addPressAnimation()
        
        guard  let emailText = self.textFieldEmail.text, !emailText.isEmpty else {
            self.view.make(toast: ErrorMessage.list.enterEmail) {
                self.textFieldEmail.becomeFirstResponder()
            }
            return
        }
        
        guard Common.isValid(email: emailText) else {
            self.view.make(toast: ErrorMessage.list.enterValidEmail) {
                self.textFieldEmail.becomeFirstResponder()
            }
            return
        }
        
        let userData = UserData()
        userData.email = emailText
        self.loader.isHidden = false
        self.presenter?.post(api: .forgotPassword, data: userData.toData())
    
    }
}

extension ForgotPasswordViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textFieldEmail.placeholder = Constants.string.email.localize()
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.count == 0 {
            textFieldEmail.placeholder = Constants.string.emailPlaceHolder.localize()
        }
    }
    
}

//MARK:- PostViewProtocol

extension ForgotPasswordViewController : PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        DispatchQueue.main.async {
            self.view.make(toast: message)
            self.loader.isHidden = true
        }
    }
    
    func getUserData(api: Base, data: UserDataResponse?) {
        
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.ChangeResetPasswordController) as? ChangeResetPasswordController {
            let obj = UserDataResponse()
            obj.email = textFieldEmail.text
            vc.set(user: obj)
            vc.isChangePassword = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
            
        
        self.loader.isHideInMainThread(true)
    }
    
}

//// MARK:- UIScrollViewDelegate
//
//extension ForgotPasswordViewController : UIScrollViewDelegate {
//
////    func scrollViewDidScroll(_ scrollView: UIScrollView) {
////        if #available(iOS 11.0, *) {
////            let offset = scrollView.contentOffset
////            self.scrollView.contentOffset = offset
////        }
////    }
//}
