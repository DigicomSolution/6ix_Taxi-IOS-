//
//  CoporateUserViewController.swift
//  TranxitUser
//
//  Created by Basha's MacBook Pro on 23/04/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import UIKit
import AccountKit
import DropDown

class CoporateUserViewController: UITableViewController {
    
    @IBOutlet var firstNameText: HoshiTextField!
    @IBOutlet var emailtext: HoshiTextField!
    @IBOutlet var lastNameText: HoshiTextField!
    
    @IBOutlet var passwordText: HoshiTextField!
    
//    @IBOutlet var confirmPwdText: HoshiTextField!
    @IBOutlet var companyIdText: HoshiTextField!
    @IBOutlet var employeeIdText: HoshiTextField!
    @IBOutlet var companyNameText: HoshiTextField!

    //@IBOutlet var countryText: HoshiTextField!
    
    // @IBOutlet var timeZone: HoshiTextField!
    
    // @IBOutlet var referralCodeText: HoshiTextField!
    
    // @IBOutlet var businessLabel: UILabel!
    // @IBOutlet var outStationLabel: UILabel!
    // @IBOutlet var personalLabel: UILabel!
    // @IBOutlet var businessimage: UIImageView!
    
    @IBOutlet var phoneNumber: HoshiTextField!
    // @IBOutlet var personalimage: UIImageView!
    
    @IBOutlet var nextView: UIView!
    
    @IBOutlet var nextImage: UIImageView!
    
    // @IBOutlet var BusinessView: UIView!
    // @IBOutlet var personalView: UIView!
    
    //MARK:- Variable
    
    let serviceTypeView = DropDown()
    var serviceTypeArr : [CompanyModalObj]?
    var selectedCompanyId = 0
    var selectedPhoneNumber = ""
    var userEnterdphonenumber : String = .Empty
    /*  private var tripType : TripType =  .Business {
     
     didSet {
     
     self.businessimage.image = tripType == .Business ? #imageLiteral(resourceName: "radio-on-button") : #imageLiteral(resourceName: "circle-shape-outline")
     self.personalimage.image = tripType == .Personal ? #imageLiteral(resourceName: "radio-on-button") : #imageLiteral(resourceName: "circle-shape-outline")
     
     }
     } */
    
    
    private var userInfo : UserData?
    private var accountKit : AKFAccountKit?
    private lazy var  loader = {
        return createActivityIndicator(UIApplication.shared.keyWindow ?? self.view)
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationcontroller()
        self.setDesign()
        print("selected phone number >>>>,",selectedPhoneNumber)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        
        
         let corpId = User.main.corp_deleted ?? 0
            
            if corpId == 1{
            
                self.setData()

            }else
            {
                
                self.textFieldHiddenOrView(value: true)
                self.passwordText.isHidden = false
                self.getCompanyList()
            }
        
        
        


        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.nextView.makeRoundedCorner()
        //self.changeNextButtonFrame()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.nextView.isHidden = false
        //self.changeNextButtonFrame()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //self.nextView.isHidden = true
        super.viewWillDisappear(animated)
    }
    
}


extension CoporateUserViewController {
    
    
    // MARK:- Designs
    
    private func setDesign() {
        
        Common.setFont(to: firstNameText)
        Common.setFont(to: emailtext)
        Common.setFont(to: lastNameText)
        Common.setFont(to: passwordText)
//        Common.setFont(to: confirmPwdText)
        Common.setFont(to: phoneNumber)
        
//        Common.setFont(to:companyIdText)
        Common.setFont(to:employeeIdText)
        Common.setFont(to: companyNameText)
        Common.setFont(to: phoneNumber)

        
    }
    
    private func getCompanyList(){
        self.loader.isHidden = false
        self.presenter?.get(api: .companyList, parameters: nil)
    }
    
    
    
