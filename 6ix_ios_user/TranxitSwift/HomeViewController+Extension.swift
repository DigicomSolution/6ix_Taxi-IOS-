//
//  HomeViewController+Extension.swift
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


extension HomeViewController {
    @IBAction func changeDestinationAction() {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MultiLocationSelectionViewController") as! MultiLocationSelectionViewController
        
        vc.mapViewHelper = mapViewHelper
        vc.delegate = self
        vc.changeDest = true
        if self.positions != nil
        {
            vc.stops = self.stops
        }
        
        
        vc.destinationChanged = {[weak self] (stops,newPositions) in
            
            guard let self = self else {return}
            self.updateStops = stops
            
            
            print("Hello",newPositions)
            
            
            
            
            var positionsUpdaterequest = [Positions]()
            
            
            for position in newPositions{
                
                
                positionsUpdaterequest.append(position)
                
                
                
                
            }
            
            
            self.updatePositions = positionsUpdaterequest
            
            if positionsUpdaterequest.count > 0 {
                
                self.updatingDestination = true
                
                if let service_type_id = self.service_type_id{
                    self.getEstimateFareFor(serviceId: service_type_id, isRoundTrip: 1, waitingMin: self.service?.waiting_minutes ?? 0)
//                    self.getEstimateFareFor(serviceId: service_type_id, isRoundTrip: 1, waitingMin:  0)
                }
                
                //  showes
                print("here I will call a method that will update the request of the ride and ")
            }
            
            
            
            
            
            
            
        }
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    // MARK:- Provider Location Marker
    
    func moveProviderMarker(to location : LocationCoordinate) {
        
        if markerProviderLocation.map == nil {
            markerProviderLocation.map = mapViewHelper.mapView
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
    
    private func addMessageButton(with frame: CGRect, to provider : Provider?) {
        
        if provider != nil {
            providerForMsg = provider
            //            let floaty = Floaty()
            //            floaty.plusColor = .primary
            //            floaty.hasShadow = false
            //            floaty.autoCloseOnTap = true
            //            floaty.buttonColor = .white
            //            floaty.buttonImage = #imageLiteral(resourceName: "phoneCall").withRenderingMode(.alwaysTemplate).resizeImage(newWidth: 25)
            //            floaty.paddingY = padding
            //            floaty.itemImageColor = .secondary
            ////            floaty.addItem(icon: #imageLiteral(resourceName: "call").resizeImage(newWidth: 25)) { (_) in
            ////                Common.call(to: provider!.mobile)
            ////            }
            //            floaty.addItem(icon: #imageLiteral(resourceName: "chatIcon").resizeImage(newWidth: 25)) { (_) in
            //                if let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.SingleChatController) as? SingleChatController {
            //                    vc.set(user: provider!, requestId: self.currentRequestId)
            //                    let navigation = UINavigationController(rootViewController: vc)
            //                    self.present(navigation, animated: true, completion: nil)
            //                }
            //            }
            //            self.floatyButton = floaty
            msgButton = Button(frame: frame)
            msgButton!.isRoundedCorner = true
//            if #available(iOS 13.0, *) {
//                msgButton!.backgroundColor = UIColor.label
//                msgButton!.tintColor = UIColor.systemBackground
//            } else {
//                msgButton!.backgroundColor = UIColor.black
//                msgButton!.tintColor = UIColor.white
//            }
            if #available(iOS 13.0, *) {
                msgButton!.tintColor = UIColor.label
                msgButton!.backgroundColor = UIColor.systemBackground
            } else {
                msgButton!.tintColor = UIColor.black
                msgButton!.backgroundColor = UIColor.white
            }
            
            msgButton!.setImage(UIImage(named: "message_chat"), for: .normal)
            
            msgButton!.addShadow(rasterize: false)
            msgButton?.addTarget(self, action: #selector(openMsgVC), for: .touchUpInside)
            self.view.addSubview(msgButton!)
        }
    }
    
    @objc func openMsgVC() {
        self.rideStatusView?.messageBadgeView.isHidden = true

        if let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.SingleChatController) as? SingleChatController {
            providerForMsg = self.currntRequest?.provider
            vc.set(user: providerForMsg, requestId: self.currentRequestId)
            let navigation = UINavigationController(rootViewController: vc)
            self.present(navigation, animated: true, completion: nil)
        }
    }
    
    //MARK:- Set ETA
    
    func showETA(destinatoin providerLocation : LocationCoordinate, sorce sourceLocation : LocationCoordinate?) {
        
        // guard let sourceLocation = self.sourceLocationDetail?.value else {return}
        
        print("SHOW ETA")
        guard let sourceLocation = sourceLocation else {return}
        self.mapViewHelper.mapView?.getEstimation(between: CLLocationCoordinate2D(latitude: sourceLocation.latitude, longitude: sourceLocation.longitude), to: providerLocation, completion: { (estimation) in
            DispatchQueue.main.async {
                self.rideStatusView?.setETA(value: estimation)
            }
        })
    }
}

extension HomeViewController : UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.rides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VehicleColCell", for: indexPath) as! VehicleColCell
        let item = self.rides[indexPath.row]
        cell.setData(ride: item)
        if selectedVehIndex == indexPath.row {
            cell.selectedButton.isHidden = false
        }else {
            cell.selectedButton.isHidden = true
        }
        
     
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

       
        callFareApi(index: indexPath.row)
        
//        if let p = service.pricing?.estimated_fare , p > 0.0 {
//        //self.priceTextfield.text = "\(service.pricing?.estimated_fare ?? 0)"
//        self.curOfferAmountByUser = Double(p)
//
//        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//      //  return CGSize(width: 300, height: 260)
//    }
    func callFareApi(index: Int) {
        self.isEstimationCall = true
        let service = self.rides[index]
        self.selectedService = service
        self.roundTripViewBottomConstriant.constant = 20
        selectedVehIndex = index
        self.vehicleCollectionView.reloadData()
                
        self.showEstimationView(with: service)
        
        self.sourceMarker.snippet = service.pricing?.time
        self.mapViewHelper.mapView?.selectedMarker = (service.pricing?.time) == nil ? nil : self.sourceMarker
        
        let sId = service.id ?? 0
        self.getEstimateFareFor(serviceId: sId,isRoundTrip:0, waitingMin: 0)
    }
}
extension HomeViewController {
    
    
    // MARK:- Show Ride Now View
    
