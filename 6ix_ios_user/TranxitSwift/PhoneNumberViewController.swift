//
//  PhoneNumberViewController.swift
//  TranxitUser
//
//  Created by Umair Khan on 13/03/2020.
//  Copyright © 2020 Appoets. All rights reserved.
//

import UIKit
import FlagPhoneNumber

protocol PhoneNumberDelegate {
    func phoneNumberDidGet(phoneNumber: Int, userData: UserData, apiType: Base,dialCode:String,mobile:Int,fullNumber:String)
}

class PhoneNumberViewController: UIViewController, FPNTextFieldDelegate {
    
    
    var isVerify = false
    
    @IBOutlet weak var verificationView:UIView!
    @IBOutlet weak var phoneNumberView:UIView!

    @IBOutlet private var viewNext: UIView!
    @IBOutlet weak var otpContainerView: UIView!

    @IBOutlet weak var mobileNoVerfiyLabel:UILabel!

    @IBOutlet weak var resendBtn:UIButton!
    @IBOutlet weak var countDownLabel:UILabel!

    let otpStackView = OTPStackView()
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            numberTextField.delegate = self
            numberTextField.flagButtonSize = CGSize(width: 35, height: 35)
//            numberTextField.setFlag(countryCode: userCurrentLocation?.countryCode ?? .PK)
            
            numberTextField.setFlag(countryCode: .CA)
            

        }
    
    
    func enableVerficationView(){
            self.resendBtn.isEnabled = false

            self.resendBtn.titleLabel?.textColor = UIColor.lightGray
        //    testButton.isHidden = true
            otpContainerView.addSubview(otpStackView)
            otpStackView.delegate = self
            otpStackView.heightAnchor.constraint(equalTo: otpContainerView.heightAnchor).isActive = true
            otpStackView.centerXAnchor.constraint(equalTo: otpContainerView.centerXAnchor).isActive = true
            otpStackView.centerYAnchor.constraint(equalTo: otpContainerView.centerYAnchor).isActive = true

             self.viewNext.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.nextAction)))


            self.startTimer()
    }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            if timer != nil {
                timer?.invalidate()
            }
        }
        var count = 30
        var timer : Timer?
        @objc func update() {
            if(count > 0) {
                count -= 1
                self.countDownLabel.text = "Countdown \(count)"
            }else{
                timer?.invalidate()
                self.countDownLabel.text = "Countdown"
                self.resendBtn.isEnabled = true
                self.resendBtn.titleLabel?.textColor = UIColor.black
            }
        }

        func startTimer(){

            if timer != nil{
                timer?.invalidate()
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
            }
            else if timer == nil {
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
            }

        }

        override func viewWillLayoutSubviews() {
            super.viewWillLayoutSubviews()
            self.viewNext.makeRoundedCorner()
        }


        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            self.mobileNoVerfiyLabel.text = "Please type the verification code sent to \(phoneNumber)"
        }

        @IBAction private func resendAction(){
            self.presenter?.post(api: .sendCodeNo, data: MakeJson.sendMobileNo(withMobile: phoneNumber))
        }


        @IBAction private func nextAction(){

            self.viewNext.addPressAnimation()

            self.presenter?.post(api: .verifyCodeNo, data: MakeJson.verifyMobileNo(withMobile: getPhoneNumber(), code: otpStackView.getOTP()))

        }
    

    func getPhoneNumber() -> String{
        return phoneNumber
    }
    
     private lazy var loader : UIView = {
          return createActivityIndicator(self.view)
      }()
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
    }
    func fpnDisplayCountryList() {
    }
    
    var userData: UserData?
    var apiType: Base?
    @IBOutlet weak var numberTextField: FPNTextField!
    var phoneNumber = ""
    var phoneNumberDelegate: PhoneNumberDelegate?
    
    
    
    var mobile = ""
    var dial_code = ""

    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        if isValid{
            phoneNumber = numberTextField.getFormattedPhoneNumber(format: .E164)!
            
           // textField.selectedCountry?.phoneCode
            print("vnum", phoneNumber)
            
            self.mobile = (numberTextField.getRawPhoneNumber())!
            self.dial_code = (textField.selectedCountry?.phoneCode)!
         
        }else{
            phoneNumber = ""
            print("invnum", phoneNumber)
            
        }
    }
    

    @IBAction func doneClicked(_ sender: UIButton) {
        if phoneNumber != ""{
         //   if let userData = userData, let apiType = apiType{
                print("No",phoneNumber)
            
            
                
                self.presenter?.post(api: .sendCodeNo, data: MakeJson.sendMobileNo(withMobile: phoneNumber))
        }else{
            DispatchQueue.main.async {
                showAlert(message: "Please enter valid phone number", okHandler: nil, fromView: self)
            }
        }
    }
    
    private func showToast(string : String?) {
        
         self.view.makeToast(string, point: CGPoint(x: UIScreen.main.bounds.width/2 , y: UIScreen.main.bounds.height/2), title: nil, image: nil, completion: nil)
        
    }
}

extension PhoneNumberViewController: OTPDelegate {

    func didChangeValidity(isValid: Bool) {
       // testButton.isHidden = !isValid
    }

}

//MARK:- PostViewProtocol

extension PhoneNumberViewController : PostViewProtocol {
   
    func onError(api: Base, message: String, statusCode code: Int) {
        
       let alert = showAlert(message: message)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: {
                self.loader.isHidden = true
            })
        }
        
    }
    
    func getMobileNoVerficationCode(api: Base, data: SendCodeMobileNo?) {

        if !isVerify{
        //this case mobile view is showing
        if data != nil {
            if let message = data?.message{
                self.showToast(string: message)
                print("Message",message)
            }
            if let isVertified = data?.isVerified,let status = data?.status{
                if status {
                    if !isVertified{

                        self.mobileNoVerfiyLabel.text = "Please type the verification code sent to \(phoneNumber)"
                        self.isVerify = true
                        self.phoneNumberView.isHidden=true
                        self.enableVerficationView()
                        self.verificationView.isHidden = false
                    }
                }
            }
        }
        
        }
        else{


            if data != nil {
                if let message = data?.message{
                    print("Message",message)
                }
                if let isVerfiy = data?.isVerified{

                    if !isVerfiy{
                        //
                        self.startTimer()
                        self.resendBtn.isEnabled = false
                        self.resendBtn.titleLabel?.textColor = UIColor.lightGray
                    }



                }
                else if let status = data?.status, let message = data?.message{
                    if status {
                        

                        if let userData = userData, let apiType = apiType{
                            print("No",phoneNumber)
                            let number = Int(phoneNumber)!
                            phoneNumberDelegate?.phoneNumberDidGet(phoneNumber: number, userData: userData, apiType: apiType,dialCode:self.dial_code,mobile:Int(self.mobile)!, fullNumber: phoneNumber)
                            self.dismiss(animated: true, completion: nil)
                            
                        }
                    }else{

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
    }
}


