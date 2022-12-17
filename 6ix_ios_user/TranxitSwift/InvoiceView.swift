//
//  InvoiceView.swift
//  User
//
//  Created by CSS on 24/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class InvoiceView: UIView {

    @IBOutlet weak var paymentChangeIconView: UIImageView!
    @IBOutlet weak var tripDetailsStackView: UIStackView!
    @IBOutlet private weak var labelBookingString : UILabel!
    @IBOutlet private weak var labelBooking : UILabel!
    @IBOutlet private weak var labelDistanceTravelledString : UILabel!
    @IBOutlet private weak var labelDistanceTravelled : UILabel!
    @IBOutlet private weak var labelTimeTakenString : UILabel!
    @IBOutlet private weak var labelTimeTaken : UILabel!
    @IBOutlet private weak var labelBaseFareString : UILabel!
    @IBOutlet private weak var labelBaseFare : UILabel!
    @IBOutlet private weak var labelDistanceFareString : UILabel!
    @IBOutlet private weak var labelDistanceFare : UILabel!
    @IBOutlet private weak var labelTimeFareString : UILabel!
    @IBOutlet private weak var labelTimeFare : UILabel!
    @IBOutlet private weak var labelTax : UILabel!
    @IBOutlet private weak var labelTaxString : UILabel!
    
    @IBOutlet private weak var labelTipsString : UILabel!
    @IBOutlet private weak var buttonTips : UIButton!
    @IBOutlet private weak var labelTotalString : UILabel!
    @IBOutlet private weak var labelTotal : UILabel!
    @IBOutlet private weak var labelWalletString : UILabel!
    @IBOutlet private weak var labelWallet : UILabel!
    @IBOutlet private weak var labelDiscountString : UILabel!
    @IBOutlet private weak var labelDiscount : UILabel!
    @IBOutlet private weak var labelToPayString : UILabel!
    @IBOutlet private weak var labelToPay : UILabel!
    @IBOutlet private weak var labelPaymentType : Label!
    @IBOutlet private weak var buttonChangePayment : UIButton!
    @IBOutlet private weak var buttonPayNow : UIButton!
    @IBOutlet private weak var labelTitle : UILabel!
    
    @IBOutlet var timeTakenView: UIView!
    @IBOutlet private weak var viewDistanceFare : UIView!
    @IBOutlet private weak var viewTimeFare : UIView!
    @IBOutlet private weak var viewTax : UIView!
    @IBOutlet private weak var viewWallet : UIView!
    @IBOutlet private weak var viewDiscount : UIView!
    @IBOutlet private weak var viewDistance: UIView!
    @IBOutlet private weak var viewTips : UIView!
    @IBOutlet weak var pickedupAddressLabel: UILabel!
    @IBOutlet weak var stop1Label: UILabel!
    @IBOutlet weak var stop2Label: UILabel!
    @IBOutlet weak var stop3Label: UILabel!
    
    @IBOutlet weak var viewStop3: UIView!
    @IBOutlet weak var viewStop2: UIView!
    @IBOutlet weak var tripDetailsIconView: UIImageView!
    
    var stops: [Stops]?
    var sourceAddress: String?
    var openTripDetails = false
    var isShowingPastRides = false{
        didSet{
            self.buttonPayNow.isHidden = !isShowingPastRides
        }
    }
    
    private var viewTipsXib : ViewTips?
    private var paymentType : PaymentType = .NONE { // Check Payment Type
        didSet {
            if paymentType != oldValue {
                
                var paymentString = ""
                if paymentType == .CAC
                {
                    paymentString = Constants.string.corporrateAc.localize()

                    
                }else{
                    
                    paymentString = paymentType == .CASH ? PaymentType.CASH.rawValue.localize() : (self.selectedCard?.last_four==nil) ? PaymentType.CARD.rawValue.localize() : "XXXX-\(String.removeNil(self.selectedCard?.last_four))"

                }
                
                let text = "\(Constants.string.payment.localize()):\(paymentString)"
                self.labelPaymentType.text = text
                self.labelPaymentType.attributeColor = .lightGray

//                self.labelPaymentType.startLocation = ((text.count)-(paymentType.rawValue.localize().count))
//                self.labelPaymentType.length = paymentType.rawValue.localize().count
                if (User.main.isCardAllowed == false){
                    self.buttonChangePayment.isHidden = true
                    self.paymentChangeIconView.isHidden = true
                }else {
                    let isHide = (isShowingRecipt && User.main.isCardAllowed)
                    self.buttonChangePayment.isHidden = isHide
                    self.paymentChangeIconView.isHidden = isHide
                }
                self.viewTips.isHidden = !(self.paymentType == .CARD || isShowingRecipt)
                if self.paymentType == .CARD || isShowingRecipt{
                    self.buttonTips.alpha = 1.0
                    startTipAnimation()
                }
                self.viewTips.isUserInteractionEnabled = !isShowingRecipt // Disable userInteraction to Tips if from Past trips
            }
        }
    }
    
    private var couponId : String? = nil {
        didSet {
            
        }
    }
    
    private var serviceCalculator : ServiceCalculator = .NONE {  // Hide Distance Fare and Time fare based on Service Calculator
        didSet {
            self.viewDistanceFare.isHidden = ![ServiceCalculator.DISTANCE, .DISTANCEHOUR, .DISTANCEMIN, .FIXED].contains(serviceCalculator)
            self.viewTimeFare.isHidden = ![ServiceCalculator.MIN, .HOUR,.DISTANCEHOUR, .DISTANCEMIN].contains(serviceCalculator)
            self.timeTakenView.isHidden = ![ServiceCalculator.MIN, .HOUR,.DISTANCEHOUR, .DISTANCEMIN].contains(serviceCalculator)
           
        }
    }
    
    private var isUsingWallet = false {
        didSet {
             self.viewWallet.isHidden = !isUsingWallet
        }
    }
    
    private var isDiscountApplied = false {
        didSet {
           self.viewDiscount.isHidden = !self.isDiscountApplied
        }
    }
    
    private var tipsAmount : Float = 0 {
        didSet {
           self.updatePayment()
        }
    }
    
    var onClickPaynow : ((Float)->Void)?
    var onDoneClick : ((Bool)->Void)?
    var onClickChangePayment : ((_ completion : @escaping ((CardEntity)->()))->Void)?
    var selectedCard : CardEntity?
    var isShowingRecipt = false
    private var requestId = 0
    private var total : Float = 0 {
        didSet{
            self.updatePayment()
        }
    }
    private var payyable : Float = 0 {
        didSet{
            self.updatePayment()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.intialLoads()
    }
    
    override func didMoveToWindow() {
        print("bolt move",self.stops)
        
        if let source = sourceAddress
        {
            pickedupAddressLabel.text = source
        }
        
        let count = stops?.count
        
        if let stops = self.stops
        {
            
            if count == 1
            {
                stop1Label.text = "Stop 1: "+stops[0].d_address!
            }
            else if count == 2
            {
                viewStop2.isHidden = false
                stop1Label.text = "Stop 1: "+stops[0].d_address!
                stop2Label.text = "Stop 2: "+stops[1].d_address!
            }
            else if count == 3
            {
                viewStop2.isHidden = false
                viewStop3.isHidden = false
                stop1Label.text = "Stop 1: "+stops[0].d_address!
                stop2Label.text = "Stop 2: "+stops[1].d_address!
                stop3Label.text = "Stop 3: "+stops[2].d_address!
            }
            
        }
    }
    
    @objc private func animateTripDetails(){
        openTripDetails = !openTripDetails
        UIView.animate(withDuration: 0.1) {
            if self.openTripDetails{
                self.tripDetailsStackView.alpha = 1.0
                self.tripDetailsIconView.image = UIImage(named: "chevron_left")
                
            }else{
                self.tripDetailsStackView.alpha = 0.0
                self.tripDetailsIconView.image = UIImage(named: "chevron_down")
            }
        }
    }
    
    @IBAction func onTripDetails(_ sender: UIButton) {
        animateTripDetails()
    }
    
    
}