    func showRideNowView(with source : [Service]) {
        
        guard let sourceLocation = self.sourceLocationDetail?.value, let destinationLocation = self.positions?[0].value else { return }
        // print("\nselected--**",self.sourceLocationDetail?.value?.coordinate, self.destinationLocationDetail?.coordinate)
        
        //        var selectedPaymentDetail : CardEntity?
        //        var paymentType : PaymentType = (User.main.isCashAllowed ? .CASH : User.main.isCardAllowed ? .CARD : .NONE)
        if self.rideNowView == nil {
            self.vehicleCollectionView.alpha = 1
            self.rides = source
            self.vehicleCollectionView.reloadData()
            self.rideNowView = Bundle.main.loadNibNamed(XIB.Names.RideNowView, owner: self, options: [:])?.first as? RideNowView
            self.rideNowView?.frame = CGRect(origin: CGPoint(x: 0, y: self.view.frame.height-self.rideNowView!.frame.height), size: CGSize(width: self.view.frame.width, height: self.rideNowView!.frame.height))
            self.rideNowView?.clipsToBounds = false
            self.rideNowView?.show(with: .bottom, completion: nil)
            
        //   self.view.addSubview(self.rideNowView!)
            
            //self.updateSOSBtnOrigin(yAxisOfStatusView: self.rideNowView?.frame.origin.y)
            
            self.isOnBooking = true
            self.rideNowView?.onClickProceed = { [weak self] service in
                
                self?.roundTripViewBottomConstriant.constant = 20
                
               self?.showEstimationView(with: service) // new
            
            }
            
            self.rideNowView?.onClickBoatService = { [weak self] service in
                if let service = service {
                    self?.popUpCableView(service: service)
                }
            }
            
            
            self.rideNowView?.onClickTowService = { [weak self] service in
                if let service = service {
                    self?.popUpInstructionsView(service: service)
                }
            }
            
            
            
            
            self.rideNowView?.onClickService = { [weak self] service in
                guard let self = self else {return}
                self.sourceMarker.snippet = service?.pricing?.time
                self.mapViewHelper.mapView?.selectedMarker = (service?.pricing?.time) == nil ? nil : self.sourceMarker
            }
        }
        self.rideNowView?.setAddress(source: sourceLocation.coordinate, destination: destinationLocation.coordinate,position: self.mulitPostions)
        self.rideNowView?.set(source: source)
    }
    
