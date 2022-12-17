//
//  SocailLoginViewController.swift
//  User
//
//  Created by CSS on 02/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

import FirebaseCore
import FacebookLogin
import FacebookCore
import AccountKit
import GoogleSignIn
import AuthenticationServices
import SwiftKeychainWrapper

class SocialLoginViewController: UITableViewController {
    
    let signInArray = [ Constants.string.facebook,Constants.string.google,Constants.string.appleSignIn ]
    
    
    let signInImageArray = [#imageLiteral(resourceName: "fb_icon"),#imageLiteral(resourceName: "google_icon"), #imageLiteral(resourceName: "apple_login_icon")]
    
    var userData : UserData?
    
    private let tableCellId = "SocialLoginCell"
    private var isfaceBook = false
    private var isApple = false
    
    private var accessToken : String?
    
    private lazy var loader : UIView = {
        return createActivityIndicator(UIApplication.shared.keyWindow ?? self.view)
    }()
    
    let configuration =   GIDConfiguration.init(clientID: (FirebaseApp.app()?.options.clientID)!)
//    var appleLogInButton : ASAuthorizationAppleIDButton = {
//        let button = ASAuthorizationAppleIDButton()
//        //button.addTarget(self, action: #selector(handleLogInWithAppleID), for: .touchUpInside)
//        return button
//    }()
    
    
    
    @available(iOS 13.0, *)
    func setupSOAppleSignIn() -> ASAuthorizationAppleIDButton{
        let btnAuthorization = ASAuthorizationAppleIDButton()
        btnAuthorization.frame = CGRect(x: (self.view.frame.width - 200)/2, y: 15, width: 200, height: 40)
        
        btnAuthorization.addTarget(self, action: #selector(actionHandleAppleSignin), for: .touchUpInside)

        return btnAuthorization
    }

    
    
    
    @objc func actionHandleAppleSignin(){
        self.appleLogin()
        User.main.loginType = LoginType.apple.rawValue
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialLoads()
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        if #available(iOS 13.0, *) {
//            performExistingAccountSetupFlows()
//        }
        
        if let email = KeychainWrapper.standard.string(forKey: "UserEmail"){
            print("email re",email)
        }
        if let email = KeychainWrapper.standard.string(forKey: "UserLastName"){
                   print("email re",email)
               }
        
        if let email = KeychainWrapper.standard.string(forKey: "UserFirstName"){
                   print("email re",email)
               }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.localize()
        self.navigationController?.isNavigationBarHidden = false
    }
    
}

// MARK:- Methods

extension SocialLoginViewController: PhoneNumberDelegate {
    
    
    private func initialLoads() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:  #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(self.backButtonClick))

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
        
        
        
        
    }
    
    
    private func localize() {
        
        self.navigationItem.title = Constants.string.chooseAnAccount.localize()
    }
    
    
    // MARK:- Socail Login
    
    private func didSelect(at indexPath : IndexPath) {
       
        accessToken = nil // reset access token
        switch (indexPath.section,indexPath.row) {
        case (0,0):
            self.facebookLogin()
            User.main.loginType = LoginType.facebook.rawValue
        case (0,1):
            self.googleLogin()
            User.main.loginType = LoginType.google.rawValue
        case (0,2):
            self.appleLogin()
            User.main.loginType = LoginType.apple.rawValue
            
        default:
            break
        }
        
    }
    
    
    // MARK:- Google Login
    
    private func googleLogin(){
        
        self.loader.isHidden = false
        self.isfaceBook = false
        self.isApple = false
  
        GIDSignIn.sharedInstance.signOut()
        GIDSignIn.sharedInstance.signIn(with: configuration, presenting: self) { user, error in
            if let error = error {
                self.loader.isHidden = true
                print("google error: \(error.localizedDescription)")
            } else {
                self.loader.isHidden = true
    
                guard user != nil else {
                    return
                }
                self.accessToken = user?.authentication.accessToken
                print(user?.profile, error ?? "No error Found")
                let loginBy : LoginType = self.isfaceBook ? .facebook : .google
                self.loadAPI(accessToken: self.accessToken/*, phoneNumber: */, loginBy: loginBy)

                //accountKit()
            }
        }
        
    }
    
    
    // MARK:- Facebook Login
    
    private func facebookLogin() {
        self.loader.isHidden = false
        self.isfaceBook = true
        self.isApple = false
        print("Facebook")
        let loginManager = LoginManager()
        loginManager.logIn(permissions: [.publicProfile, .email], viewController: self) { (loginResult) in
            switch loginResult {
            case .failed(let error):
                print(error)
                self.loader.isHidden = true
                break
            case .cancelled:
                print("Cancelled")
                self.loader.isHidden = true
                break
            case .success(_ , _, let accessToken):
                print(accessToken)
                self.accessToken = accessToken.tokenString
                let loginBy : LoginType = self.isfaceBook ? .facebook : .google
                self.loadAPI(accessToken: self.accessToken/*, phoneNumber: */, loginBy: loginBy)
                
                //self.accountKit()
                break
            }
        }
    }
    
    
    private func loadAPI(accessToken: String?/*,phoneNumber: Int?*/, loginBy: LoginType){
        //self.loader.isHidden = false
        let user = UserData()
        user.accessToken = accessToken
        user.device_id = UUID().uuidString
        user.device_token = deviceTokenString
        user.device_type = .ios
        user.login_by = loginBy
        //user.mobile = phoneNumber
        
        
        
        if self.isApple{
            if let email = KeychainWrapper.standard.string(forKey: "UserEmail"){
                user.email = email
            }
            
            if let firstName = KeychainWrapper.standard.string(forKey: "UserFirstName"){
                user.first_name = firstName
            }
            
            if let lastName = KeychainWrapper.standard.string(forKey: "UserLastName"){
                user.last_name = lastName
            }
            
            self.userData = user
            self.presenter?.post(api: .isAppleMobileVerify, data: user.toData())
            
        }else{
            self.userData = user
            self.presenter?.post(api: .isMobileVerfiy, data: user.toData())
        }
        
        

        
       
        
        
    }
    
    private func openPhoneNumberSelectionVC(data: UserData, apiType: Base){
        if let sb = UIStoryboard(name: "User", bundle: nil).instantiateViewController(withIdentifier: "PhoneNumberVC") as? PhoneNumberViewController{
            sb.userData = data
            sb.apiType = apiType
            sb.phoneNumberDelegate = self
            sb.modalPresentationStyle = .popover
            present(sb, animated: true, completion: nil)
            self.loader.isHidden = true
        }
    }
    
    func phoneNumberDidGet(phoneNumber: Int, userData: UserData, apiType: Base,dialCode:String,mobile:Int,fullNumber:String) {
        self.loader.isHidden = false
        
//        if apiType == .googleLogin{
//            userData.mobile = mobile
//            userData.dial_code = dialCode
//            userData.isMobileVerified = 1
//        }else{
//            userData.mobile = phoneNumber
//            userData.isMobileVerified = 1
//        }
        
//        userData.mobile = mobile
//        userData.dial_code = dialCode
        userData.mobile = fullNumber
        userData.isMobileVerified = 1
        
   
        //self.loader.isHidden = false
        self.presenter?.post(api: apiType, data: userData.toData())
    }
    
    
//    private func accountKit(){
//        let accountKit = AKFAccountKit(responseType: .accessToken)
//        let accountKitVC = accountKit.viewControllerForPhoneLogin()
//        accountKitVC.enableSendToFacebook = true
//        self.prepareLogin(viewcontroller: accountKitVC)
//        self.present(accountKitVC, animated: true, completion: nil)
//    }
    
//    private func prepareLogin(viewcontroller : UIViewController&AKFViewController) {
//
//        viewcontroller.delegate = self
//        viewcontroller.uiManager = AKFSkinManager(skinType: .contemporary, primaryColor: .primary)
//        viewcontroller.uiManager.theme?()?.buttonTextColor = UIColor.black
//    }
    
}

// MARK:- AKFViewControllerDelegate
//extension SocialLoginViewController : AKFViewControllerDelegate {
//
//    func viewControllerDidCancel(_ viewController: (UIViewController & AKFViewController)!) {
//        viewController.dismiss(animated: true, completion: nil)
//    }
//
//    func viewController(_ viewController: (UIViewController & AKFViewController)!, didFailWithError error: Error!) {
//        viewController.dismiss(animated: true, completion: nil)
//    }
//
//    func viewController(_ viewController: (UIViewController & AKFViewController)!, didCompleteLoginWith accessToken: AKFAccessToken!, state: String!) {
//        print(state)
//        viewController.dismiss(animated: true) {
//            //self.loader.isHidden = false
//            //self.presenter?.post(api: .signUp, data: self.userSignUpInfo?.toData())
//
//            AKFAccountKit(responseType: AKFResponseType.accessToken).requestAccount({ (account, error) in
//
//                // self.accessToken = accessToken as! String
//                guard let number = account?.phoneNumber?.phoneNumber, let code = account?.phoneNumber?.countryCode, let numberInt = Int(code+number) else {
//                    self.onError(api: .addPromocode, message: .Empty, statusCode: 0)
//                    return
//                }
//
//                let loginBy : LoginType = self.isfaceBook ? .facebook : .google
//                self.loadAPI(accessToken: self.accessToken, phoneNumber: numberInt, loginBy: loginBy)
//
//            })
//
//        }
//
//    }
//}

// MARK:- TableView

extension SocialLoginViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let tableCell = tableView.dequeueReusableCell(withIdentifier: self.tableCellId, for: indexPath) as? SocialLoginCell {
//
//            tableCell.labelTitle.text = (indexPath.row == 0 ? Constants.string.facebook : Constants.string.google).localize()
//            tableCell.imageViewTitle.image = indexPath.row == 0 ?  #imageLiteral(resourceName: "fb_icon") :  #imageLiteral(resourceName: "google_icon")
            