    private func localize(){
        
        self.firstNameText.placeholder = Constants.string.first.localize()
        self.lastNameText.placeholder = Constants.string.last.localize()
        self.emailtext.placeholder = Constants.string.emailPlaceHolder.localize()
        self.passwordText.placeholder = Constants.string.password
//        self.confirmPwdText.placeholder = Constants.string.ConfirmPassword.localize()
//        self.companyIdText.placeholder = Constants.string.companyId.localize()
        self.employeeIdText.placeholder = Constants.string.employeeId.localize()

        self.phoneNumber.placeholder = Constants.string.phoneNumber.localize()
        self.passwordText.placeholder = Constants.string.password.localize()
        self.companyNameText.placeholder = Constants.string.companyName.localize()

        
        //        self.countryText.placeholder = Constants.string.country.localize()
        //        self.timeZone.placeholder = Constants.string.timeZone.localize()
        //        self.referralCodeText.placeholder = Constants.string.referalCode.localize()
        //        self.businessLabel.text = Constants.string.business.localize()
        //        self.personalLabel.text = Constants.string.personal.localize()
        
    }
    
    func setNavigationcontroller(){
        
       
        title = Constants.string.coporateDetails.localize()
        
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
//
        
        self.navigationController?.navigationItem.title = title
        // self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(self.backButtonClick))
//        if #available(iOS 13.0, *) {
//            self.navigationController?.navigationBar.barTintColor = UIColor.systemBackground
//            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
//            self.navigationController?.navigationBar.tintColor = UIColor.label
//        }else{
//            self.navigationController?.navigationBar.tintColor = UIColor.black
//        }
        addGustureforNextBtn()
        self.view.dismissKeyBoardonTap()
        self.firstNameText.delegate = self
        self.lastNameText.delegate = self
        self.emailtext.delegate = self
        self.passwordText.delegate = self
//        self.companyIdText.delegate = self
        self.employeeIdText.delegate = self
        self.companyNameText.delegate = self

        
//        self.confirmPwdText.delegate = self
        self.phoneNumber.delegate = self
        //self.navigationController?.view.addSubview(nextView)
    }
    
    
    private func setData(){
        
        self.textFieldHiddenOrView(value: false)

        self.firstNameText.text = User.main.firstName
        self.lastNameText.text = User.main.lastName
        self.emailtext.text = User.main.email
        self.companyNameText.text = User.main.company_name
//        self.companyIdText.text = User.main.company_id
        self.employeeIdText.text = User.main.emp_id
        self.phoneNumber.text = User.main.mobile

        self.passwordText.isHidden = true
//        self.phoneNumber.isHidden = true

        

    }
    
    private func textFieldHiddenOrView(value:Bool){
        
        self.firstNameText.isEnabled = value
        self.lastNameText.isEnabled = value
        self.emailtext.isEnabled = value
        self.passwordText.isEnabled = value
//        self.companyIdText.isEnabled = value
        self.employeeIdText.isEnabled = value
        self.companyNameText.isEnabled = value
        self.phoneNumber.isEnabled = value
        
        self.nextView.isHidden = !value
    }
    
