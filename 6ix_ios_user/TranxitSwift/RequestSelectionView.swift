//
//  RequestSelectionView.swift
//  User
//
//  Created by CSS on 19/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class RequestSelectionView: UIView {
    
    @IBOutlet private weak var buttonScheduleRide : UIButton!
    @IBOutlet weak var buttonRideNow: Button!
    
    @IBOutlet var roundTripButton: Button!
    @IBOutlet private weak var labelEstimationFare : UILabel!
    @IBOutlet private weak var buttonChangePayment : UIButton!
    @IBOutlet private weak var imageViewModal : UIImageView!
    @IBOutlet weak var labelPaymentType: UILabel!
    @IBOutlet weak var labelCarType: UILabel!
    
    @IBOutlet var walletAmountLabel: UILabel!
    
    @IBOutlet var walletSelectionImageView: ImageView!
    
    @IBOutlet var paymentDropdownImageView: UIImageView!
    @IBOutlet var sechduleView: UIView!
    
    @IBOutlet var dividerView: UILabel!
    @IBOutlet var walletTitelLabel: UILabel!
    var scheduleAction : ((Service)->())?
    var rideotp :((Service)->())?
    var rideNowAction : ((Service)->())?
    var roundTripAction : ((Service)->())?
    var paymentChangeClick : ((_ completion : @escaping ((CardEntity?)->()))->Void)?
    var onclickCoupon : ((_ couponList : [PromocodeEntity],_ selected : PromocodeEntity?, _ promo : ((PromocodeEntity?)->())?)->Void)?
    var selectedCoupon : PromocodeEntity? { // Selected Promocode
        didSet{
            if let percentage = selectedCoupon?.percentage, let maxAmount = selectedCoupon?.max_amount, let fare = self.service?.pricing?.estimated_fare{
                let discount = fare*(percentage/100)
                let discountAmount = discount > maxAmount ? maxAmount : discount
                self.setEstimationFare(amount: fare-discountAmount)
                
            } else {
                self.setEstimationFare(amount: self.service?.pricing?.estimated_fare)
            }
        }
    }
    
    private var availablePromocodes = [PromocodeEntity]() { // Entire Promocodes available for selection
        didSet {
            self.isPromocodeEnabled = availablePromocodes.count>0
        }
    }
    
    private var isWalletChecked = false {  // Handle Wallet
        didSet {
            self.service?.pricing?.useWallet = isWalletChecked ? 1 : 0
        }
    }
    private var selectedCard : CardEntity?
    var paymentType : PaymentType = .NONE {
        didSet {
            var paymentString : String = .Empty
            if paymentType == .NONE {
                paymentString = Constants.string.NA.localize()
            }else if paymentType == .CAC {
                paymentString = Constants.string.corporrateAc.localize()
            } else {
                paymentString = paymentType == .CASH ? PaymentType.CASH.rawValue.localize() : (self.selectedCard == nil ? PaymentType.CARD.rawValue.localize() : "\("XXXX-"+String.removeNil(self.selectedCard?.last_four))")
            }
            
            labelPaymentType.text = paymentString
           
        }
    }
    
    private var isPromocodeEnabled = false {
        didSet {

        }
    }
    
    private var service : Service?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialLoads()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

// MARK:- Methods

extension RequestSelectionView {
    
    // MARK:- Initial Loads
    