            if indexPath.row < 2 {
                tableCell.labelTitle.text = (signInArray[indexPath.row]).localize()
                tableCell.imageViewTitle.image = signInImageArray[indexPath.row]
            }else{
                if #available(iOS 13.0, *) {
                    tableCell.labelTitle.text = ""
                    let btnAuthorization = setupSOAppleSignIn()

                   

                    //btnAuthorization.center = tableCell.center
                    tableCell.addSubview(btnAuthorization)
                } else {
                    // Fallback on earlier versions
                    if indexPath.row == (signInArray.count - 1){
                        tableCell.labelTitle.textColor = .white
                        tableCell.backgroundColor = .black
                        
                    }

                }
            }
            
            
            
            return tableCell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.didSelect(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
}



extension SocialLoginViewController : PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        DispatchQueue.main.async {
            self.loader.isHidden = true
            showAlert(message: message, okHandler: nil, fromView: self)
        }
    }
    func getProfile(api: Base, data: Profile?) {
        
        if api == .getProfile {
            Common.storeUserData(from: data)
            storeInUserDefaults()
            self.navigationController?.present(Common.setDrawerController(), animated: true, completion: nil)
        }
        loader.isHideInMainThread(true)
        
    }
    
    func getOath(api: Base, data: LoginRequest?) {
        if api == .facebookLogin || api == .googleLogin || api == .appleLogin, let accessTokenString = data?.access_token {
            User.main.accessToken = accessTokenString
            User.main.refreshToken =  data?.refresh_token
            self.presenter?.get(api: .getProfile, parameters: nil)
        }
    }
    
    func socialLoginCheckMobileVerify(api: Base, data: SocialLoginMobileVerfied?) {
        
        if api == .isMobileVerfiy || api == .isAppleMobileVerify{
            
            if let status = data?.status{
                if status{
                    
                    if let isVerfied = data?.isVerified{
                        if isVerfied == 1{
                            //is verified very sccess full now call auth etc mk
                            
                            if let userData = self.userData{
                             //   userData.mobile = 12300
                                
                                if  self.isfaceBook{
                                    
                                    self.presenter?.post(api: .facebookLogin, data: userData.toData())
                                }else if self.isApple{
                                    
                                    self.presenter?.post(api: .appleLogin, data: userData.toData())
                                }
                                else{
                                    
                                    self.presenter?.post(api: .googleLogin, data: userData.toData())
                                }
                            }
                            
                        }else{
                            if let userData = self.userData{

                                var apiType:Base
                                
                                if isfaceBook{
                                    apiType = .facebookLogin
                                }else if isApple{
                                    apiType = .appleLogin
                                }else{
                                    apiType = .googleLogin
                                }
                            
                                
                                
                                
                            //let apiType : Base = isfaceBook ? .facebookLogin : .googleLogin
                            openPhoneNumberSelectionVC(data: userData, apiType: apiType)
                            }
                            //here call the  phone number
                        }
                    }
                }else{
                    
                    
                  

                    
                    
                    
                    self.loader.isHidden = true
                        if let userData = self.userData{
                            
                            
                            
                            if self.isApple{
                                
                                self.presenter?.post(api: .appleLogin, data: userData.toData())
                            }else{

                                                            var apiType:Base
                                                            
                                                            if isfaceBook{
                                                                apiType = .facebookLogin
                                                            }else if isApple{
                                                                apiType = .appleLogin
                                                            }else{
                                                                apiType = .googleLogin
                                                            }

                                                            
                                                            
                                //                        let apiType : Base = isfaceBook ? .facebookLogin : .googleLogin
                                                        openPhoneNumberSelectionVC(data: userData, apiType: apiType)
                            }
                            
                            

                        }
                        //here call the  phone number
                    
                    
                    
//                    if let message = data?.message{
//                        //show message alert herer
//                        DispatchQueue.main.async {
//                            self.loader.isHidden = true
//                            showAlert(message: message, okHandler: nil, fromView: self)
//                        }
//                    }
                }
            }
            
        }
        
    }
    
    