// MARK:- Methods

extension InvoiceView {
    
    func intialLoads() {
        
        viewStop2.isHidden = true
        viewStop3.isHidden = true
        
        print("bolt",self.stops)
        
        self.buttonPayNow.isHidden = true
        tripDetailsIconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(animateTripDetails)))
        tripDetailsIconView.isUserInteractionEnabled = true
        
        paymentChangeIconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.buttonChangePaymentAction)))
        paymentChangeIconView.isUserInteractionEnabled = true
        self.buttonPayNow.addTarget(self, action: #selector(self.buttonPaynowAction), for: .touchUpInside)
        self.buttonChangePayment.addTarget(self, action: #selector(self.buttonChangePaymentAction), for: .touchUpInside)
        self.buttonChangePayment.setTitle(Constants.string.changePayment.localize(), for: .normal)
        
    
        self.buttonTips.addTarget(self, action: #selector(self.buttonTipsAction(sender:)), for: .touchUpInside)
        self.tipsAmount = 0
        self.localize()
        self.setDesign()
     //   self.viewDistance.isHidden = true 
    }
    
    func startTipAnimation(){
        UIView.animate(withDuration: 1.0, delay: 0, options: [UIView.AnimationOptions.repeat, .autoreverse, .allowUserInteraction], animations: {
            self.buttonTips.alpha = 0.2
            
        }, completion: nil)
    }
    
    // MARK:- Set Designs
    
    private func setDesign() {
        
//        Common.setFont(to: labelTitle, isTitle: true)
//        Common.setFont(to: buttonPayNow, isTitle: true)
//        Common.setFont(to: labelTotal, isTitle: true, size: 20)
//        Common.setFont(to: labelTotalString, isTitle: true, size: 20)
//        Common.setFont(to: labelToPay, isTitle: true, size: 20)
//        Common.setFont(to: labelToPayString, isTitle: true, size: 20)
//        Common.setFont(to: labelDiscount)
//        Common.setFont(to: labelDiscountString)
//        Common.setFont(to: labelBooking)
//        Common.setFont(to: labelBookingString)
//        Common.setFont(to: labelBaseFare)
//        Common.setFont(to: labelBaseFareString)
//        Common.setFont(to: labelDistanceFare)
//        Common.setFont(to: labelDistanceFareString)
//        Common.setFont(to: labelTimeFare)
//        Common.setFont(to: labelTimeFareString)
//        Common.setFont(to: labelTimeTaken)
//        Common.setFont(to: labelTimeTakenString)
//        Common.setFont(to: labelDistanceTravelled)
//        Common.setFont(to: labelDistanceTravelledString)
//        Common.setFont(to: labelTax)
//        Common.setFont(to: labelTaxString)
//        Common.setFont(to: labelTipsString)
//        Common.setFont(to: labelWallet)
//        Common.setFont(to: labelWalletString)
//        Common.setFont(to: labelPaymentType)
//        Common.setFont(to: buttonChangePayment)
    }
    
    
    
    // MARK:- Localize
    
    private func localize() {
        
        self.labelBookingString.text = Constants.string.bookingId.localize()
        self.labelDistanceTravelledString.text = Constants.string.distanceFare.localize()
        // time taken chnage to waitingCharges
        self.labelTimeTakenString.text = Constants.string.waitingCharges.localize()
        self.labelBaseFareString.text = Constants.string.baseFare.localize()
        self.labelDistanceFareString.text = Constants.string.adminFees.localize()
        self.labelTimeFareString.text = Constants.string.timeFare.localize()
        self.labelTaxString.text = Constants.string.tax.localize()
        self.labelTipsString.text = Constants.string.tips.localize()
        self.buttonTips.setTitle(Constants.string.addTips.localize(), for: .normal)
        self.labelTotalString.text = Constants.string.total.localize()
        self.labelWalletString.text = Constants.string.walletDeduction.localize()
        self.labelDiscountString.text = Constants.string.discount.localize()
        self.labelTitle.text = Constants.string.invoice.localize()
        
    }
    
    func set(request : Request) {
        
        self.requestId = request.id ?? 0
        
        if let userLocation = userCurrentLocation, userLocation.isPakistan{
            self.buttonChangePayment.isHidden = true
            self.paymentChangeIconView.isHidden = true
            self.labelPaymentType.isHidden = true
        }
        func setAmount(to label : UILabel, with amount : Float?) {
            label.text = "\(String.removeNil(User.main.currency)) \(Formatter.shared.limit(string: "\(Float.removeNil(amount))", maximumDecimal: 2))"
        }
        let isRoundTrip =  request.is_round == 1
        let calculation_format = request.service?.calculation_format
        
        self.labelBooking.text = request.booking_id
        if let payment = request.payment{
            let distanceTravelledFare = isRoundTrip ? ((payment.distanceTravelledFare) * 2) : payment.distanceTravelledFare
            let distanceFare:Float = payment.isFlatRate  ? distanceTravelledFare : payment.distance ?? 0.0
            setAmount(to: self.labelDistanceTravelled, with: distanceFare)
        }else{
            setAmount(to: self.labelDistanceTravelled, with:  request.payment?.distance ?? 0.0)
        }
       
        setAmount(to: self.labelTimeTaken, with: Float(request.payment?.waiting_charges ?? 0.0))
        
        if calculation_format == "TYPEC"{
            let baseFare = isRoundTrip ? ((request.payment?.fixed ?? 0.00)) : request.payment?.fixed
            setAmount(to: self.labelBaseFare, with: baseFare)
            self.labelDistanceFareString.isHidden = true
        }else{
            let baseFare = isRoundTrip ? ((request.payment?.fixed ?? 0.00)) : request.payment?.fixed
            setAmount(to: self.labelBaseFare, with: baseFare)
        }
        
//        let commision = isRoundTrip ? ((request.payment?.commision ?? 0.00) * 2) : request.payment?.commision
        let tax = isRoundTrip ? ((request.payment?.tax ?? 0.00) * 2) : request.payment?.tax
//        setAmount(to: self.labelDistanceFare, with: commision)
        setAmount(to: self.labelTax, with: tax)
        /////
        ///
        ///
        
        
        self.labelDistanceFare.text = "\(User.main.currency ?? "$") \(Formatter.shared.limit(string: "\(request.payment?.admin_fee ?? 0.0)", maximumDecimal: 2))"
        
        
        
//        self.labelDistanceFare.text = "Test Value"
        print("calculation_format>>>>>>>",calculation_format as Any)
        if (isShowingRecipt || request.paid == 1) {
            self.buttonPayNow.setTitle(Constants.string.Done.localize(), for: .normal)
        }else{
            self.buttonPayNow.setTitle(Constants.string.paynow.localize(), for: .normal)
        }

        self.labelToPayString.text = (isShowingRecipt ? Constants.string.paid : Constants.string.toPay).localize()
        
        

        print(request)
        pickedupAddressLabel.text = request.s_address
        
        if request.stops?.count == 1{
            stop1Label.text = request.stops?[0].d_address ?? ""
        }else if request.stops?.count == 2{
            stop1Label.text = request.stops?[1].d_address ?? ""
        }else if request.stops?.count == 3{
            stop1Label.text = request.stops?[2].d_address ?? ""
        }
        
        print(request.payment_mode)
        self.paymentType = request.payment_mode ?? .NONE
        self.serviceCalculator = request.service?.calculator ?? .NONE
        self.isUsingWallet = (request.payment?.wallet ?? 0)>0
        self.isDiscountApplied = (request.payment?.discount ?? 0)>0
        
        let timeFare : Float = {
            if [ServiceCalculator.MIN, .DISTANCEMIN].contains(self.serviceCalculator) {
                return request.payment?.minute ?? 0
            } else if [ServiceCalculator.HOUR, .DISTANCEHOUR].contains(self.serviceCalculator) {
                return request.payment?.minute ?? 0
            }
            return 0
        }()
        
        setAmount(to: self.labelTimeFare, with: timeFare)
        
        setAmount(to: self.labelWallet, with: request.payment?.wallet)
        setAmount(to: self.labelDiscount, with: request.payment?.discount)
        self.total = (request.payment?.isFlatRate ?? false) ? request.payment?.flat_rate?.float ?? 0:(request.payment?.total ?? 0)
        if self.tipsAmount == 0 {
            self.tipsAmount = request.payment?.tips ?? 0
        }
        if self.isShowingRecipt { // On recipt page
            self.payyable = self.total-((request.payment?.discount ?? 0)+(request.payment?.wallet ?? 0))
        } else { // On Invoice page
            self.payyable = request.payment?.payable ?? 0
        }
        if (request.payment_mode == .CASH && !isShowingRecipt) && (request.paid == 0){
            self.labelPaymentType.isHidden = false
            
        }else if (request.payment_mode == .CAC && !isShowingRecipt) && (request.paid == 0){
            self.labelPaymentType.isHidden = false
            
        }else{
            
        }
        if (request.paid == 1){
            self.labelPaymentType.isHidden = true
            self.buttonChangePayment.isHidden = true
            self.paymentChangeIconView.isHidden = true
            
        }
        self.viewTips.isHidden = request.payment_mode == .CASH

        self.viewTimeFare.isHidden = timeFare == 0
        
    }
    
    private func updatePayment() {
        self.buttonTips.setTitle((tipsAmount>0 || self.isShowingRecipt) ? " \(String.removeNil(User.main.currency)) \(Formatter.shared.limit(string: "\(tipsAmount)", maximumDecimal: 2)) " : " \(Constants.string.addTips.localize()) ", for: .normal)
        self.labelTotal.text = "\(String.removeNil(User.main.currency)) \(Formatter.shared.limit(string: "\(tipsAmount+total)", maximumDecimal: 2))"
        self.labelToPay.text = "\(String.removeNil(User.main.currency)) \(Formatter.shared.limit(string: "\(tipsAmount+payyable)", maximumDecimal: 2))"
    }
    
    @IBAction private func buttonPaynowAction() {
        if buttonPayNow.titleLabel?.text == Constants.string.Done{
            self.onDoneClick?(true)
        }else{
            self.onClickPaynow?(self.tipsAmount)
        }
    }
    
    // MARK:- Change Payment Type
    @IBAction private func buttonChangePaymentAction() {
        self.onClickChangePayment?({ [weak self] card in
            self?.selectedCard = card
        })
    }
    
    
    @IBAction private func buttonTipsAction(sender : UIButton){
        
        self.buttonTips.layer.removeAllAnimations()
        self.buttonTips.alpha = 1.0
        
        if self.viewTipsXib == nil {
            self.viewTipsXib = ViewTips(frame: .zero)
            self.viewTipsXib?.alpha = 0
            self.viewTipsXib?.backgroundColor = .white
            self.viewTipsXib?.addBackgroundView(in: self, gesture: UITapGestureRecognizer(target: self, action: #selector(self.dismissTipsView)))
            self.addSubview(self.viewTipsXib!)
            UIView.animate(withDuration: 0.5) {
                self.viewTipsXib?.alpha = 1
            }
            self.viewTipsXib?.translatesAutoresizingMaskIntoConstraints = false
            self.viewTipsXib?.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0 ).isActive = true
            self.viewTipsXib?.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0 ).isActive = true
            self.viewTipsXib?.heightAnchor.constraint(equalToConstant: 150).isActive = true
            self.viewTipsXib?.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true
            self.viewTipsXib?.tipsAmount = tipsAmount
            self.viewTipsXib?.onClickSubmit = { value in
                self.tipsAmount = value
                self.dismissTipsView()
                
                var data = TipModel()
                data.request_id = self.requestId
                data.tip = value
                
                self.presenter?.post(api: .addTip, data: data.toData())
            }
        }
        self.viewTipsXib?.total = self.total
    }
    
    @IBAction private func dismissTipsView() {
        self.removeBackgroundView()
        UIView.animate(withDuration: 0.5, animations: {
            self.viewTipsXib?.alpha = 0
        }) { (_) in
            self.viewTipsXib?.removeFromSuperview()
            self.viewTipsXib = nil
        }
    }
    
}



extension InvoiceView : PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
      
        DispatchQueue.main.async {
            if let viewController = UIApplication.topViewController() {
                showAlert(message: message, okHandler: nil, fromView: viewController)
            }
        }
    }
    
//    func getLocationService(api: Base, data: LocationService?) {
//
//        storeFavouriteLocations(from: data)
//
//    }
    
    
    func addTipValueDriver(api: Base, data: TipModel?) {
        
        
        
    }
    
    
    func success(api: Base, message: String?) {
        
        if api == .locationServicePostDelete {
            self.presenter?.get(api: .locationService, parameters: nil)
        }
        
    }
    
    
}
