//
//  VerificationController.swift
//  User
//
//  Created by CSS on 20/02/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class OTPScreenView: UIView {
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var EnterOTP: UILabel!
    
    @IBOutlet private var textField1 : UITextView!
    @IBOutlet private var textField2 : UITextView!
    @IBOutlet private var textField3 : UITextView!
    @IBOutlet private var textField4 : UITextView!
    @IBOutlet private var textField5 : UITextView!
    @IBOutlet private var textField6 : UITextView!
    
    @IBOutlet var buttonDone: UIButton!
    
     var onClickOtp:(()->Void)?
    private var countryCode : String = .Empty
    var userEnterdOtp : String = .Empty
    private var number : String = .Empty // Verification Id For Firebase Auth
    // var isSign = true // Flag to find whether the view controller is used for Sign In or Sign Up
     var completion : ((Bool)->())?  // Send Verfication result
    
    
    private lazy var textFieldsArray = [self.textField1,self.textField2,self.textField3,self.textField4]
    
//    private lazy var loader : UIView = {
//        return createActivityIndicator(self.view)
//    }()
    var otp  = [String]()
    var otp1 =  UserDefaults.standard.integer(forKey: "corporate_pin")
    
  
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialLoads()
        print("otp1>>>",otp1)
    }
    
    
    //MARK:- Initial Loads
    private func initialLoads(){
        
        EnterOTP.text = Constants.string.enterOtp
        self.dismissKeyBoardonTap()
        self.otp.removeAll()
        textField1.becomeFirstResponder()
        textFieldsArray.forEach { (textField) in
            textField?.delegate = self
            textField?.addShadow(color: .lightGray, opacity: 1, offset: CGSize(width: 0.1, height: 0.1), radius: 10, rasterize: false, maskToBounds: true)
            
        }
        //self.view.dismissKeyBoardonTap()
    }
    
    //MARK:- Set Country Code and number
    
    func set(number : String, with completion : @escaping (Bool)->()) {
        
        print("otp In OTPScreen>>> \(number)")
        self.number = number
        self.completion = completion
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        
    }
    
    @IBAction private func resendButtonAction(sender : UIButton) {
        

            
        
        
        
    }
//    
    func toast(message: String){
//        UIScreen.main.OTPScreenView?.make(toast: ErrorMessage.list.wrongOTP as String,smallFont: true
//            ,isPhoneX:true,color:UIColor.red)
       
//        toast(message: ((Constants.string.wrongOTP as NSString) as String))
//        to
        toastSuccess(UIApplication.shared.keyWindow! , message: Constants.string.wrongOTP as NSString, smallFont: true, isPhoneX: true, color: UIColor.red)
       // vibrate(with: weak)
    }
    
    
    @IBAction private func confirmButtonClick(sender : UIButton){
     
        
        
        
//        self.dismiss(animated: true) {
//            self.completion?(true)
//        }
         otp.removeAll()
    
         guard let otp1 = textField1.text, !otp1.isEmpty else {
            toast(message: ErrorMessage.list.enterOTP)
            
         return
         }
         
         guard let otp2 = textField2.text, !otp2.isEmpty else {
            toast(message: ErrorMessage.list.enterOTP)
            
         return
         }
         guard let otp3 = textField3.text, !otp3.isEmpty else {
         toast(message: ErrorMessage.list.enterOTP)
           
         return
         }
         
         guard let otp4 = textField4.text, !otp4.isEmpty else {
         toast(message: ErrorMessage.list.enterOTP)
           
         return
         }
        
        otp.append(textField1.text)
        otp.append(textField2.text)
        otp.append(textField3.text)
        otp.append(textField4.text)
        
        print(otp.joined())
        

        var otpPin =  UserDefaults.standard.integer(forKey: "corporate_pin")
        print("otpPin>>",otpPin)
        self.userEnterdOtp = otp.joined()
        
        if otpPin == Int(self.userEnterdOtp) as! Int{
             self.onClickOtp!()
        }else{
            
            textField4.becomeFirstResponder()

//            self.present(alert, animated: true, completion: nil)
            toast(message:ErrorMessage.list.wrongOTP)
//            let alert = UIAlertController(title: "", message: "YOUR MESSAGE", preferredStyle: .alert)
//            OTPScreenView(alert,animated:true)
//            {
//                sleep(5)
//                alert.dismiss(animated: true)
//            }
        }
    
//        self.number = "1234"
//        let checkOtp = self.userEnterdOtp
        
        
//        guard self.number == checkOtp else {
//
//        }
        
//        self.completion?(true)
       

    }
    
    
    private func makeResponsive(textView : UITextView){
        
        textFieldsArray.forEach { (field) in
            
            field?.layer.masksToBounds = !(textView == field)
        }
    }
}


extension OTPScreenView : UITextViewDelegate {
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        self.makeResponsive(textView: textView)
        
        if textView.text.count>1, var text = textView.text {
            text.removeFirst()
            textView.text = text
        }
        
        
    }
    
    //For Detecting Backspace based Deletion of Entire Word in TextField
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string.cString(using: String.Encoding.utf8) != nil {
            return true
        } else if string.isEmpty {
            return true
        } else {
            return false
        }
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        print("end editimg>>>>")
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEditing>>>>>")
    }
    func textViewDidChangeSelection(_ textView: UITextView) {
//        if textField4.text.count == 1{
//
//            print("empty")
//        }
        
        print("textViewDidChangeSelection>>>>>>")
        if textField4.text.count == 0 && textView.tag == 4{
            textField3.becomeFirstResponder()
        }
        if textField3.text.count == 0 && textView.tag == 3{
            textField2.becomeFirstResponder()
        }
        if textField2.text.count == 0 && textView.tag == 2{
            textField1.becomeFirstResponder()
        }
        
    }
    
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        if (range.length == 1 && string.isEmpty){
//            print("Used Backspace")
//        }
//        return true
//    }
    
    
    
    func textViewDidChange(_ textView: UITextView) {

        if Int.val(val: textView.text?.count)>1, var text = textView.text {
            text.removeFirst()
            textView.text = text
        }
        
//        if textView.text.count>=1{
//            tex
//        }

        if textView.text.count>=1 {

            switch textView {

            case textField1 :

                textField2.becomeFirstResponder()

            case textField2 :

                textField3.becomeFirstResponder()
            case textField3 :
                textField4.becomeFirstResponder()
            default :
                textView.resignFirstResponder()
                if textField4.text.count <= 4{
                    textField4.becomeFirstResponder()
                }
            }
            
            
            
//            if textField4.text == "" {
//                textField3.becomeFirstResponder()
//            }

        }
        
        
//        self.otp.append(textField4.text)
//
//         }

//                defer {
//                    if Int.val(val: textField.text?.count)>1, var text = textField.text {
//                        text.removeFirst()
//                       textField.text = text
//                    }
//                }

    
    }

    private func textFieldDidEndEditing(_ textField: UITextField) {

           // print("did end ",textField.text)

            if Int.val(val: textField.text?.count)>1, var text = textField.text {
                text.removeFirst()
                textField.text = text
            }

        }


}





