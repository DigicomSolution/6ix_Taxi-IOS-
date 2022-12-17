//
//  PasswordViewController.swift
//  User
//
//  Created by CSS on 28/04/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class PasswordViewController: UIViewController {
    
    @IBOutlet private var viewNext : UIView!
    @IBOutlet private var textFieldPassword : HoshiTextField!
    @IBOutlet private var buttonForgotPassword : UIButton!
    @IBOutlet private var buttonCreateAccount : UIButton!
    @IBOutlet private var scrollView : UIScrollView!
    @IBOutlet private var viewScroll : UIView!
    
    private lazy var loader : UIView = {
        return createActivityIndicator(self.view)
    }()

    private var email : String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.initialLoads()
        self.setDesign()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.setFrame()
    }
}


//MARK:- Methods

extension PasswordViewController {
    
    // MARK:- Set Designs
    
    private func setDesign() {
        
        Common.setFont(to: textFieldPassword!)
        Common.setFont(to: buttonCreateAccount!)
        Common.setFont(to: buttonForgotPassword!)
    }

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
            self.navigationItem.largeTitleDisplayMode = .never
        } 
        
//        if #available(iOS 13.0, *) {
//            self.navigationController?.navigationBar.barTintColor = UIColor.systemBackground
//            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
//            self.navigationController?.navigationBar.tintColor = UIColor.label
//        }else{
//            self.navigationController?.navigationBar.tintColor = UIColor.black
//        }
        
        self.scrollView.addSubview(viewScroll)
        self.setFrame()
        self.buttonCreateAccount.addTarget(self, action: #selector(self.createAccountAction), for: .touchUpInside)
        self.buttonForgotPassword.addTarget(self, action: #selector(self.forgotPasswordAction), for: .touchUpInside)
//      self.textFieldPassword.setPasswordView()
    }
    
    private func setFrame() {
        self.viewNext.makeRoundedCorner()
        self.viewScroll.frame = self.scrollView.bounds
        self.scrollView.contentSize = self.viewScroll.bounds.size
    }
    
    private func setDesigns() {
        
        if #available(iOS 13.0, *) {
            self.textFieldPassword.borderActiveColor = .label
        } else {
            self.textFieldPassword.borderActiveColor = .primary
        }
        self.textFieldPassword.borderInactiveColor = .lightGray
        self.textFieldPassword.placeholderColor = .gray
        self.textFieldPassword.delegate = self
        Common.setFont(to: textFieldPassword)
        
    }
    
    private func localize() {
        
        self.textFieldPassword.placeholder = Constants.string.enterPassword.localize()
        self.buttonCreateAccount.setAttributedTitle(NSAttributedString(string: Constants.string.iNeedTocreateAnAccount.localize(), attributes: [.font : UIFont.systemFont(ofSize: 14)]), for: .normal)
        self.buttonForgotPassword.setAttributedTitle(NSAttributedString(string: Constants.string.iForgotPassword.localize(), attributes: [.font : UIFont.systemFont(ofSize: 14)]), for: .normal)
        self.navigationItem.title = Constants.string.welcomeBackPassword.localize()
        Common.setFont(to: buttonCreateAccount!)
        Common.setFont(to: buttonForgotPassword!)
    }
    
    
    //MARK:- Set Values
    
    func set(email : String?) {
        
        self.email = email
        
    }
    
    
    //MARK:- Next View Tap Action
    
    @IBAction private func nextAction() {
        
        self.viewNext.addPressAnimation()
        
        if email == nil { //Go back if Email is nil
            
            self.popOrDismiss(animation: true)
        }
        
        guard  let passwordText = self.textFieldPassword.text, !passwordText.isEmpty else {
            
            self.view.make(toast: ErrorMessage.list.enterPassword) {
                self.textFieldPassword.becomeFirstResponder()
            }
            
            return
        }
        
        self.loader.isHidden = false
        self.presenter?.post(api: .login, data: MakeJson.login(withUser: email, password: passwordText))
        
        
        
    }
    
    //MARK:- Create Account

    @IBAction private func createAccountAction() {
        self.push(id: Storyboard.Ids.SignUpMobileNumberViewController, animation: true)
    }
    
    //MARK:- Forgot Password

    
    @IBAction private func forgotPasswordAction() {
        
        if let forgotVC = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.ForgotPasswordViewController) as? ForgotPasswordViewController {
            forgotVC.emailString = email
            self.navigationController?.pushViewController(forgotVC, animated: true)
        }
        
    }

}


//MARK:- UITextFieldDelegate

extension PasswordViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textFieldPassword.placeholder = Constants.string.password.localize()
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.count == 0 {
            textFieldPassword.placeholder = Constants.string.enterPassword.localize()
        }
    }
    
    
}


//MARK:- PostViewProtocol

extension PasswordViewController : PostViewProtocol {
   
    func onError(api: Base, message: String, statusCode code: Int) {
        
       let alert = showAlert(message: message)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: {
                self.loader.isHidden = true
            })
        }
        
    }
    
    func getOath(api: Base, data: LoginRequest?) {
      //  print("accessToke >>>>",data?.access_token")
        
        
        guard let accessToken = data?.access_token, let refreshToken = data?.refresh_token else {
            self.onError(api: api, message: ErrorMessage.list.serverError.localize(), statusCode: 0)
            return
        }
           
            User.main.accessToken = accessToken
            User.main.refreshToken = refreshToken
            self.presenter?.get(api: .getProfile, parameters: nil)
    }
    
    
    func getProfile(api: Base, data: Profile?) {
        print("accessToke >>>>",data?.access_token as Any)
        
        guard data != nil  else { return  }
        Common.storeUserData(from: data)
        storeInUserDefaults()
        let drawer = Common.setDrawerController() //Router.main.instantiateViewController(withIdentifier: Storyboard.Ids.DrawerController)
        self.present(drawer, animated: true, completion: {
            self.navigationController?.viewControllers.removeAll()
        })
    }
    
    
}
