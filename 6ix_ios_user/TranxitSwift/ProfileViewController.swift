//
//  ProfileViewController.swift
//  User
//
//  Created by CSS on 04/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController {
    
    @IBOutlet private weak var imageViewEdit : UIImageView!
    @IBOutlet private weak var viewImageChange : UIView!
    @IBOutlet private weak var imageViewProfile : UIImageView!
    @IBOutlet private weak var textFieldFirst : HoshiTextField!
    @IBOutlet private weak var textFieldLast : HoshiTextField!
    @IBOutlet private weak var textFieldPhone : HoshiTextField!
    @IBOutlet private weak var textFieldEmail : HoshiTextField!
    @IBOutlet private weak var buttonSave : UIButton!
    @IBOutlet private weak var buttonChangePassword : UIButton!
    @IBOutlet private weak var labelBusiness : UILabel!
    @IBOutlet private weak var labelPersonal : UILabel!
    @IBOutlet private weak var labelTripType : UILabel!
    @IBOutlet private weak var imageViewBusiness : UIImageView!
    @IBOutlet private weak var imageViewPersonal : UIImageView!
    @IBOutlet private weak var viewBusiness : UIView!
    @IBOutlet private weak var viewPersonal : UIView!
    
    
    private var tripType :TripType = .Business { // Store Radio option TripType
        
        didSet {
            
            self.imageViewBusiness.image = tripType == .Business ? #imageLiteral(resourceName: "radio-on-button") : #imageLiteral(resourceName: "circle-shape-outline")
            self.imageViewPersonal.image = tripType == .Personal ? #imageLiteral(resourceName: "radio-on-button") : #imageLiteral(resourceName: "circle-shape-outline")
            
        }
        
    }
    
    private var changedImage : UIImage?
    
    private lazy var loader : UIView = {
       
        return createActivityIndicator(UIScreen.main.focusedView ?? self.view)
        
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let viewControllerName = String.init(describing: self.classForCoder)
        print("VCName***: \(viewControllerName)")
        self.initialLoads()
        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        //self.isEnabled = IQKeyboardManager.shared.enable
        //IQKeyboardManager.shared.enable = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
}

// MARK:- Methods

extension ProfileViewController {
    
