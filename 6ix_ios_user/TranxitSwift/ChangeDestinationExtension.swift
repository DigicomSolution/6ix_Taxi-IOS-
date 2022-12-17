//
//  ChangeDestinationExtension.swift
//  TranxitUser
//
//  Created by Hexacrew on 15/04/2020.
//  Copyright © 2020 Appoets. All rights reserved.
//

import Foundation


//
//  ChangeDestinationViewController+Extension.swift
//  User
//
//  Created by CSS on 16/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation
import UIKit
import Lottie
import GoogleMaps
import PopupDialog


extension ChangeDestinationViewController {
    
    
    // MARK:- Show Ride Now View
    
    func showRideNowView(with source : [Service]) {
        guard let sourceLocation = self.sourceLocationDetail?.value, let destinationLocation = self.destinationLocationDetail else { return }
        // print("\nselected--**",self.sourceLocationDetail?.value?.coordinate, self.destinationLocationDetail?.coordinate)
        
        //        var selectedPaymentDetail : CardEntity?
        //        var paymentType : PaymentType = (User.main.isCashAllowed ? .CASH : User.main.isCardAllowed ? .CARD : .NONE)
        if self.rideNowView == nil {
            
            self.rideNowView = Bundle.main.loadNibNamed(XIB.Names.RideNowView, owner: self, options: [:])?.first as? RideNowView
            self.rideNowView?.frame = CGRect(origin: CGPoint(x: 0, y: self.view.frame.height-self.rideNowView!.frame.height), size: CGSize(width: self.view.frame.width, height: self.rideNowView!.frame.height))
            self.rideNowView?.clipsToBounds = false
            self.rideNowView?.show(with: .bottom, completion: nil)
            self.view.addSubview(self.rideNowView!)
            self.isOnBooking = true
            self.rideNowView?.onClickProceed = { [weak self] service in
                self?.showEstimationView(with: service)
            }
            self.rideNowView?.onClickService = { [weak self] service in
                guard let self = self else {return}
                self.sourceMarker.snippet = service?.pricing?.time
                self.mapViewHelper?.mapView?.selectedMarker = (service?.pricing?.time) == nil ? nil : self.sourceMarker
            }
            //self.rideNowView?.imageViewCard.image = paymentType.image
            //            self.rideNowView?.onClickRideNow = { service in
            //                if service != nil {
            //                    self.createRequest(for: service!, isScheduled: false, scheduleDate: nil, cardEntity: selectedPaymentDetail, paymentType: paymentType)
            //                }
            //            }
            //            self.rideNowView?.onClickSchedule = { service in
            //                self.schedulePickerView(on: { (date) in
            //                    if service != nil {
            //                        self.createRequest(for: service!, isScheduled: true, scheduleDate: date,cardEntity: selectedPaymentDetail, paymentType: paymentType)
            //                    }
            //                })
            //            }
            //            self.rideNowView?.onClickChangePayment = {
            //                if let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.PaymentViewController) as? PaymentViewController{
            //                    vc.isChangingPayment = true
            //                    vc.onclickPayment = { (paymentTypeEntity , cardEntity) in
            //                        selectedPaymentDetail = cardEntity
            //                        paymentType = paymentTypeEntity
            //                        self.rideNowView?.imageViewCard.image = paymentType.image
            //                        self.rideNowView?.labelCardNumber.text = cardEntity == nil ? Constants.string.cash.localize() : String.removeNil(cardEntity?.last_four)
            //                    }
            //                    let navigation = UINavigationController(rootViewController: vc)
            //                    self.present(navigation, animated: true, completion: nil)
            //                }
            //            }
        }
        self.rideNowView?.setAddress(source: sourceLocation.coordinate, destination: destinationLocation.coordinate,position: nil)
        self.rideNowView?.set(source: source)
    }
    
    // MARK:- Remove RideNowView
    