//    func getMobileNoVerficationCode(api: Base, data: SendCodeMobileNo?) {
//
//        if api == .isMobileVerfiy{
//
//            if let status = data?.status{
//                if status{
//
//                    if let isVerfied = data?.isVerified{
//                        if isVerfied{
//                            //is verified very sccess full now call auth etc mk
//
//                            if let userData = self.userData{
//
//                                if  self.isfaceBook{
//
//                                    self.presenter?.post(api: .facebookLogin, data: userData.toData())
//                                }else{
//
//                                    self.presenter?.post(api: .googleLogin, data: userData.toData())
//                                }
//                            }
//
//                        }else{
//                            if let userData = self.userData{
//
//                            let apiType : Base = isfaceBook ? .facebookLogin : .googleLogin
//                            openPhoneNumberSelectionVC(data: userData, apiType: apiType)
//                            }
//                            //here call the  phone number
//                        }
//                    }
//                }else{
//                    if let message = data?.message{
//                        //show message alert herer
//                        DispatchQueue.main.async {
//                            self.loader.isHidden = true
//                            showAlert(message: message, okHandler: nil, fromView: self)
//                        }
//                    }
//                }
//            }
//
//        }
//
//    }
    
}





class SocialLoginCell : UITableViewCell {
    
    @IBOutlet weak var imageViewTitle : UIImageView!
    @IBOutlet weak var labelTitle : UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setDesign()
    }
    
    // MARK:- Set Designs
    
    private func setDesign() {
        Common.setFont(to: self.labelTitle!, isTitle: true)
    }
    
    
    
}

