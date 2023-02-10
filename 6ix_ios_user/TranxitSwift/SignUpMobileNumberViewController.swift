//
//  SignUpMobileNumberViewController.swift
//  TranxitUser
//
//  Created by Yousaf Shafiq on 25/03/2020.
//  Copyright © 2020 Appoets. All rights reserved.
//

import UIKit
import FlagPhoneNumber

class SignUpMobileNumberViewController: UIViewController,FPNTextFieldDelegate{
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        
    }
    
    func fpnDisplayCountryList() {
        
    }
    
    
    
    
        @IBOutlet weak var textFieldMobileNumber: FPNTextField!
        var phoneNumber = ""
  
        
        
        func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
            if isValid{
                phoneNumber = textFieldMobileNumber.getFormattedPhoneNumber(format: .E164)!
                
               // textField.selectedCountry?.phoneCode
                print("vnum", phoneNumber)
//
//                self.mobile = (textFieldMobileNumber.getRawPhoneNumber())!
//                self.dial_code = (textField.selectedCountry?.phoneCode)!
//
            }else{
                phoneNumber = ""
                print("invnum", phoneNumber)
                
            }
        }
        

//        @IBAction func doneClicked(_ sender: UIButton) {
//            if phoneNumber != ""{
//             //   if let userData = userData, let apiType = apiType{
//                    print("No",phoneNumber)
//
//
//
//                    self.presenter?.post(api: .sendCodeNo, data: MakeJson.sendMobileNo(withMobile: phoneNumber))
//    //                let number = Int(phoneNumber)!
//    //                phoneNumberDelegate?.phoneNumberDidGet(phoneNumber: number, userData: userData, apiType: apiType)
//    //                self.dismiss(animated: true, completion: nil)
//
//               // }
//            }else{
//                DispatchQueue.main.async {
//                    showAlert(message: "Please enter valid phone number", okHandler: nil, fromView: self)
//                }
//            }
//        }

    

    
    private lazy var loader : UIView = {
         return createActivityIndicator(self.view)
     }()
    
    
    @IBOutlet private var viewNext: UIView!
  //  @IBOutlet private var textFieldMobileNumber : HoshiTextField!
   // @IBOutlet private var buttonCreateAcount : UIButton!
    @IBOutlet private var scrollView : UIScrollView!
    @IBOutlet private var viewScroll : UIView!
    
    var isHideLeftBarButton = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewControllerName = String.init(describing: self.classForCoder)
        print("VCName***: \(viewControllerName)")
        
        textFieldMobileNumber.delegate = self
//        textFieldMobileNumber.setFlag(countryCode: userCurrentLocation?.countryCode ?? .PK)
        textFieldMobileNumber.setFlag(countryCode: .CA)
        self.initialLoads()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.viewNext.makeRoundedCorner()
        self.viewScroll.frame = self.scrollView.bounds
        self.scrollView.contentSize = self.viewScroll.bounds.size
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
       // self.textFieldMobileNumber.becomeFirstResponder()
    }

}

//MARK:- Methods

extension SignUpMobileNumberViewController {

    
    private func initialLoads(){
       
//        if #available(iOS 11.0, *) {
//            self.navigationController?.navigationBar.prefersLargeTitles = true
//        }
        
        
        self.navigationController?.navigationBar.isHidden = false
        self.setDesigns()
        self.localize()
        self.view.dismissKeyBoardonTap()
        self.viewNext.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.nextAction)))
        if !isHideLeftBarButton {
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
            
        }
        self.scrollView.addSubview(viewScroll)
        self.scrollView.contentOffset = .zero
    }
    
    
    private func setDesigns(){
//
//        self.textFieldMobileNumber.borderActiveColor = .primary
//        self.textFieldMobileNumber.borderInactiveColor = .lightGray
//        self.textFieldMobileNumber.placeholderColor = .gray
        self.textFieldMobileNumber.delegate = self
        Common.setFont(to: textFieldMobileNumber!)
        //Common.setFont(to: buttonCreateAcount)
        
    }
    
    
    private func localize() {
        
        self.textFieldMobileNumber.placeholder = Constants.string.mobilePlaceHolder.localize()
        let attr :[NSAttributedString.Key : Any]  = [.font : UIFont.systemFont(ofSize: 14)]
        //self.buttonCreateAcount.setAttributedTitle(NSAttributedString(string: Constants.string.iNeedTocreateAnAccount.localize(), attributes: attr), for: .normal)
        self.navigationItem.title = Constants.string.whatsYourMobileNumber.localize()
        
    }
    
    
    //MARK:- Next View Tap Action
    
    @IBAction private func nextAction(){
        
       self.viewNext.addPressAnimation()
       
       guard  let numberText = self.textFieldMobileNumber.text, !numberText.isEmpty else {
            
            self.view.make(toast: ErrorMessage.list.enterMobileNumber) {
                self.textFieldMobileNumber.becomeFirstResponder()
            }
            
            return
        }
        
        
        
        
        
        
                if phoneNumber != ""{
       
                        self.presenter?.post(api: .sendCodeNo, data: MakeJson.sendMobileNo(withMobile: phoneNumber))
 
                }else{
                    DispatchQueue.main.async {
                        showAlert(message: "Please enter valid phone number", okHandler: nil, fromView: self)
                    }
                }
            
        
        
        
        
        
        
       

        
//        if let passwordVC = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.PasswordViewController) as? PasswordViewController {
//
//            passwordVC.set(email: numberText)
//            self.navigationController?.pushViewController(passwordVC, animated: true)
//
//        }
        
        
        
    }
  
}

extension SignUpMobileNumberViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textFieldMobileNumber.placeholder = Constants.string.MobileNumber.localize()
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.count == 0 {
            textFieldMobileNumber.placeholder = Constants.string.MobileNumber.localize()
        }
    }
    
}





//MARK:- PostViewProtocol

extension SignUpMobileNumberViewController : PostViewProtocol {
   
    func onError(api: Base, message: String, statusCode code: Int) {
        
       let alert = showAlert(message: message)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: {
                self.loader.isHidden = true
            })
        }
        
    }
    

    
    func getMobileNoVerficationCode(api: Base, data: SendCodeMobileNo?) {

        
        if data != nil {
           
            if let isVertified = data?.isVerified,let status = data?.status{
                if status {
                    if !isVertified{
                        
                        guard  let numberText = self.textFieldMobileNumber.text else{
                            return
                        }
                        
                        if let verifyVC = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.VerifyMobileNumberViewController) as? VerifyMobileNumberViewController {
                            verifyVC.set(phoneNumber: phoneNumber)
                            self.navigationController?.pushViewController(verifyVC, animated: true)
                        }


                       // self.push(id: Storyboard.Ids.VerifyMobileNumberViewController, animation: true)
                    }else{
                        if let message = data?.message{
                            let alert = showAlert(message: message)
                            
                            DispatchQueue.main.async {
                                self.present(alert, animated: true, completion: {
                                    self.loader.isHidden = true
                                })
                            }
                        }
                    }
                }
            }
//            if let status = data?.status{
//
//            }
        }
        
        


    }

    
//    func getProfile(api: Base, data: Profile?) {
//        print("accessToke >>>>",data?.access_token as Any)
//
//        guard data != nil  else { return  }
//        Common.storeUserData(from: data)
//        storeInUserDefaults()
//        let drawer = Common.setDrawerController() //Router.main.instantiateViewController(withIdentifier: Storyboard.Ids.DrawerController)
//        self.present(drawer, animated: true, completion: {
//            self.navigationController?.viewControllers.removeAll()
//        })
//    }
    
    
}