    func removeRideNow() {
        
        self.isOnBooking = false
        self.rideNowView?.dismissView(onCompletion: {
            self.mapViewHelper?.mapView?.selectedMarker = nil
        })
        self.rideNowView = nil
    }
    
    
    /*   // MARK:- Show Service View
     
     func showServiceSelectionView(with source : [Service]) {
     
     
     if self.serviceSelectionView == nil {
     
     self.serviceSelectionView = Bundle.main.loadNibNamed(XIB.Names.ServiceSelectionView, owner: self, options: [:])?.first as? ServiceSelectionView
     self.serviceSelectionView?.frame = CGRect(origin: CGPoint(x: 0, y: self.view.frame.height-self.serviceSelectionView!.frame.height), size: CGSize(width: self.view.frame.width, height: self.serviceSelectionView!.frame.height))
     self.serviceSelectionView?.buttonMore.addTarget(self, action: #selector(self.buttonMoreServiceAction(sender:)), for: .touchUpInside)
     self.serviceSelectionView?.buttonService.addTarget(self, action: #selector(self.buttonMoreServiceAction(sender:)), for: .touchUpInside)
     self.serviceSelectionView?.show(with: .bottom, completion: nil)
     self.view.addSubview(self.serviceSelectionView!)
     self.isOnBooking = true
     if let source = self.sourceLocationDetail?.value?.coordinate, let destination = self.destinationLocationDetail?.coordinate {
     self.serviceSelectionView?.setAddress(source: source, destination: destination)
     }
     self.serviceSelectionView?.onClickPricing = { selectedItem in
     if let id = selectedItem?.id {
     self.loader.isHidden = false
     self.service = selectedItem
     self.getEstimateFareFor(serviceId: id)
     }
     }
     self.serviceSelectionView?.clipsToBounds = false
     }
     
     self.serviceSelectionView?.set(source: source)
     }
     
     // MARK:- Service View Button More and Service Action
     
     @IBAction private func buttonMoreServiceAction(sender : UIButton) {
     
     self.serviceSelectionView?.isServiceSelected = sender == self.serviceSelectionView?.buttonService
     
     }
     
     // MARK:- Remove Service View
     
     func removeServiceView() {
     
     self.isOnBooking = false
     self.serviceSelectionView?.dismissView(onCompletion: {
     self.serviceSelectionView = nil
     })
     
     } */
    
    // MARK:- Temporarily Hide Service View
    
    func isMapInteracted(_ isHide : Bool){
        
        UIView.animate(withDuration: 0.2) {
            
            
            self.rideStatusView?.frame.origin.y = (self.view.frame.height-(isHide ? 0 : self.rideStatusView?.frame.height ?? 0))
            self.invoiceView?.frame.origin.y = (self.view.frame.height-(isHide ? 0 : self.invoiceView?.frame.height ?? 0))
            //self.ratingView?.frame.origin.y = (self.view.frame.height-(isHide ? 0 : self.ratingView?.frame.height ?? 0))
            self.rideNowView?.frame.origin.y = (self.view.frame.height-(isHide ? 0 : self.rideNowView?.frame.height ?? 0))
            self.estimationFareView?.frame.origin.y = (self.view.frame.height-(isHide ? 0 : self.estimationFareView?.frame.height ?? 0))
            self.couponView?.frame.origin.y = (self.view.frame.height-(isHide ? 0 : self.couponView?.frame.height ?? 0))
            
            self.couponView?.alpha = isHide ? 0 : 1
            self.viewAddressOuter.alpha = isHide ? 0 : 1
            //  self.viewLocationButtons.alpha = isHide ? 0 : 1
            self.estimationFareView?.alpha = isHide ? 0 : 1
            self.rideStatusView?.alpha = isHide ? 0 : 1
            self.invoiceView?.alpha = isHide ? 0 : 1
            self.ratingView?.alpha = isHide ? 0 : 1
            self.rideNowView?.alpha = isHide ? 0 : 1
            self.floatyButton?.alpha = isHide ? 0 : 1
            self.reasonView?.alpha = isHide ? 0 : 1
            //  self.buttonSOS.alpha = isHide ? 0 : 1
        }
        
    }
    
    
    // MARK:- Show Ride Now view
    
