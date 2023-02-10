//
//  VerifyMobileNumberViewController.swift
//  TranxitUser
//
//  Created by Yousaf Shafiq on 26/03/2020.
//  Copyright © 2020 Appoets. All rights reserved.
//

import UIKit

class VerifyMobileNumberViewController: UIViewController {
    
    
    
    private lazy var loader : UIView = {
         return createActivityIndicator(self.view)
     }()


    
    @IBOutlet private var viewNext: UIView!
    @IBOutlet weak var otpContainerView: UIView!
    
    @IBOutlet weak var mobileNoVerfiyLabel:UILabel!
    
    @IBOutlet weak var resendBtn:UIButton!
    @IBOutlet weak var countDownLabel:UILabel!
    
    let otpStackView = OTPStackView()
    
    var phoneNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewControllerName = String.init(describing: self.classForCoder)
        print("VCName***: \(viewControllerName)")
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

//    @IBAction func clickedForHighlight(_ sender: UIButton) {
//        print("Final OTP : ",otpStackView.getOTP())
//        otpStackView.setAllFieldColor(isWarningColor: true, color: .yellow)
//
//
//}
  
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.viewNext.makeRoundedCorner()
    }
    
    
    func set(phoneNumber : String?) {
        
        self.phoneNumber = phoneNumber ?? ""
        
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
        
//        guard  let numberText = self.textFieldMobileNumber.text, !numberText.isEmpty else {
//
//            self.view.make(toast: ErrorMessage.list.enterMobileNumber) {
//                self.textFieldMobileNumber.becomeFirstResponder()
//            }
//
//            return
//        }
//
//
//        guard Common.isValidPhone(phone:numberText)else {
//            self.view.make(toast: ErrorMessage.list.enterValidMobileNumber) {
//                self.textFieldMobileNumber.becomeFirstResponder()
//            }
//
//            return
//
//        }
        
        self.presenter?.post(api: .verifyCodeNo, data: MakeJson.verifyMobileNo(withMobile: phoneNumber, code: otpStackView.getOTP()))
          
    }
    
}

extension VerifyMobileNumberViewController: OTPDelegate {
    
    func didChangeValidity(isValid: Bool) {
       // testButton.isHidden = !isValid
    }
    
}



//MARK:- PostViewProtocol

extension VerifyMobileNumberViewController : PostViewProtocol {
   
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
                    //it means true
                    if let verifyVC = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.SignUpTableViewController) as? SignUpUserTableViewController {
                        verifyVC.set(phoneNumber: self.phoneNumber)
                        self.navigationController?.pushViewController(verifyVC, animated: true)
                    }
                }else{
                    
                    let alert = showAlert(message: message)
                     
                     DispatchQueue.main.async {
                         self.present(alert, animated: true, completion: {
                             self.loader.isHidden = true
                         })
                     }

                    
                    //show the error here
                }
            }
        }
        
        
        
        print(data?.message)
        
        
        print("see the result")
        print(data?.JSONRepresentation)



    }

    
    
    
    
}