    // MARK:- Remove RideNowView
    
    func removeRideNow() {
        
        self.isOnBooking = false
        self.rideNowView?.dismissView(onCompletion: {
            self.mapViewHelper.mapView?.selectedMarker = nil
        })
        self.rideNowView = nil
    }
    
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
            self.localSelectionParentView.alpha = isHide ? 0 : 1
            self.viewLocationButtons.alpha = isHide ? 0 : 1
            self.estimationFareView?.alpha = isHide ? 0 : 1
            self.rideStatusView?.alpha = isHide ? 0 : 1
            self.invoiceView?.alpha = isHide ? 0 : 1
            self.ratingView?.alpha = isHide ? 0 : 1
            self.rideNowView?.alpha = isHide ? 0 : 1
            //self.floatyButton?.alpha = isHide ? 0 : 1
            self.msgButton?.alpha = isHide ? 0 : 1
            self.reasonView?.alpha = isHide ? 0 : 1
            self.buttonSOS.alpha = isHide ? 0 : 1
            self.changeDestinationButton.alpha = isHide ? 0 : 1
            self.vehicleCollectionView.alpha = isHide ? 0 : 1
            
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
            
            self.estimationFareView = Bundle.main.loadNibNamed(XIB.Names.RequestSelectionView, owner: self, options: [:])?.first as? RequestSelectionView
            var yAxis: CGFloat = 0.0
            var height: CGFloat = 0.0
            if #available(iOS 11.0, *) {
                yAxis = (self.view.frame.height-(self.estimationFareView!.frame.height+UIApplication.shared.windows[0].safeAreaInsets.bottom))
                height = self.estimationFareView!.frame.height+UIApplication.shared.windows[0].safeAreaInsets.bottom
            } else {
                yAxis = self.view.frame.height-self.estimationFareView!.frame.height
                height = self.estimationFareView!.frame.height
            }
            
            self.estimationFareView?.frame = CGRect(x: 0, y: yAxis, width: self.view.frame.width, height: height)
            
            self.estimationFareView?.show(with: .bottom, completion: nil)
           // self.view.addSubview(self.estimationFareView!)
            self.estimationFareView?.scheduleAction = { [weak self] service in
                self?.schedulePickerView(on: { (date) in
                    self?.createRequest(for: service, isScheduled: true, scheduleDate: date,cardEntity: selectedPaymentDetail, paymentType: paymentType, price: Double(self!.priceTextfield.text!)!)
                })
            }
            self.estimationFareView?.rideNowAction = { [weak self] service in
                UserDefaults.standard.setValue(true, forKey: "onRide")
                self?.service?.round_trip = 0
                self?.createRequest(for: service, isScheduled: false, scheduleDate: nil, cardEntity: selectedPaymentDetail, paymentType: paymentType, price: Double(self!.priceTextfield.text!)!) // new
            }
            self.estimationFareView?.roundTripAction = { [weak self] service in
                self?.service = service
                let isPakistan =  userCurrentLocation?.isPakistan  ?? true
                if isPakistan {
                    if let id = self?.service?.id {
                        self?.popUpwaitTime()
//                        self?.isRoundTrip = true
//                        self?.service?.round_trip = 1
//                        self?.getEstimateFareFor(serviceId: id,isRoundTrip:1)
                    }
                }else{
                    self?.persentWaitingTimeSelectionVC()
                }
                
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
                        self?.createRequest(for: service, isScheduled: false, scheduleDate: nil, cardEntity: selectedPaymentDetail, paymentType: paymentType, price: Double(self!.priceTextfield.text!)!)
                        
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
        self.offerView.alpha = 0
        self.localSelectionParentView.alpha = 0
        self.removeRideNow()
        //self.localSelectionParentView.isHidden = true
        self.viewLocationButtons.isHidden = true
        self.loader.isHidden = true
        print("ViewAddressOuter ", #function, !(request.status == .pickedup))
        var addInsects : CGFloat = 0
        if request.status == .arrived {
            addInsects = 40
        }
        
        let rideStatus = Bundle.main.loadNibNamed(XIB.Names.RideStatusView, owner: self, options: [:])?.first as! RideStatusView
        var yAxis: CGFloat = 0.0
        var height: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            yAxis = (self.view.frame.height-(rideStatus.frame.height+UIApplication.shared.windows[0].safeAreaInsets.bottom ))
            height = rideStatus.frame.height+UIApplication.shared.windows[0].safeAreaInsets.bottom
        } else {
            yAxis = self.view.frame.height-rideStatus.frame.height
            height = rideStatus.frame.height
        }
        
        if self.rideStatusView == nil{
            UserDefaults.standard.setValue(true, forKey: "onRide")
            
          
            rideStatus.frame = CGRect(origin: CGPoint(x: 0, y: yAxis - addInsects), size: CGSize(width: self.view.frame.width, height: height + addInsects))
            
            rideStatusView = rideStatus
            rideStatusView?.onClickMessage = {
                self.openMsgVC()
            }
            self.view.addSubview(rideStatus)
//            self.addMessageButton(with: CGRect(x: self.view.frame.width-50, y: yAxis-30, width: 30, height: 30), to: request.provider)
//            self.addMessageButton(with: CGRect(x: self.view.frame.width-50, y: yAxis-40, width: 40, height: 40), to: request.provider)
            
          //  self.addMessageButton(with: CGRect(x: 16, y: yAxis-40, width: 40, height: 40), to: request.provider)
            
            rideStatus.show(with: .bottom, completion: nil)
        }else {
        
            
            rideStatusView?.frame  = CGRect(origin: CGPoint(x: 0, y: yAxis - addInsects), size: CGSize(width: self.view.frame.width, height: height + addInsects))
         
        }
        
        // Change Provider Location
        //        if let latitude = request.provider?.latitude, let longitude = request.provider?.longitude {
        self.getDataFromFirebase(providerID: (request.provider?.id)!)
        //            self.moveProviderMarker(to: LocationCoordinate(latitude: latitude, longitude: longitude))
        //        }
        
        updateSOSBtnOrigin(yAxisOfStatusView: rideStatusView == nil ? nil : self.view.frame.height-rideStatusView!.frame.height)
        
        self.buttonSOS.isHidden = !(request.status == .pickedup)
        self.changeDestinationButton.isHidden = !(request.status == .pickedup)
        self.floatyButton?.isHidden = request.status == .pickedup
        rideStatusView?.set(values: request)
        rideStatusView?.onClickCancel = {
            self.cancelCurrentRide(isSendReason: true)
        }
        rideStatusView?.onClickShare = {
            self.shareRide()
        }
        
    }
    