    private func initialLoads() {
        
        self.viewPersonal.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.setTripTypeAction(sender:))))
        self.viewBusiness.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.setTripTypeAction(sender:))))
        self.imageViewProfile.isUserInteractionEnabled = true
        [self.imageViewEdit, self.viewImageChange].forEach({$0?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.changeImage)))}) 
        self.buttonSave.addTarget(self, action: #selector(self.buttonSaveAction), for: .touchUpInside)
        self.buttonChangePassword.addTarget(self, action: #selector(self.changePasswordAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(self.backButtonClick))
        self.navigationItem.title = Constants.string.profile.localize()
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
        self.localize()
        self.setDesign()
        self.setProfile()
        self.view.dismissKeyBoardonTap()
        self.presenter?.get(api: .getProfile, parameters: nil)
        self.tableView.tableHeaderView?.bounds.size = CGSize(width: self.tableView.bounds.width, height: 200)
        self.buttonChangePassword.isHidden = (User.main.loginType != LoginType.manual.rawValue)
        self.navigationController?.isNavigationBarHidden = false
        self.textFieldPhone.isEnabled = false
    }
    
    // MARK:- Set Profile Details
    
    private func setProfile(){
        
        let url = (User.main.picture?.contains(WebConstants.string.http) ?? false) ? User.main.picture : Common.getImageUrl(for: User.main.picture)
        
        Cache.image(forUrl: url) { (image) in
            DispatchQueue.main.async {
                self.imageViewProfile.image = image == nil ? #imageLiteral(resourceName: "userPlaceholder") : image
            }
        }
        
//        Cache.image(forUrl: Common.getImageUrl(for: User.main.picture)) { (image) in
//            DispatchQueue.main.async {
//                self.imageViewProfile.image = image == nil ? #imageLiteral(resourceName: "userPlaceholder") : image
//            }
//        }
        self.textFieldFirst.text = User.main.firstName
        self.textFieldLast.text = User.main.lastName
        self.textFieldEmail.text = User.main.email
        self.textFieldPhone.text = User.main.mobile
    }
    
    //MARK:- Set Designs
    
    private func setDesign() {
        
        var attributes : [ NSAttributedString.Key : Any ] = [.font : UIFont.systemFont(ofSize: 18, weight: .bold)]
        attributes.updateValue(UIColor.white, forKey: NSAttributedString.Key.foregroundColor)
        self.buttonSave.setAttributedTitle(NSAttributedString(string: Constants.string.save.localize().uppercased(), attributes: attributes), for: .normal)
        [textFieldFirst, textFieldLast, textFieldEmail, textFieldPhone].forEach({
            $0?.borderInactiveColor = nil
            $0?.borderActiveColor = nil
        })
        self.textFieldEmail.isEnabled = false
        
        Common.setFont(to: textFieldEmail!)
        Common.setFont(to: textFieldFirst!)
        Common.setFont(to: textFieldLast!)
        Common.setFont(to: textFieldPhone!)
        Common.setFont(to: buttonSave!)
        Common.setFont(to: buttonChangePassword!)
        Common.setFont(to: labelBusiness!)
        Common.setFont(to: labelPersonal!)
        Common.setFont(to: labelTripType!)
    }
    
    // MARK:- Show Image
    
    @IBAction private func changeImage(){
        
        self.showImage { (image) in
            if image != nil {
                self.imageViewProfile.image = image?.resizeImage(newWidth: 200)
                self.changedImage = self.imageViewProfile.image
            }
        }
    }
    
    
    // MARK:- Trip Type Action
    
   @IBAction private func setTripTypeAction(sender : UITapGestureRecognizer) {
        
        guard let senderView = sender.view else { return }
        
        self.tripType = senderView == viewPersonal ? .Personal : .Business
        
    }
    
    // MARK:- Update Profile Details
    
    @IBAction private func buttonSaveAction(){
        
        self.view.endEditingForce()
        
        guard let firstName = self.textFieldFirst.text, firstName.count>0 else {
            UIScreen.main.focusedView?.make(toast: ErrorMessage.list.enterFirstName.localize())
            return
        }
        
        guard let lastName = self.textFieldLast.text, lastName.count>0 else {
            UIScreen.main.focusedView?.make(toast: ErrorMessage.list.enterLastName.localize())
            return
        }
        
        guard let mobile = self.textFieldPhone.text, mobile.count>0 else {
            UIScreen.main.focusedView?.make(toast: ErrorMessage.list.enterMobileNumber.localize())
            return
        }
        
//        guard let email = self.textFieldEmail.text, email.count>0 else {
//            UIScreen.main.focusedView?.make(toast: ErrorMessage.list.enterEmail.localize())
//            return
//        }
        
//        guard Common.isValid(email: email) else {
//            UIScreen.main.focusedView?.make(toast: ErrorMessage.list.enterValidEmail.localize())
//            return
//        }
        
        self.loader.isHidden = false
        
        let profile = Profile()
        profile.device_token = deviceTokenString
        profile.email = User.main.email
        profile.first_name = firstName
        profile.last_name = lastName
        profile.mobile = mobile
        
        var json = profile.JSONRepresentation
        json.removeValue(forKey: "id")
        json.removeValue(forKey: "picture")
        json.removeValue(forKey: "access_token")
        json.removeValue(forKey: "currency")
        json.removeValue(forKey: "wallet_balance")
        json.removeValue(forKey: "sos")

        if self.changedImage != nil, let dataImg = self.changedImage!.pngData() {
            self.presenter?.post(api: .updateProfile, imageData: [WebConstants.string.picture : dataImg], parameters: json)
        } else {
            self.presenter?.post(api: .updateProfile, data: profile.toData())
        }
    }
  
    private func setLayout(){
        
        self.imageViewProfile.makeRoundedCorner()
        self.viewImageChange.frame.origin.y = self.imageViewProfile.frame.origin.y + ((self.imageViewProfile.frame.height/3)*2)
        self.imageViewEdit.frame.origin.y = self.viewImageChange.frame.origin.y+(self.viewImageChange.frame.height/3)
    }
    
    // MARK:- Localize
    
    private func localize() {
        
        self.textFieldFirst.placeholder = Constants.string.first.localize()
        self.textFieldLast.placeholder = Constants.string.last.localize()
        self.textFieldPhone.placeholder = Constants.string.phoneNumber.localize()
        self.textFieldEmail.placeholder = Constants.string.email.localize()
        self.labelTripType.text = Constants.string.tripType.localize()
        self.labelBusiness.text = Constants.string.business.localize()
        self.labelPersonal.text = Constants.string.personal.localize()
        self.buttonChangePassword.setTitle(Constants.string.lookingToChangePassword.localize(), for: .normal)
        
    }
    
    //MARK:- Button Change Password Action
    
    @IBAction private func changePasswordAction() {
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.ChangeResetPasswordController) as? ChangeResetPasswordController {
            vc.isChangePassword = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
}


// MARK:- TextField Delegate

extension ProfileViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
       return textField.resignFirstResponder()
    }
    
}


// MARK:- ScrollView Delegate

extension ProfileViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {

        guard scrollView.contentOffset.y<0 else { return }

        print(scrollView.contentOffset)

        let inset = abs(scrollView.contentOffset.y/imageViewProfile.frame.height)

        self.imageViewProfile.transform = CGAffineTransform(scaleX: 1+inset, y: 1+inset)
        self.viewImageChange.transform = CGAffineTransform(scaleX: 1+inset, y: 1+inset)
        self.imageViewEdit.transform = CGAffineTransform(scaleX: 1+inset, y: 1+inset)
    }
    
}


// MARK:- PostviewProtocol

extension ProfileViewController : PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        
        DispatchQueue.main.async {
           UIApplication.shared.keyWindow?.make(toast: message)
            self.loader.isHidden = true
        }
        
    }
    
    func getProfile(api: Base, data: Profile?) {
        Common.storeUserData(from: data)
        storeInUserDefaults()
        DispatchQueue.main.async {
            self.loader.isHidden = true
            self.setProfile()
            if api == .updateProfile {
                UIApplication.shared.keyWindow?.make(toast: Constants.string.profileUpdated.localize())
            }
        }
        
    }
    
    
}