    func showEstimationView(with service : Service){
        
        self.removeRideNow()
        self.isOnBooking = true
        if self.estimationFareView == nil {
            print("ViewAddressOuter ", #function)
            var selectedPaymentDetail : CardEntity?
            var paymentType : PaymentType = (User.main.isCashAllowed ? .CASH : User.main.isCardAllowed ? .CARD : .NONE)
            self.loader.isHidden = true
            let isWalletAvailable = User.main.wallet_balance != 0
            let heightPadding : CGFloat = (isWalletAvailable ? 0 : 40)
            self.estimationFareView = Bundle.main.loadNibNamed(XIB.Names.RequestSelectionView, owner: self, options: [:])?.first as? RequestSelectionView
            self.estimationFareView?.frame = CGRect(x: 0, y: self.view.frame.height-(self.estimationFareView!.bounds.height-heightPadding), width: self.view.frame.width, height: self.estimationFareView!.frame.height-heightPadding)
            self.estimationFareView?.show(with: .bottom, completion: nil)
            self.view.addSubview(self.estimationFareView!)
            self.estimationFareView?.scheduleAction = { [weak self] service in
                self?.schedulePickerView(on: { (date) in
                    self?.createRequest(for: service, isScheduled: true, scheduleDate: date,cardEntity: selectedPaymentDetail, paymentType: paymentType)
                })
            }
            self.estimationFareView?.rideNowAction = { [weak self] service in
                self?.createRequest(for: service, isScheduled: false, scheduleDate: nil, cardEntity: selectedPaymentDetail, paymentType: paymentType)
            }
            
            self.estimationFareView?.rideotp = { [weak self] service in
                self!.view.addBlurview { blurView in
                    //                self.hideSimmerButton()
                    
                    
                    self!.OTPScreen = Bundle.main.loadNibNamed(XIB.Names.OTPScreenView, owner: self, options: nil)?.first as? OTPScreenView
                    self?.OTPScreen?.EnterOTP.text = Constants.string.EnterPin
                    
                    
                    
                    
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self?.handleTap))
                    tap.cancelsTouchesInView = false
                    
                    self?.view.addGestureRecognizer(tap)
                    self?.view.isUserInteractionEnabled = true
                    
                    
                    
                    
                    
                    //                if !(self?.OTPScreen != nil) != nil{
                    //                     self?.OTPScreen?.removeFromSuperview()
                    //                }else{
                    //                    print("remove otp scree")
                    //                    self?.dismiss(animated: true, completion: nil)
                    //                }
                    
                    
                    // This is not required
                    // self?.OTPScreen?.addGestureRecognizer(tap)
                    self!.OTPScreen?.frame = CGRect(x: 0, y: self!.view.frame.height / 3, width: self!.view.frame.width, height: 200)
                    blurView?.contentView.addSubview(self!.OTPScreen!)
                    //                blurView?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.otpScreenPanGesture(sender:))))
                    
                    self!.OTPScreen?.onClickOtp = {
                        self?.view.removeBlurView()
                        self?.createRequest(for: service, isScheduled: false, scheduleDate: nil, cardEntity: selectedPaymentDetail, paymentType: paymentType)
                        
                    }
                    //                self.OTPScreen?.set(number: self!.userOtp ?? "0", with: { (status) in
                    //
                    //                    //                                                if status{
                    //                    //                                                    self.LoadUpdateStatusAPI(status: Constants.string.pickedUp)
                    //                    //                                                    self.statusChanged(status: requestType.pickedUp.rawValue)
                    //                    //                                                }else {
                    //                    //
                    //                    //                                                }
                    //                })
                }            //
                //
                //            self?.createRequest(for: service, isScheduled: false, scheduleDate: nil, cardEntity: selectedPaymentDetail, paymentType: paymentType)
            }
            
            
            self.estimationFareView?.paymentChangeClick = { [weak self]  completion in
                if let vc = self?.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.PaymentViewController) as? PaymentViewController {
                    vc.isChangingPayment = true
                    vc.paymentTypeStr = paymentType.rawValue
                    vc.onclickPayment = { [weak self] (paymentTypeEntity , cardEntity) in
                        guard let self = self else {return}
                        selectedPaymentDetail = cardEntity
                        paymentType = paymentTypeEntity
                        completion(cardEntity)
                        self.estimationFareView?.paymentType = paymentType
                    }
                    let navigation = UINavigationController(rootViewController: vc)
                    self?.present(navigation, animated: true, completion: nil)
                }
            }
            self.estimationFareView?.onclickCoupon = { [weak self] (availableCoupons,selected, completion) in // available coupons, currently selected coupons, completion to send response
                self?.showCouponView(coupons: availableCoupons, currentlySelected: selected, completion: { (couponEntity) in
                    completion?(couponEntity) // sending back the couponEntity
                    self?.removeCouponView()
                })
            }
        }
        self.estimationFareView?.setValues(values: service)
    }
    
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        // handling code
        
        print("tap>>>>>",sender?.view)
        sender?.view?.removeBlurView()
        //        if sender?.view !== self.OTPScreen {
        //            dismiss(animated: true, completion: nil)
        //        }
        //
        //        if self.OTPScreen?.mainView != self.OTPScreen {
        //            self.OTPScreen?.isHidden = true
        //        }
        
    }
    
    // MARK:- Remove RideNow View
    
    func removeEstimationFareView(){
        
        self.estimationFareView?.dismissView(onCompletion: {
            self.isOnBooking = false
            self.loader.isHidden = true
            self.isOnBooking = false
        })
        self.estimationFareView = nil
    }
    
    
    // MARK:- Show Coupon View
    
    func showCouponView(coupons: [PromocodeEntity],currentlySelected selected : PromocodeEntity?,completion : @escaping ((PromocodeEntity?)->Void)) {
        
        if self.couponView == nil, let couponViewObject = Bundle.main.loadNibNamed(XIB.Names.CouponView, owner: self, options: [:])?.first as? CouponView {
            couponViewObject.frame = CGRect(origin: CGPoint(x: 0, y: self.view.frame.height-couponViewObject.frame.height), size: CGSize(width: self.view.frame.width, height: couponViewObject.frame.height))
            couponView = couponViewObject
            self.view.addBackgroundView(in: self.view, gesture: UITapGestureRecognizer(target: self, action: #selector(self.removeCouponView)))
            self.couponView?.applyCouponAction = { coupon in
                completion(coupon)
            }
            couponView?.show(with: .bottom, completion: nil)
            self.view.addSubview(couponView!)
            self.couponView?.set(values: coupons, selected: selected)
        }
        
    }
    
    // MARK:- Remove CouponView
    
    @IBAction private func removeCouponView() {
        self.view.removeBackgroundView()
        self.couponView?.dismissView(onCompletion: {
            self.couponView = nil
        })
    }
    
    
    
    // MARK:- Show RideStatus View
    
    func showRideStatusView(with request : Request) {
        
        self.removeRideNow()
        self.viewAddressOuter.isHidden = true
        //  self.viewLocationButtons.isHidden = true
        self.loader.isHidden = true
        print("ViewAddressOuter ", #function, !(request.status == .pickedup))
        if self.rideStatusView == nil, let rideStatus = Bundle.main.loadNibNamed(XIB.Names.RideStatusView, owner: self, options: [:])?.first as? RideStatusView {
            rideStatus.frame = CGRect(origin: CGPoint(x: 0, y: self.view.frame.height-rideStatus.frame.height), size: CGSize(width: self.view.frame.width, height: rideStatus.frame.height))
            rideStatusView = rideStatus
            self.view.addSubview(rideStatus)
            self.addFloatingButton(with: rideStatus.frame.height, to: request.provider)
            rideStatus.show(with: .bottom, completion: nil)
        }
        // Change Provider Location
        //        if let latitude = request.provider?.latitude, let longitude = request.provider?.longitude {
        self.getDataFromFirebase(providerID: (request.provider?.id)!)
        //            self.moveProviderMarker(to: LocationCoordinate(latitude: latitude, longitude: longitude))
        //        }
        //  self.buttonSOS.isHidden = !(request.status == .pickedup)
        self.floatyButton?.isHidden = request.status == .pickedup
        rideStatusView?.set(values: request)
        rideStatusView?.onClickCancel = {
            self.cancelCurrentRide(isSendReason: true)
        }
        rideStatusView?.onClickShare = {
            self.shareRide()
        }
        
    }
    
    
    // MARK:- Remove RideStatus View
    
    func removeRideStatusView() {
        //  self.buttonSOS.isHidden = !(riderStatus == .pickedup)
        self.rideStatusView?.dismissView(onCompletion: {
            self.rideStatusView = nil
        })
        
    }
    
    
    // MARK:- Show Invoice View
    
    func showInvoiceView(with request : Request) {
        isRateViewShowed = false
        self.isInvoiceShowed = true
        //   self.buttonSOS.isHidden = !(riderStatus == .pickedup)
        self.mapViewHelper?.mapView?.clear()
        if self.invoiceView == nil, let invoice = Bundle.main.loadNibNamed(XIB.Names.InvoiceView, owner: self, options: [:])?.first as? InvoiceView {
            self.viewAddressOuter.isHidden = true
            //  self.viewLocationButtons.isHidden = true
            print("ViewAddressOuter ", #function)
            invoice.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.width, height: self.view.frame.height))
            invoiceView = invoice
            self.view.addSubview(invoiceView!)
            invoiceView?.show(with: .bottom, completion: nil)
            
            self.invoiceView?.onClickPaynow = { tipsAmount in
                print("Called",#function)
                self.isInvoiceShowed = true
                self.loader.isHidden = false
                let requestObj = Request()
                requestObj.request_id = request.id
                if tipsAmount>0 {
                    requestObj.tips = (Float(Int(tipsAmount*100))/100)
                }
                self.presenter?.post(api: .payNow, data: requestObj.toData())
            }
            self.invoiceView?.onDoneClick = { onClick in
                self.showRatingView(with: request)
            }
            self.invoiceView?.onClickChangePayment = { [weak self] completion in
                print("Called",#function)
                guard let self = self else {return}
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.PaymentViewController) as? PaymentViewController{
                    vc.isChangingPayment = true
                    vc.isShowCash = false
                    vc.onclickPayment = { (paymentTypeEntity , cardEntity) in
                        if paymentTypeEntity == .CARD, cardEntity != nil {
                            completion(cardEntity!)
                            self.updatePaymentType(with: cardEntity!)
                        }else if paymentTypeEntity == .CAC{
                            
                            
                        }
                    }
                    let navigation = UINavigationController(rootViewController: vc)
                    self.present(navigation, animated: true, completion: nil)
                }
            }
        }
        
        self.invoiceView?.set(request: request)
        
    }
    
    
    // MARK:- Remove RideStatus View
    
    func removeInvoiceView() {
        // self.buttonSOS.isHidden = !(riderStatus == .pickedup)
        self.invoiceView?.dismissView(onCompletion: {
            self.invoiceView = nil
            riderStatus = .none
        })
    }
    
    
    // MARK:- Show RideStatus View
    
    func showRatingView(with request : Request) {
        
        guard self.ratingView == nil else {
            print("return")
            return
        }
        self.removeInvoiceView()
        isRateViewShowed = true
        if let rating = Bundle.main.loadNibNamed(XIB.Names.RatingView, owner: self, options: [:])?.first as? RatingView {
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShowRateView(info:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHideRateView(info:)), name: UIResponder.keyboardWillHideNotification, object: nil)
            self.viewAddressOuter.isHidden = true
            //     self.viewLocationButtons.isHidden = true
            rating.frame = CGRect(origin: CGPoint(x: 0, y: self.view.frame.height-rating.frame.height), size: CGSize(width: self.view.frame.width, height: rating.frame.height))
            ratingView = rating
            self.view.addSubview(ratingView!)
            ratingView?.show(with: .bottom, completion: nil)
        }
        ratingView?.set(request: request)
        ratingView?.onclickRating = { (rating, comments) in
            if self.currentRequestId > 0 {
                var rate = Rate()
                rate.request_id = self.currentRequestId
                rate.rating = rating
                if comments == Constants.string.writeYourComments {
                    rate.comment = ""
                }else{
                    rate.comment = comments
                }
                self.presenter?.post(api: .rateProvider, data: rate.toData())
            }
            self.removeRatingView()
        }
    }
    
    
    // MARK:- Remove RideStatus View
    
    func removeRatingView() {
        Store.review() // Getting Appstore review from user
        self.ratingView?.dismissView(onCompletion: {
            self.ratingView = nil
            self.viewAddressOuter.isHidden = false
            //  self.viewLocationButtons.isHidden = false
            self.clearMapview()
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        })
    }
    
    //MARK:- Keyboard will show
    
    @IBAction func keyboardWillShowRateView(info : NSNotification){
        
        guard let keyboard = (info.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{
            return
        }
        self.ratingView?.frame.origin.y =  keyboard.origin.y-(self.ratingView?.frame.height ?? 0 )
    }
    
    
    //MARK:- Keyboard will hide
    
    @IBAction func keyboardWillHideRateView(info : NSNotification){
        
        guard let keyboard = (info.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{
            return
        }
        self.ratingView?.frame.origin.y += keyboard.size.height
        
    }
    
    
    // MARK:- Show Providers In Current Location
    
    func showProviderInCurrentLocation(with data : [Service]) {
        
        self.markersProviders.forEach({ $0.map = nil })
        self.markersProviders.removeAll()
        
        for locationData in data where locationData.longitude != nil && locationData.latitude != nil {
            
            //            let lottieView = LottieView(name: "suv")
            //            lottieView.frame = CGRect(origin: .zero, size: CGSize(width: 50, height: 50))
            //            lottieView.loopAnimation = true;
            //            lottieView.play()
            
            let marker = GMSMarker(position: CLLocationCoordinate2DMake(locationData.latitude!, locationData.longitude!))
            marker.icon = #imageLiteral(resourceName: "map-vehicle-icon-black").resizeImage(newWidth: 20)
            marker.groundAnchor = CGPoint(x: 0.5, y: 1)
            marker.map = mapViewHelper?.mapView
            self.markersProviders.append(marker)
            
        }
        
    }
    
    // MARK:- Show Loader View
    
    func showLoaderView(with requestId : Int? = nil) {
        
        if self.requestLoaderView == nil, let singleView = Bundle.main.loadNibNamed(XIB.Names.LoaderView, owner: self, options: [:])?.first as? LoaderView {
            self.isOnBooking = true
            singleView.frame = self.viewMapOuter.bounds
            self.requestLoaderView = singleView
            self.requestLoaderView?.onCancel = {
                self.cancelCurrentRide()
            }
            self.view.addSubview(singleView)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) { // Hiding Address View
                UIView.animate(withDuration: 0.5, animations: {
                    self.viewAddressOuter.isHidden = false
                    //      self.viewLocationButtons.isHidden = true
                    print("ViewAddressOuter ", #function)
                })
            }
        }
        self.requestLoaderView?.isCancelButtonEnabled = requestId != nil
    }
    
    // MARK:- Remove Loader View
    
    func removeLoaderView() {
        
        self.requestLoaderView?.endLoader {
            self.requestLoaderView = nil
            self.viewAddressOuter.isHidden = false
            //   self.viewLocationButtons.isHidden = false
            print("ViewAddressOuter ", #function)
        }
    }
    
    // MARK:- Show Cancel Reason View
    
    private func showCancelReasonView(completion : @escaping ((String)->Void)) {
        
        if self.reasonView == nil, let reasonView = Bundle.main.loadNibNamed(XIB.Names.ReasonView, owner: self, options: [:])?.first as? ReasonView {
            reasonView.frame = CGRect(x: 16, y: 50, width: self.view.frame.width-32, height: reasonView.frame.height)
            self.reasonView = reasonView
            self.reasonView?.didSelectReason = { cancelReason in
                completion(cancelReason)
            }
            self.view.addSubview(reasonView)
            self.reasonView?.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: CGFloat(0.5),
                           initialSpringVelocity: CGFloat(1.0),
                           options: .allowUserInteraction,
                           animations: {
                self.reasonView?.transform = .identity },
                           completion: { Void in()  })
        }
        
    }
    
    // MARK:- Remove Cancel View
    
    private func removeCancelView() {
        UIView.animate(withDuration: 0.3,
                       animations: {
            self.reasonView?.transform = CGAffineTransform(scaleX: 0.0000001, y: 0000001)
        }) { (_) in
            self.reasonView?.removeFromSuperview()
            self.reasonView = nil
        }
        
        /*(withDuration: 1.0,
         delay: 0,
         usingSpringWithDamping: CGFloat(0.2),
         initialSpringVelocity: CGFloat(2.0),
         options: .allowUserInteraction,
         animations: {
         self.reasonView?.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
         },
         completion: { Void in()
         self.reasonView?.removeFromSuperview()
         self.reasonView = nil
         }) */
    }
    
    
    
    // MARK:- Clear Map View
    
    func clearMapview() {
        
        self.mapViewHelper?.mapView?.clear()
        self.destinationLocationDetail = nil
        self.viewAddressOuter.isHidden = false
        //  self.viewLocationButtons.isHidden = false
        self.resetAll()
    }
    
    // MARK:- Handle Request Data
    
    func handle(request : Request) {
        
        let stat = request.status
        print("stat>>>>>",stat as Any)
        
        //        UserDefaults.standard.set(request.status, forKey: "status")
        //        let currentstaus = UserDefaults.standard.value(forKey: "status")
        //        print("currentstaus>>>",currentstaus as Any)
        
        guard let status = request.status, request.id != nil else { return }
        
        //        if status == .dropped{
        //              self.currentRequestId = request.id!
        //            if let dAddress = request.d_address, let dLatitude = request.d_latitude, let dLongitude = request.d_longitude{
        //                let currentLat =  UserDefaults.standard.double(forKey: "lat")
        //                //  latDouble = Double(currentLat)
        //                print("latitude>>>>>>>>",currentLat)
        //
        //                let currentLong =  UserDefaults.standard.double(forKey: "long")
        //                //  longDouble = Double(currentLat)
        //                print("currentLong>>>>>",currentLong)
        //
        //                DispatchQueue.main.async {
        //                    self.drawPolyline(isReroute: false)
        //                }
        //
        //            }
        //
        //        }else{
        
        //        DispatchQueue.global(qos: .default).async {
        //
        //            self.currentRequestId = request.id!
        //            if let dAddress = request.d_address, let dLatitude = request.d_latitude, let dLongitude = request.d_longitude, let sAddress = request.s_address, let sLattitude = request.s_latitude, let sLongitude = request.s_longitude {
        //                self.destinationLocationDetail = LocationDetail(dAddress, LocationCoordinate(latitude: dLatitude, longitude: dLongitude))
        //                self.sourceLocationDetail?.value = LocationDetail(sAddress,LocationCoordinate(latitude: sLattitude, longitude: sLongitude))
        //
        //                DispatchQueue.main.async {
        //                    self.drawPolyline(isReroute: false)
        //                }
        //            }
        //
        //        }
        
        
        switch status{
            
        case .searching:
            self.showLoaderView(with: self.currentRequestId)
            self.perform(#selector(self.validateRequest), with: self, afterDelay: requestInterval)
        case .accepted, .arrived, .started, .pickedup:
            self.showRideStatusView(with: request)
            
        case .dropped:
            
            //            mapViewHelper?.getCurrentLocation(onReceivingLocation: { (location) in
            //                self.mapViewHelper?.moveTo(location: LocationCoordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), with: self.viewMapOuter.center)
            //            })
            //
            
            if let payment = request.payment
            {
                if let total = payment.total
                {
                    if (total != 0)
                    {
                        
                        self.showInvoiceView(with: request)
                        riderStatus = .none
                    }
                    else
                        
                    {
                        riderStatus = .none
                    }
                    
                }
                else
                {
                    riderStatus = .none
                }
            }
            else
            {
                riderStatus = .none
            }
            
            print("<<- \(request)")
            
        case .completed:
            riderStatus = .none
            if request.payment_mode == .CARD {
                if request.use_wallet == 1 {
                    if request.paid == 0 {
                        self.showInvoiceView(with: request)
                    }else{
                        if isInvoiceShowed {
                            self.showRatingView(with: request)
                        }else{
                            self.showInvoiceView(with: request)
                        }
                    }
                }else{
                    if isInvoiceShowed {
                        self.showRatingView(with: request)
                    }else{
                        self.showInvoiceView(with: request)
                    }
                    //                    if !isRateViewShowed {
                    //                        self.showInvoiceView(with: request)
                    //                    }else{
                    //                        self.showRatingView(with: request)
                    //
                    //                    }
                }
            }else{
                if request.use_wallet == 1 {
                    if request.paid == 0 {
                        self.showInvoiceView(with: request)
                    }else{
                        if isInvoiceShowed  {
                            self.showRatingView(with: request)
                        }else{
                            self.showInvoiceView(with: request)
                        }
                    }
                }else{
                    if isInvoiceShowed {
                        self.showRatingView(with: request)
                    }else{
                        if request.payment_mode == .CASH{
                            self.showInvoiceView(with: request)
                        }else if request.payment_mode == .CARD{
                            self.showInvoiceView(with: request)
                        }else{
                            self.showRatingView(with: request)
                        }
                    }
                }
            }
            /* if request.paid == 1 && (!isRateViewShowed) {
             self.showInvoiceView(with: request)
             //                }else{
             //                    self.showInvoiceView(with: request)
             //                }
             //                self.showRatingView(with: request)
             }else if request.payment_mode == .CASH && (!isRateViewShowed) {
             self.showInvoiceView(with: request)
             }else if request.payment_mode == .CARD && request.paid == 0{
             self.showInvoiceView(with: request)
             }else if request.use_wallet == 1 && request.paid == 1{
             self.showInvoiceView(with: request)
             }else{
             self.showRatingView(with: request)
             }*/
        default:
            break
        }
        
        self.removeUnnecessaryView(with: status)
        
    }
    
    // MARK:- Remove Other Views
    
    func removeUnnecessaryView(with status : RideStatus) {
        
        if ![RideStatus.searching].contains(status) {
            self.removeLoaderView()
        }
        if ![RideStatus.none, .searching].contains(status) {
            self.removeRideNow()
            self.removeEstimationFareView()
        }
        if ![RideStatus.started, .accepted, .arrived, .pickedup].contains(status) {
            self.removeRideStatusView()
        }
        if ![RideStatus.completed].contains(status) {
            self.removeRatingView()
        }
        if ![RideStatus.dropped, .completed].contains(status) {
            self.removeInvoiceView()
        }
        if [RideStatus.none, .cancelled].contains(status) {
            self.currentRequestId = 0 // Remove Current Request
        }
        
    }
    
    
    // MARK:- Share Ride
    func shareRide() {
        if let currentLocation  = currentLocation.value {
            
            let format = "http://maps.google.com/maps?q=loc:\(currentLocation.latitude),\(currentLocation.longitude)"
            let  message = "\(AppName) :- \(String.removeNil(User.main.firstName)) \(String.removeNil(User.main.lastName)) \(Constants.string.wouldLikeToShare) \(format)"
            self.share(items: [#imageLiteral(resourceName: "Splash_icon"), message])
        }
    }
    
    
    // MARK:- Share Items
    
    func share(items : [Any]) {
        
        //        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        //        activityController.setValue("Test", forKey: "Subject")
        //        self.present(activityController, animated: true, completion: nil)
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = self.view
        self.present(activityController, animated: true, completion: nil)
    }
    
    // MARK:- Cancel Current Ride
    
    private func cancelCurrentRide(isSendReason : Bool = false) {
        
        let alert = PopupDialog(title: Constants.string.cancelRequest.localize(), message: Constants.string.cancelRequestDescription.localize())
        let cancelButton =  PopupDialogButton(title: Constants.string.no.localize(), action: {
            alert.dismiss()
        })
        cancelButton.titleColor = .primary
        let sureButton = PopupDialogButton(title: Constants.string.yes.localize()) {
            if isSendReason {
                //                self.showCancelReasonView(completion: { (reason) in  // Getting Cancellation Reason After Providing Accepting Ride
                //                    cancelRide(reason: reason)
                //                    self.removeCancelView()
                //                })
                
                cancelRide()
            } else {
                cancelRide()
            }
        }
        sureButton.titleColor = .red
        alert.addButtons([cancelButton,sureButton])
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
        
        func cancelRide(reason : String? = nil) { // Cancel Ride
            self.loader.isHidden = false
            self.cancelRequest(reason: reason)
            self.removeLoaderView()
            self.clearMapview()
            self.removeRideNow()
            self.removeEstimationFareView()
            self.isOnBooking = false
        }
        
        
    }
    
   
    // MARK:- SOS Action
    
    @IBAction func buttonSOSAction() {
        
        showAlert(message: Constants.string.wouldyouLiketoMakeaSOSCall.localize(), okHandler: {
            Common.call(to: "\(/*User.main.sos ??*/ "911")")
        }, cancelHandler: {
            
        }, fromView: self)
        
    }
    
    // MARK:- Provider Location Marker
    
    func moveProviderMarker(to location : LocationCoordinate) {
        
        if markerProviderLocation.map == nil {
            markerProviderLocation.map = mapViewHelper?.mapView
        }
        let originCoordinate = CGPoint(x: providerLastLocation.latitude-location.latitude, y: providerLastLocation.longitude-location.longitude)
        let tanDegree = atan2(originCoordinate.x, originCoordinate.y)
        CATransaction.begin()
        CATransaction.setAnimationDuration(2)
        markerProviderLocation.position = location
        markerProviderLocation.rotation = CLLocationDegrees(tanDegree*CGFloat.pi/180)
        CATransaction.commit()
        self.providerLastLocation = location
    }
    
    // MARK:- Add Floating Button
    
    private func addFloatingButton(with padding : CGFloat, to provider : Provider?) {
        
        if provider != nil {
            let floaty = Floaty()
            floaty.plusColor = .primary
            floaty.hasShadow = false
            floaty.autoCloseOnTap = true
            floaty.buttonColor = .white
            floaty.buttonImage = #imageLiteral(resourceName: "phoneCall").withRenderingMode(.alwaysTemplate).resizeImage(newWidth: 25)
            floaty.paddingY = padding
            floaty.itemImageColor = .secondary
            floaty.addItem(icon: #imageLiteral(resourceName: "call").resizeImage(newWidth: 25)) { (_) in
                Common.call(to: provider!.mobile)
            }
            floaty.addItem(icon: #imageLiteral(resourceName: "chatIcon").resizeImage(newWidth: 25)) { (_) in
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.SingleChatController) as? SingleChatController {
                    vc.set(user: provider!, requestId: self.currentRequestId)
                    let navigation = UINavigationController(rootViewController: vc)
                    self.present(navigation, animated: true, completion: nil)
                }
            }
            self.floatyButton = floaty
            self.view.addSubview(floaty)
        }
    }
    
    
    //MARK:- Set ETA
    
    func showETA(destinatoin providerLocation : LocationCoordinate, sorce sourceLocation : LocationCoordinate?) {
        
       // guard let sourceLocation = self.sourceLocationDetail?.value else {return}
        
        print("SHOW ETA")
         guard let sourceLocation = sourceLocation else {return}
        self.mapViewHelper?.mapView?.getEstimation(between: CLLocationCoordinate2D(latitude: sourceLocation.latitude, longitude: sourceLocation.longitude), to: providerLocation, completion: { (estimation) in
            DispatchQueue.main.async {
                self.rideStatusView?.setETA(value: estimation)
            }
        })
    }
        
    
    
}