    private func addGustureforNextBtn(){
        
        let nextBtnGusture = UITapGestureRecognizer(target: self, action: #selector(nextBtnTapped(sender:)))
        
        self.nextView.addGestureRecognizer(nextBtnGusture)
    }
    
    
    //    private func addGustureForRadioBtn(){
    //        let BusinessradioGusture = UITapGestureRecognizer(target: self, action: #selector(RatioButtonTapped(sender:)))
    //        self.personalView.addGestureRecognizer(BusinessradioGusture)
    //    }
    //
    //    @IBAction func RatioButtonTapped (sender: UITapGestureRecognizer){
    //
    //        guard let currentView = sender.view else {
    //            return
    //        }
    //
    //        self.tripType = currentView == BusinessView ? .Business : .Personal
    //
    //    }
    
    
    @IBAction func nextBtnTapped(sender : UITapGestureRecognizer){
        
        //sender.view?.addPressAnimation()
        self.view.endEditingForce()
        guard let email = self.validateEmail() else { return }
        
        guard let firstName = self.firstNameText.text, !firstName.isEmpty else {
            self.showToast(string: ErrorMessage.list.enterFirstName.localize())
            return
        }
        guard let lastName = lastNameText.text, !lastName.isEmpty else {
            self.showToast(string: ErrorMessage.list.enterLastName.localize())
            return
        }
        
        guard let phoneNumber = phoneNumber.text, !phoneNumber.isEmpty, let mobile = Int(phoneNumber)  else {
            self.showToast(string: ErrorMessage.list.enterMobileNumber.localize())
            return
        }
        guard let password = passwordText.text, !password.isEmpty, password.count>=6 else {
            self.showToast(string: ErrorMessage.list.enterPassword.localize())
            return
        }
//        guard let companyID = companyIdText.text, !companyID.isEmpty else {
//            self.showToast(string: ErrorMessage.list.enterCompanyId.localize())
//            return
//        }
        
        guard let companyName = companyNameText.text, !companyName.isEmpty else {
            self.showToast(string: ErrorMessage.list.enterCompanyName.localize())
            return
        }

        guard let employeeId = employeeIdText.text, !employeeId.isEmpty else {
            self.showToast(string: ErrorMessage.list.enterEmployeeId.localize())
            return
        }
        
//        guard phoneNumber == selectedPhoneNumber else {
//            self.showToast(string: ErrorMessage.list.companyNumberDoesnotMatch.localize())
//            return
//        }
//
        
        
//        guard let confirmPwd = confirmPwdText.text, !confirmPwd.isEmpty else {
//            self.showToast(string: ErrorMessage.list.enterConfirmPassword.localize())
//            return
//        }
//        guard confirmPwd == password else {
//            self.showToast(string: ErrorMessage.list.passwordDonotMatch.localize())
//            return
//        }
//        userInfo =  MakeJson.signUp(loginBy: .manual, email: email, password: password, socialId: nil, firstName: firstName, lastName: lastName, mobile: mobile)
//        userInfo = MakeJson.coporateLogin(loginBy: .manual, email: email, password: password, companyId: companyID, employeeID: employeeId, companyName: companyName, firstName: firstName, lastName: lastName, mobile: "\(mobile)")
        userInfo = MakeJson.coporateLogin(loginBy: .manual, email: email, password: password, companyId: "\(selectedCompanyId)", employeeID: employeeId, companyName: companyName, firstName: firstName, lastName: lastName, mobile: "\(mobile)")

        /* guard let country = countryText.text, country.isEmpty else {
         UIApplication.shared.keyWindow?.makeToast(ErrorMessage.list.enterCountry)
         return
         }
         guard let timeZone = timeZone.text, timeZone.isEmpty else {
         UIApplication.shared.keyWindow?.makeToast(ErrorMessage.list.enterTimezone)
         return
         }
         guard let referralCode = referralCodeText.text, referralCode.isEmpty else {
         UIApplication.shared.keyWindow?.makeToast(ErrorMessage.list.enterReferralCode)
         return
         } */
        
        
        self.loader.isHideInMainThread(false)
        self.presenter?.post(api: .corporateUser, data: userInfo?.toData() )
//         self.present(id: Storyboard.Ids.DrawerController, animation: true)
        
//        self.accountKit = AKFAccountKit(responseType: .accessToken)
//        let akPhone = AKFPhoneNumber(countryCode: "in", phoneNumber: phoneNumber)
//        let accountKitVC = accountKit?.viewControllerForPhoneLogin(with: akPhone, state: UUID().uuidString)
//        accountKitVC!.enableSendToFacebook = true
//        self.prepareLogin(viewcontroller: accountKitVC!)
//        self.present(accountKitVC!, animated: true, completion: nil)
        
        
    }
    
    private func validateEmail()->String? {
        guard let email = emailtext.text?.trimmingCharacters(in: .whitespaces), !email.isEmpty else {
            self.showToast(string: ErrorMessage.list.enterEmail.localize())
            emailtext.becomeFirstResponder()
            return nil
        }
        guard Common.isValid(email: email) else {
            self.showToast(string: ErrorMessage.list.enterValidEmail.localize())
            emailtext.becomeFirstResponder()
            return nil
        }
        return email
    }
    
    
    private func prepareLogin(viewcontroller : UIViewController&AKFViewController) {
        
        viewcontroller.delegate = self
        viewcontroller.uiManager = AKFSkinManager(skinType: .contemporary, primaryColor: .primary)
        viewcontroller.uiManager.theme?()?.buttonTextColor = .black
        
    }
    
    
    
    //MARK:- Show Custom Toast
    private func showToast(string : String?) {
        
        self.view.makeToast(string, point: CGPoint(x: UIScreen.main.bounds.width/2 , y: UIScreen.main.bounds.height/2), title: nil, image: nil, completion: nil)
        
    }
    
    
    private func changeNextButtonFrame() {
        
        let frameWidth : CGFloat = 50 * (UIScreen.main.bounds.width/375)
        self.nextView.makeRoundedCorner()
        self.nextView.frame = CGRect(x: UIScreen.main.bounds.width-(frameWidth+16), y: UIScreen.main.bounds.height-(frameWidth+16), width: frameWidth, height: frameWidth)
        self.nextImage.frame = CGRect(x: self.nextView.frame.width/4, y: self.nextView.frame.height/4, width: self.nextView.frame.width/2, height: self.nextView.frame.height/2)
//         self.nextImage.frame = CGRect(x: nextView.frame.midX, y: nextView.frame.midY, width: self.nextView.frame.width/2, height: self.nextView.frame.height/2)
        
        //nextView.addSubview(nextImage)

    }
    
    
    
}


extension CoporateUserViewController : PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        self.loader.isHideInMainThread(true)

//        if api == .userVerify {
//            self.emailtext.shake()
//            vibrate(with: .weak)
//            DispatchQueue.main.async {
//                self.emailtext.becomeFirstResponder()
//            }
//        }
        DispatchQueue.main.async {
            self.loader.isHidden = true
            self.showToast(string: message)
        }
        
    }
    
    func getProfile(api: Base, data: Profile?) {
        print("company name",data?.company_name)

        loader.isHideInMainThread(true)
        
        if api == .corporateUser {
          
            User.main.company_id = "\(selectedCompanyId)"
            User.main.company_name = self.companyNameText.text
            User.main.emp_id = self.employeeIdText.text
            
            storeInUserDefaults()
            
            showToast(string: data?.message)
            setData()
            self.popOrDismiss(animation: true)
            
            //        self.confirmPwdText.delegate = self
            
//            self.navigationController?.present(Common.setDrawerController(), animated: true, completion: nil)
            //self.presenter?.get(api: .getProfile, parameters: nil)
            //self.presenter?.post(api: .login, data: MakeJson.login(withUser: userInfo?.email,password:userInfo?.password))
            return
            
        }
        /*else if api == .getProfile {
         Common.storeUserData(from: data)
         storeInUserDefaults()
         self.navigationController?.present(id: Storyboard.Ids.DrawerController, animation: true)
         } else {
         loader.isHideInMainThread(true)
         } */
    }
    func getCompanyListApi(api: Base, data: [CompanyModalObj]) {
        print("getcompanyList >>>",data.first?.name as Any)
        loader.isHideInMainThread(true)

        serviceTypeArr = data
//        setData()

    }
    
    /* func getOath(api: Base, data: LoginRequest?) {
     
     loader.isHideInMainThread(true)
     if api == .login, let accessToken = data?.access_token {
     
     User.main.accessToken = accessToken
     storeInUserDefaults()
     self.presenter?.get(api: .getProfile, parameters: nil)
     //let drawer = Router.main.instantiateViewController(withIdentifier: Storyboard.Ids.DrawerController)
     //            let window = UIWindow(frame: UIScreen.main.bounds)
     //            UIApplication.shared.windows.last?.rootViewController?.popOrDismiss(animation: true)
     //            let navigationController = Router.main.instantiateViewController(withIdentifier: Storyboard.Ids.DrawerController)
     //            window.rootViewController = navigationController
     //            window.makeKeyAndVisible()
     
     }
     
     } */
    
}