//MARK: - Sign In With Apple

extension SocialLoginViewController
{
    func appleLogin()
    {
        print("loggging apple")
        
        self.isfaceBook = false
        self.isApple = true
        
        if #available(iOS 13.0, *) {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            
            controller.delegate = self
            controller.presentationContextProvider = self
            
            controller.performRequests()
            
        } else {
            // Fallback on earlier versions
            print("ASAuthorizationAppleIDProvider not availlble in this version")
        }
    }
    
    @available(iOS 13.0, *)
    func performExistingAccountSetupFlows()
    {
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                       ASAuthorizationPasswordProvider().createRequest()]
        
        let controller = ASAuthorizationController(authorizationRequests: requests)
        
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
    }
    
    @available(iOS 13.0, *)
    func saveUserCredentials(credentials: ASAuthorizationAppleIDCredential)
    {
        print("email ",credentials.email,
              "FullName ",credentials.fullName,
              "GivenName ",credentials.fullName?.givenName,
              "Family Name ",credentials.fullName?.familyName,
              "Identity Token ",credentials.identityToken,
              "User ",credentials.user)
        
        KeychainWrapper.standard.set(credentials.user, forKey: "UserIdentifier")

        if let userEmail = credentials.email
        {
             KeychainWrapper.standard.set(userEmail, forKey: "UserEmail")
        }
        
        if let fullName = credentials.fullName
        {
            if let firstName = fullName.givenName
            {
                KeychainWrapper.standard.set(firstName, forKey: "UserFirstName")
            }
            if let lastName = fullName.familyName
            {
                KeychainWrapper.standard.set(lastName, forKey:"UserLastName")
            }
        }
        
        if let token = credentials.identityToken
        {
            if let tokenString = String(bytes: token, encoding: .utf8)
            {
                print("token re :",tokenString)
                
                KeychainWrapper.standard.set(tokenString, forKey: "UserToken")
                
                self.loadAPI(accessToken: tokenString, loginBy: .apple)
            }
        }
        
        
        
        
       
    }
}

extension SocialLoginViewController: ASAuthorizationControllerDelegate
{
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
            
        case let appleIdCredentials as ASAuthorizationAppleIDCredential:
            
            saveUserCredentials(credentials: appleIdCredentials)
            
            break
        case let passwordCredential as ASPasswordCredential:
            print("lulu",passwordCredential.password)
            break
            
        default:
            break
        }
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Error in Completing Sign IN With Apple",error.localizedDescription)
    }
}


extension SocialLoginViewController: ASAuthorizationControllerPresentationContextProviding
{
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    
}