    func updateSOSBtnOrigin(yAxisOfStatusView: CGFloat?){
        self.buttonSOS.frame = CGRect(x: 8, y: yAxisOfStatusView == nil ? self.view.center.y - 25 :  yAxisOfStatusView!-50, width: 50, height: 50)
        self.changeDestinationButton.frame = CGRect(x: 66, y: yAxisOfStatusView == nil ? self.view.center.y - 25 :  yAxisOfStatusView!-50, width: 50, height: 50)
    }
    
    
    // MARK:- Remove RideStatus View
    
    func removeRideStatusView() {
        self.buttonSOS.isHidden = !(riderStatus == .pickedup)
        self.changeDestinationButton.isHidden = !(riderStatus == .pickedup)
        self.rideStatusView?.dismissView(onCompletion: {
            self.rideStatusView = nil
        })
        
    }
    
    
    // MARK:- Show Invoice View
    
    func showInvoiceView(with request : Request) {
        isRateViewShowed = false
        self.isInvoiceShowed = true
        self.buttonSOS.isHidden = !(riderStatus == .pickedup)
        self.changeDestinationButton.isHidden = !(riderStatus == .pickedup)
        self.mapViewHelper.mapView?.clear()
        if self.invoiceView == nil, let invoice = Bundle.main.loadNibNamed(XIB.Names.InvoiceView, owner: self, options: [:])?.first as? InvoiceView {
            //self.localSelectionParentView.isHidden = true
            
            self.viewLocationButtons.isHidden = true
            print("ViewAddressOuter ", #function)
            if #available(iOS 11.0, *) {
                let topInset = UIApplication.shared.windows[0].safeAreaInsets.top
                invoice.frame = CGRect(origin: CGPoint(x: 0, y: topInset+10), size: CGSize(width: self.view.frame.width, height: (self.view.frame.height-(topInset+10))))
            } else {
                invoice.frame = CGRect(origin: CGPoint(x: 0, y: 30), size: CGSize(width: self.view.frame.width, height: self.view.frame.height-30))
            }
            invoiceView = invoice
            invoiceView?.stops = request.stops
            invoiceView?.sourceAddress = request.s_address
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
                            
                            
                        }else if paymentTypeEntity == .CASH{
                            self.updatePaymentTypeToCash()
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
        self.buttonSOS.isHidden = !(riderStatus == .pickedup)
        self.changeDestinationButton.isHidden = !(riderStatus == .pickedup)
        
        
        
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
            //self.localSelectionParentView.isHidden = true
            self.viewLocationButtons.isHidden = true
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
            self.presenter?.get(api: .getProfile, parameters: nil)
        }
    }
    
    
    // MARK:- Remove RideStatus View
    
