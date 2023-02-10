//
//  WalletViewController.swift
//  User
//
//  Created by CSS on 24/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding

class WalletViewController: UIViewController {
    
    @IBOutlet private weak var labelBalance : Label!
    @IBOutlet private weak var textFieldAmount : UITextField!
    @IBOutlet private weak var viewWallet : UIView!
    @IBOutlet private weak var buttonAddAmount : UIButton!
    @IBOutlet var labelWallet: UILabel!
    @IBOutlet var labelAddMoney: UILabel!
    @IBOutlet private var buttonsAmount : [UIButton]!
    @IBOutlet private weak var viewCard : UIView!
    @IBOutlet private weak var labelCard: UILabel!
    @IBOutlet private weak var buttonChange : UIButton!
    
    private var selectedCardEntity : CardEntity?
    
    private var isWalletEnabled : Bool = false {
        didSet{
            self.buttonAddAmount.isEnabled = isWalletEnabled
            self.buttonAddAmount.backgroundColor = isWalletEnabled ? .primary : .lightGray
            self.viewCard.isHidden = !isWalletEnabled
        }
    }
    
    private var isWalletAvailable : Bool = false {
        didSet {
            self.buttonAddAmount.isHidden = !isWalletAvailable
            self.viewCard.alpha = CGFloat(isWalletAvailable ? 1 : 0)
            self.viewWallet.alpha = CGFloat(isWalletAvailable ? 1 : 0)
        }
    }
    
    private lazy var loader  : UIView = {
        return createActivityIndicator(self.view)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewControllerName = String.init(describing: self.classForCoder)
        print("VCName***: \(viewControllerName)")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.isWalletAvailable = User.main.isCardAllowed
        self.initalLoads()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       // IQKeyboardManager.sharedManager().enable = false
    }
    
}

//NSDictionary *params = @{@"amount":_enterAmtTxtfiedl.text, @"card_id":strCardID};

extension WalletViewController {
    
    private func initalLoads() {
        
        self.setWalletBalance()
        self.presenter?.get(api: .getProfile, parameters: nil)
        self.view.dismissKeyBoardonTap()
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
        self.navigationItem.title = Constants.string.wallet.localize()
        self.setDesign()
        self.textFieldAmount.placeholder = String.removeNil(User.main.currency)+" "+"\(0)"
        self.textFieldAmount.delegate = self
        for (index,button) in buttonsAmount.enumerated() {
            button.tag = (index*100)+99
            button.setTitle(String.removeNil(String.removeNil(User.main.currency)+" \(button.tag)"), for: .normal)
        }
        self.buttonChange.addTarget(self, action: #selector(self.buttonChangeCardAction), for: .touchUpInside)
        self.isWalletEnabled = false
        KeyboardAvoiding.avoidingView = self.view
        self.presenter?.get(api: .getCards, parameters: nil)
    }
    
    // MARK:- Set Designs
    
    private func setDesign() {
        
        Common.setFont(to: labelBalance!, isTitle: true)
        Common.setFont(to: textFieldAmount!)
        Common.setFont(to: labelCard!)
        Common.setFont(to: buttonChange!)
        buttonChange.setTitle(Constants.string.changePayment.localize(), for: .normal)
        labelAddMoney.text = Constants.string.addAmount.localize()
        labelWallet.text = Constants.string.yourWalletAmnt.localize()
        buttonAddAmount.setTitle(Constants.string.ADDAMT, for: .normal)
        
    }
    
    @IBAction private func buttonAmountAction(sender : UIButton) {
        
        textFieldAmount.text = "\(sender.tag)"
    }
    
    private func setCardDetails() {
        if let lastFour = self.selectedCardEntity?.last_four {
           self.labelCard.text = "XXXX-XXXX-XXXX-"+lastFour
        }
    }
    
    
    @IBAction private func buttonAddAmountClick() {
        self.view.endEditingForce()
        guard let text = textFieldAmount.text?.replacingOccurrences(of: String.removeNil(User.main.currency), with: "").removingWhitespaces(),  text.isNumber, Int(text)! > 0  else {
            self.view.make(toast: Constants.string.enterValidAmount.localize())
            return
        }
        guard self.selectedCardEntity != nil else{
            return
        }
        self.loader.isHidden = false
        let cardId = self.selectedCardEntity?.card_id
        self.selectedCardEntity?.strCardID = cardId
        self.selectedCardEntity?.amount = text
        self.presenter?.post(api: Base.addMoney, data: self.selectedCardEntity?.toData())
    }
    
    // MARK:- Change Card Action
    
    @IBAction private func buttonChangeCardAction() {
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.PaymentViewController) as? PaymentViewController{
            vc.isChangingPayment = true
            vc.isShowCash = false
            vc.onclickPayment = { type, cardEntity in
                self.selectedCardEntity = cardEntity
                self.setCardDetails()
                vc.navigationController?.dismiss(animated: true, completion: nil)
            }
            let navigation = UINavigationController(rootViewController: vc)
            self.present(navigation, animated: true, completion: nil)
        }
        
    }
    
    
    private func setWalletBalance() {
        DispatchQueue.main.async {
            self.labelBalance.text = String.removeNil(User.main.currency)+" \(User.main.wallet_balance ?? 0)"
        }
    }
    
    
}


extension WalletViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
     //   print(IQKeyboardManager.sharedManager().keyboardDistanceFromTextField)
    }
}

// MARK:- PostViewProtocol

extension WalletViewController : PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        DispatchQueue.main.async {
            self.loader.isHidden = true
            showAlert(message: message, okHandler: nil, fromView: self)
        }
    }
    
    func getProfile(api: Base, data: Profile?) {
        Common.storeUserData(from: data)
        storeInUserDefaults()
        self.setWalletBalance()
    }
    
    func getCardEnities(api: Base, data: [CardEntity]) {
        self.selectedCardEntity = data.first
        DispatchQueue.main.async {
            self.setCardDetails()
            self.isWalletEnabled = !data.isEmpty
            if data.isEmpty && User.main.isCardAllowed {
                showAlert(message: Constants.string.addCard.localize(), okHandler: {
                   self.push(id: Storyboard.Ids.AddCardViewController, animation: true)
                }, cancelHandler: nil, fromView: self)
            }
        }
    }
   
    func getWalletEntity(api: Base, data: WalletEntity?) {
        User.main.wallet_balance = data?.balance
        storeInUserDefaults()
        DispatchQueue.main.async {
            self.loader.isHidden = true
            self.setWalletBalance()
            self.textFieldAmount.text = nil
            UIApplication.shared.keyWindow?.makeToast(data?.message)
        }
    }
    
}