    private func initialLoads() {
        //self.backgroundColor = .clear
        self.isWalletChecked = false
        self.localize()
        self.setDesign()
        self.paymentType = .NONE
        if (User.main.isCardAllowed == false){
            self.buttonChangePayment.isHidden = true
        }else {
            self.buttonChangePayment.isHidden = !(User.main.isCashAllowed || User.main.isCardAllowed)
        }
//        self.buttonChangePayment.isHidden = !(User.main.isCashAllowed && User.main.isCardAllowed) // Change button enabled only if both payment modes are enabled
//        let isPakistan = (userCurrentLocation?.isPakistan ?? false)
        self.buttonChangePayment.addTarget(self, action: #selector(self.buttonChangePaymentAction), for: .touchUpInside)
        self.isPromocodeEnabled = false
        self.presenter?.get(api: .promocodes, parameters: nil)
//        self.paymentDropdownImageView.isHidden = isPakistan
//        self.sechduleView.isHidden = isPakistan
//        self.dividerView.isHidden = isPakistan
//        self.buttonChangePayment.isHidden = isPakistan
        
    }
    
    
    // MARK:- Set Designs //
    
    private func setDesign() {
        
        Common.setFont(to: buttonRideNow!, isTitle: true)
        Common.setFont(to: roundTripButton!, isTitle: true)
        Common.setFont(to: labelEstimationFare!, isTitle: true)
        Common.setFont(to: walletAmountLabel!, isTitle: true)
        Common.setFont(to: walletTitelLabel!, isTitle: true)
    }
    
    
    // MARK:- Localize
    
    private func localize() {
        
        self.buttonRideNow.setTitle(Constants.string.rideNow.localize().uppercased(), for: .normal)
        self.roundTripButton.setTitle(Constants.string.ROUNDTRIP.localize().uppercased(), for: .normal)
        self.walletAmountLabel.text = User.main.walletBalance
        
    }
    
    
    func setValues(values : Service) {
        labelCarType.text = values.name
        self.service = values
        self.setEstimationFare(amount: self.service?.pricing?.estimated_fare)
        self.paymentType = User.main.isCashAllowed ? .CASH :( User.main.isCardAllowed ? .CARD : .NONE)
        self.imageViewModal.setImage(with: values.image, placeHolder: #imageLiteral(resourceName: "CarplaceHolder"))
        
    }

    func setEstimationFare(amount : Float?) {
        self.labelEstimationFare.text = "\(User.main.currency ?? .Empty) \(Formatter.shared.limit(string: "\(amount ?? 0)", maximumDecimal: 2))" //:- \(Int(amount ?? -3) + 3)
        
        
        //        self.labelEstimationFare.text = "\(User.main.currency ?? .Empty) \(Int(amount ?? 0))" //\(Formatter.shared.limit(string: "\(amount ?? 0)", maximumDecimal: 2)) //:- \(Int(amount ?? -3) + 3)
    }
    
    @IBAction private func buttonScheduleAction(){
        self.service?.promocode = self.selectedCoupon
        self.scheduleAction?(self.service!)
    }
    
    @IBAction private func buttonRideNowAction(){
        self.service?.promocode = self.selectedCoupon
        if paymentType.rawValue == "CORPORATE_ACCOUNT"{
            print("corporate account")
            let corporatePin = UserDefaults.standard.integer(forKey: "corporate_pin")
            
            if corporatePin == 0 {
                self.rideNowAction?(self.service!)
            }else{
                self.rideotp?(self.service!)
            }
           
        }else {
              self.rideNowAction?(self.service!)
        }
        
        
    }
    @IBAction private func roundTripButtonPressed(){
        self.roundTripAction?(self.service!)
    }
    
    
    @IBAction private func useWalletAction(){
        self.isWalletChecked = !isWalletChecked
        self.walletSelectionImageView.image = self.isWalletChecked ? UIImage(named:"check") : UIImage(named:"check-box-empty")
        
    }
    @IBAction private func buttonCouponAction() {
        self.onclickCoupon?( self.availablePromocodes,self.selectedCoupon, { [weak self] selectedCouponCode in  // send Available couponlist and get the selected coupon entity
            self?.selectedCoupon = selectedCouponCode
            self?.isPromocodeEnabled = true
            })
    }
    @IBAction private func buttonChangePaymentAction() {
        self.paymentChangeClick?({ [weak self] selectedCard in
            self?.selectedCard = selectedCard
        })
    }
}

// MARK:- PostViewProtocol

extension RequestSelectionView : PostViewProtocol {
    func onError(api: Base, message: String, statusCode code: Int) {
        print(message)
    }
    
    func getPromocodeList(api: Base, data: [PromocodeEntity]) {
        self.availablePromocodes = data
    }
}