    func removeRatingView() {
        Store.review() // Getting Appstore review from user
        self.ratingView?.dismissView(onCompletion: {
            self.ratingView = nil
            self.localSelectionParentView.isHidden = false
            self.viewLocationButtons.isHidden = false
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
        
        var providersData = data
        
        for provider in providersData {
            if let marker = markersProviders.first(where: { marker in
                (marker.userData as! [String : Int])["id"] == provider.id!
            }){
            
                CATransaction.begin()
                CATransaction.setAnimationDuration(2)

                marker.position = CLLocationCoordinate2DMake(provider.latitude!, provider.longitude!)
                
                CATransaction.commit()
            }else{
                let marker = GMSMarker(position: CLLocationCoordinate2DMake(provider.latitude!, provider.longitude!))
                marker.userData = ["id" : provider.id]
                marker.icon = #imageLiteral(resourceName: "map-vehicle-icon-black").resizeImage(newWidth: 20)
                marker.groundAnchor = CGPoint(x: 0.5, y: 1)
                marker.map = mapViewHelper.mapView
                self.markersProviders.append(marker)
            }
        }
        
        markersProviders.removeAll { marker in
            if !providersData.contains(where: { provider in
                (marker.userData as! [String : Int])["id"] == provider.id!
            }){
                marker.map = nil
                return true
            }else{
                return false
            }
        }
        
    }
    
    // MARK:- Show Loader View
    
    func showLoaderView(with requestId : Int? = nil) {
        setDataOFFarwView()
        topRideDetailView.alpha = 1
        bottomRaiseView.alpha = 1
        offerCancelButton.alpha = 1
        self.roundTripViewBottomConstriant.constant = -80
        offerCancelButton.alpha = 1
        driverFindingLabel.alpha = 1
        localSelectionParentView.isHidden = true
        vehicleCollectionView.isHidden = true
        
        if self.requestLoaderView == nil, let singleView = Bundle.main.loadNibNamed(XIB.Names.LoaderView, owner: self, options: [:])?.first as? LoaderView {
            self.isOnBooking = true
            singleView.frame = self.viewMapOuter.bounds
            self.requestLoaderView = singleView
            self.requestLoaderView?.onCancel = {
                self.cancelCurrentRide()
            }
            //self.view.addSubview(singleView)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) { // Hiding Address View
                UIView.animate(withDuration: 0.5, animations: {
                    //self.localSelectionParentView.isHidden = false
                    self.viewLocationButtons.isHidden = true
                    print("ViewAddressOuter ", #function)
                })
            }
        }
        self.requestLoaderView?.isCancelButtonEnabled = requestId != nil
    }
    
    
    func setDataOFFarwView(){
        self.tripSourceAddressLabel.text = self.sourceAddressLabel.text
        self.tripDesLabel.text = self.stop1AddressLabel.text
        self.vehicleNameLabel.text = self.selectedService?.name
//        self.tripPriceLabel.text = "C$\(self.currntRequest?.offer_price ?? 0)"
//        self.tripCurrentFareLabel.text = "C$\(self.currntRequest?.offer_price ?? 0)"
        
    }
    // MARK:- Remove Loader View
    
    func removeLoaderView() {
        
        self.requestLoaderView?.endLoader {
            self.requestLoaderView = nil
            // self.viewAddressOuter.isHidden = false
            self.viewLocationButtons.isHidden = false
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
        
        self.mapViewHelper.mapView?.clear()
        
        if let location = self.mapViewHelper.locationManager.location?.coordinate {
            let locationCoordinate = LocationCoordinate(latitude: location.latitude, longitude: location.longitude)
            
            self.mapViewHelper.getPlaceAddress(from: locationCoordinate) { locationDetail in
                print("Location Detail is",locationDetail.address)
                self.sourceLocationDetail?.value = locationDetail
                self.sourceAddressLabel.text = (self.sourceLocationDetail?.value?.address ?? "")
            }
        }
        
   
        self.destinationLocationDetail = nil
        self.positions = [Bind<LocationDetail>(nil)]
        stop1AddressLabel.text = "Where to?"

        stop2AddressLabel?.text = ""
        stop3AddressLabel?.text = ""
        if #available(iOS 13.0, *) {
            stop1AddressLabel?.textColor = .label
            stop2AddressLabel?.textColor = .label
            stop3AddressLabel?.textColor = .label
        } else {
            stop1AddressLabel.textColor = .black
            stop2AddressLabel.textColor = .black
            stop3AddressLabel.textColor = .black
        }
        self.stop2StackView?.isHidden = true
        self.stop3StackView?.isHidden = true
        self.localSelectionParentView.isHidden = false
        self.viewLocationButtons.isHidden = false
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
           // self.showLoaderView(with: self.currentRequestId)
            //self.perform(#selector(self.validateRequest), with: self, afterDelay: requestInterval)
            self.topRideDetailView.alpha = 1
            self.bottomRaiseView.alpha = 1
            self.localSelectionParentView.alpha = 0
            self.roundTripViewBottomConstriant.constant = -80
            offerCancelButton.alpha = 1
            driverFindingLabel.alpha = 1
            if offers.count > 0 {
                if !self.isOfferAccepted {
                self.topRideDetailView.alpha = 0
                self.bottomRaiseView.alpha = 0
                    offerCancelButton.alpha = 0
                    driverFindingLabel.alpha = 0
                self.offerView.alpha = 1
                self.offerView.isHidden = false
               // self.offerTableView.reloadData()
                }
            }
            
        case .accepted:
            
            self.showRideStatusView(with: request)
         

        case .arrived:
            print("arrived")
            self.showRideStatusView(with: request)

        case .started:
            print("arrived")
            self.showRideStatusView(with: request)

        case .pickedup:
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
            if UserDefaults.standard.bool(forKey: "onRide"), status == .none{
                self.removeEstimationFareView()
                self.removeRideNow()
                self.rideStatusView?.dismissView(onCompletion: {
                    self.rideStatusView = nil
                })
                
             //   self.getServicesList()
                UserDefaults.standard.setValue(false, forKey: "onRide")
            }else{
                self.removeRideStatusView()
            }
            
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
        if status == .none {
            self.localSelectionParentView.alpha = 1
           // self.roundTripViewBottomConstriant.constant = -80
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
            //            self.clearMapview()
            //            self.removeRideNow()
            //            self.removeEstimationFareView()
            //self.isOnBooking = false
            
        }
        
        
    }
    
    // MARK: - WalletView -
    func showOutstandingAlertView(){
        // self.view.frame.height-self.walletAlertView!.frame.height
        if self.walletAlertView == nil {
            self.walletAlertView = Bundle.main.loadNibNamed(XIB.Names.WalletAlertView, owner: self, options: [:])?.first as? WalletAlertView
            self.walletAlertView?.frame = CGRect(origin: CGPoint(x: 0, y:0), size: CGSize(width: self.view.frame.width, height: self.view!.frame.height))
            //            self.walletAlertView?.dismissView(onCompletion: {
            //                self.removeWalletView()
            //            })
            self.walletAlertView?.onPayClick = {
                print("onPayClick")
                self.removeWalletView()
                self.showWalletVC()
            }
            self.walletAlertView?.onOkButtonClick = {
                print("onOkButtonClick")
                self.removeWalletView()
            }
            self.walletAlertView?.clipsToBounds = false
            self.walletAlertView?.show(with: .bottom, completion: nil)
            self.view.addSubview(self.walletAlertView!)
            
        }
    }
    
    private func removeWalletView() {
        UIView.animate(withDuration: 0.3,
                       animations: {
            self.walletAlertView?.transform = CGAffineTransform.identity
            self.walletAlertView?.alpha = 0
        }) { (_) in
            self.walletAlertView?.removeFromSuperview()
            self.walletAlertView = nil
        }
    }
    // MARK:- SOS Action
    
    @IBAction func buttonSOSAction() {
        
        showAlert(message: Constants.string.wouldyouLiketoMakeaSOSCall.localize(), okHandler: {
            Common.call(to: "\(/*User.main.sos ??*/ "911")")
        }, cancelHandler: {
            
        }, fromView: self)
        
    }
    
}



// MARK: - Navigation -


