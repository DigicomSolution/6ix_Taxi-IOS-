//
//  AddCardViewController.swift
//  User
//
//  Created by CSS on 23/07/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit
import CreditCardForm
import Stripe

class AddCardViewController: UIViewController {

    @IBOutlet private weak var creditCardView : CreditCardFormView!
    let paymentTextField = STPPaymentCardTextField()
    private lazy var loader  : UIView = {
        return createActivityIndicator(self.view)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialLoads()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension AddCardViewController {
    
    func initialLoads() {
        
        STPAPIClient.shared.publishableKey = User.main.stripeKey ?? stripePublishableKey//need to add on drive code
        self.creditCardView.cardHolderString =  String.removeNil(User.main.firstName)+" "+String.removeNil(User.main.lastName)
        self.creditCardView.defaultCardColor = .primary
        self.createTextField()
        self.navigationController?.isNavigationBarHidden = false
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
        self.navigationItem.title = Constants.string.addCardPayments.localize()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemGreen]
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: Constants.string.Done.localize(), style: .done, target: self, action: #selector(self.doneButtonClick))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.view.dismissKeyBoardonTap()
    }
    
    func createTextField() {
        paymentTextField.frame = CGRect(x: 15, y: 199, width: self.view.frame.size.width - 30, height: 44)
        paymentTextField.delegate = self
        paymentTextField.translatesAutoresizingMaskIntoConstraints = false
        paymentTextField.borderWidth = 0
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: paymentTextField.frame.size.height - width, width:  paymentTextField.frame.size.width, height: paymentTextField.frame.size.height)
        border.borderWidth = width
        paymentTextField.layer.addSublayer(border)
        paymentTextField.layer.masksToBounds = true
        
        view.addSubview(paymentTextField)
        
        NSLayoutConstraint.activate([
            paymentTextField.topAnchor.constraint(equalTo: creditCardView.bottomAnchor, constant: 20),
            paymentTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paymentTextField.widthAnchor.constraint(equalToConstant: self.view.frame.size.width-20),
            paymentTextField.heightAnchor.constraint(equalToConstant: 44)
            ])
    }
    
    // MARK:- Done Button Click
    
    @IBAction private func doneButtonClick() {
        self.view.endEditingForce() 
        self.loader.isHidden = false
        
        let cardParams = STPCardParams()
        cardParams.currency = "PKR"
        cardParams.number = paymentTextField.cardNumber
        cardParams.expMonth = UInt((paymentTextField.expirationMonth))
        cardParams.expYear = UInt((paymentTextField.expirationYear))
        cardParams.cvc = paymentTextField.cvc
        STPAPIClient.shared.createToken(withCard: cardParams) { (stpToken, error) in
            
            guard let token = stpToken?.tokenId else {
                self.loader.isHideInMainThread(true)
                print(error?.localizedDescription ?? "no error found")
                showAlert(message: error?.localizedDescription ?? "somting went wrong..", okHandler: nil, fromView: self)
                return
            }
            
            var cardEntity = CardEntity()
            cardEntity.stripe_token = token
            self.presenter?.post(api: .postCards, data: cardEntity.toData())
            
        }
    }
}

// MARK:- STPPaymentCardTextFieldDelegate

extension AddCardViewController : STPPaymentCardTextFieldDelegate {
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        self.navigationItem.rightBarButtonItem?.isEnabled = textField.isValid
        creditCardView.paymentCardTextFieldDidChange(cardNumber: textField.cardNumber, expirationYear: UInt(textField.expirationYear), expirationMonth: UInt(textField.expirationMonth), cvc: textField.cvc)
    }
    
    func paymentCardTextFieldDidEndEditingExpiration(_ textField: STPPaymentCardTextField) {
        creditCardView.paymentCardTextFieldDidEndEditingExpiration(expirationYear: UInt(textField.expirationYear))
    }
    
    func paymentCardTextFieldDidBeginEditingCVC(_ textField: STPPaymentCardTextField) {
        creditCardView.paymentCardTextFieldDidBeginEditingCVC()
    }
    
    func paymentCardTextFieldDidEndEditingCVC(_ textField: STPPaymentCardTextField) {
        creditCardView.paymentCardTextFieldDidEndEditingCVC()
    }
}

// MARK:- PostViewProtocol

extension AddCardViewController : PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        DispatchQueue.main.async {
            self.loader.isHidden = true
            showAlert(message: message, okHandler: nil, fromView: self)
        }
    }
    func success(api: Base, message: String?) {
        DispatchQueue.main.async {
            self.loader.isHidden = true
            let alert = showAlert(message: message) { (_) in
                self.navigationController?.popViewController(animated: true)
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
}