//MARK:- AKFViewControllerDelegate

extension CoporateUserViewController : AKFViewControllerDelegate {
    
    func viewControllerDidCancel(_ viewController: (UIViewController & AKFViewController)!) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: (UIViewController & AKFViewController)!, didFailWithError error: Error!) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: (UIViewController & AKFViewController)!, didCompleteLoginWith accessToken: AKFAccessToken!, state: String!) {
        func dismiss() {
            viewController.dismiss(animated: true) { }
            self.loader.isHidden = false
            self.presenter?.post(api: .signUp, data: self.userInfo?.toData())
        }
        if accountKit != nil {
            accountKit!.requestAccount({ (account, error) in
                if let phoneNumber = account?.phoneNumber {
                    var mobileString = phoneNumber.stringRepresentation()
                    if mobileString.hasPrefix("+") {
                        mobileString.removeFirst()
                        if let mobileInt = Int(mobileString) {
                            self.userInfo?.mobile = mobileString
                        }
                    }
                }
                dismiss()
                return
                //print("--->>",account?.phoneNumber.)
                // print("--->>>",error)
            })
        }else {
            dismiss()
        }
        
    }
    
}

// MARK:- UITextFieldDelegate

extension CoporateUserViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //(textField as? HoshiTextField)?.borderActiveColor = .primary
        if textField == emailtext {
            textField.placeholder = Constants.string.email.localize() }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //(textField as? HoshiTextField)?.borderActiveColor = .lightGray
        if textField == emailtext {
            if textField.text?.count == 0 {
                textField.placeholder = Constants.string.emailPlaceHolder.localize()
            }
//            else if let email = validateEmail(){
//                textField.resignFirstResponder()
//                let user = User()
//                user.email = email
//                presenter?.post(api: .userVerify, data: user.toData())
//            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == companyNameText {
            serviceTypeView.anchorView = textField
            var dataSource:[String]=[]
            
            guard let serviceTypes = self.serviceTypeArr else {return false}
            for service in serviceTypes {
                dataSource.append(service.name ?? "")
            }
            serviceTypeView.dataSource = dataSource
            serviceTypeView.selectionAction = { [weak self] (index, item) in
                self?.companyNameText.text = item
                self?.selectedCompanyId = (self?.serviceTypeArr![index].id)!
                self?.selectedPhoneNumber = (self?.serviceTypeArr![index].mobile)!

            }
            DropDown.setupDefaultAppearance()
            serviceTypeView.cellNib = UINib(nibName: "DropDownCell", bundle: Bundle(for: DropDownCell.self))
            serviceTypeView.show()
            return false
        }

        return true
    }
    
    //    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    //
    //       // let count = range.length-range.location
    //
    //        if textField == passwordText {
    //            let isEditable = Int.removeNil(passwordText.text?.count)<passwordLengthMax
    //            passwordText.borderActiveColor = isEditable ? .primary : .red
    //            passwordText.borderInactiveColor = isEditable ? .lightGray : .red
    //          return isEditable
    //        }
    //        return true
    //    }
    
    //    private func textField(textField : HoshiTextField, count : Int) {
    //
    //        if textField == passwordText {
    //            let isEditable = Int.removeNil(passwordText.text?.count)<passwordLengthMax
    //            passwordText.borderActiveColor = isEditable ? .primary : .red
    //            passwordText.borderInactiveColor = isEditable ? .lightGray : .red
    //            return isEditable
    //        }
    //
    //    }
    
}


//extension CoporateUserViewController {
//
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//
//    }
//
//}


