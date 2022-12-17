//
//  RideStatusView.swift
//  User
//
//  Created by CSS on 23/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class RideStatusView: UIView {
    
    @IBOutlet private weak var labelTopTitle : UILabel!
    @IBOutlet private weak var imageViewProvider : UIImageView!
    @IBOutlet private weak var labelProviderName : UILabel!
    @IBOutlet private weak var viewRating : FloatRatingView!
    @IBOutlet private weak var imageViewService : UIImageView!
    @IBOutlet private weak var labelServiceName : UILabel!
    @IBOutlet private weak var labelServiceDescription : UILabel!
    @IBOutlet private weak var labelServiceNumber : UILabel!
    @IBOutlet private weak var buttonCall : UIButton!
    @IBOutlet private weak var buttonCancel : UIButton!
    
    @IBOutlet private weak var buttonShareRide : UIButton!
    
    @IBOutlet private weak var labelOtp : UILabel!

    @IBOutlet private weak var labelETA : UILabel!
    
    private var currentStatus : RideStatus = .none {
        didSet{
            DispatchQueue.main.async {
                if [RideStatus.started, .accepted, .arrived].contains(self.currentStatus) {
                    self.buttonCancel.isHidden = false
                    self.buttonCancel.setTitle(Constants.string.Cancel.localize().uppercased(), for: .normal)
                    self.buttonShareRide.setTitle(Constants.string.shareRide.localize().uppercased(), for: .normal)
//                    self.buttonShareRide.setImage(UIImage(named: "share"), for: .normal)
                } else {
                    self.buttonCancel.isHidden = true
                    self.buttonShareRide.setTitle(Constants.string.shareRide.localize().uppercased(), for: .normal)
                    self.buttonShareRide.setImage(UIImage(named: "share"), for: .normal)
                }
            }
        }
    }
    
    private var isOnSurge : Bool = false {
        didSet {
        }
    }
    
    
    var onClickCancel : (()->Void)?
    var onClickShare : (()->Void)?

    private var request : Request?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialLoads()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.imageViewProvider.makeRoundedCorner()
    }
}

extension RideStatusView {
    
    private func initialLoads() {
        self.initRating()
        self.localize()
        self.buttonCall.addTarget(self, action: #selector(self.callAction), for: .touchUpInside)
        self.buttonCancel.addTarget(self, action: #selector(self.cancelShareAction), for: .touchUpInside)
        self.buttonShareRide.addTarget(self, action: #selector(self.shareAction), for: .touchUpInside)
        self.setDesign()
        
    }
    
    // MARK:- Set Designs
    
    private func setDesign() {
//        Common.setFont(to: labelETA, isTitle: true)
//        Common.setFont(to: labelOtp, isTitle: true)
//        Common.setFont(to: labelTopTitle)
//        Common.setFont(to: labelServiceName)
//        Common.setFont(to: labelProviderName)
//        Common.setFont(to: labelServiceNumber)
//        Common.setFont(to: labelServiceDescription)
//        Common.setFont(to: buttonCancel, isTitle: true)
//        Common.setFont(to: buttonCall, isTitle: true)
        //buttonCancel.setTitleColor(.white, for: .normal)
        //buttonCall.setTitleColor(.white, for: .normal)
        
    }
    
    // MARK:- Localization
    private func localize() {

        self.buttonCall.setTitle(Constants.string.call.localize().uppercased()
            , for: .normal)
        self.buttonCancel.setTitle(Constants.string.Cancel.localize().uppercased(), for: .normal)
    }
    
    // MARK:- Rating
    private func initRating() {
        
        viewRating.fullImage = #imageLiteral(resourceName: "StarFull")
        viewRating.emptyImage = #imageLiteral(resourceName: "StarEmpty")
        viewRating.minRating = 0
        viewRating.maxRating = 5
        viewRating.rating = 0
        viewRating.editable = false
        viewRating.minImageSize = CGSize(width: 3, height: 3)
        viewRating.floatRatings = true
        viewRating.contentMode = .scaleAspectFit
    }
    
    func setETA(value : String) {
        self.labelETA.text = " \(Constants.string.ETA.localize()): \(value) "
       
    }
    
    
    // MARK:- Set Values
    
    func set(values : Request) {
        
        self.request = values
        self.currentStatus = values.status ?? .none
        
        
//        self.labelETA.isHidden = !([RideStatus.accepted,.started,,].contains(self.currentStatus))
        self.labelTopTitle.text = {
            switch values.status! {
                case .accepted, .started:
                self.labelETA.isHidden = false
                   return Constants.string.driverAccepted.localize()
                case .arrived:
                    self.labelETA.isHidden = true
                   return Constants.string.driverArrived.localize()
                case .pickedup:
                   self.labelOtp.isHidden = true
                self.labelETA.isHidden = true
                   return Constants.string.youAreOnRide.localize()
                default:
                  return .Empty
               }
            }()
        
        Cache.image(forUrl: Common.getImageUrl(for: values.provider?.avatar)) { (image) in
            if image != nil {
                DispatchQueue.main.async {
                    self.imageViewProvider.image = image
                }
            }
        }
        
        Cache.image(forUrl: values.service?.image) { (image) in
            if image != nil {
                DispatchQueue.main.async {
                    self.imageViewService.image = image?.withRenderingMode(.alwaysTemplate)
                }
            }
        }
        
        self.labelProviderName.text = String.removeNil(values.provider?.first_name)+" "+String.removeNil(values.provider?.last_name)
        self.viewRating.rating = Float(values.provider?.rating ?? "0") ?? 0
        self.labelServiceName.text = values.service?.name
        self.labelServiceNumber.text = values.provider_service?.service_number
        self.labelServiceDescription.text = values.provider_service?.service_model
        self.labelOtp.text = " \(Constants.string.otp.localize()+": "+String.removeNil(values.otp)) "
        self.isOnSurge = values.surge == 1
    }
    
    // MARK:- Call Provider
    
    @IBAction private func callAction() {
        
        Common.call(to: request?.provider?.mobile)
        
    }
    
//    // MARK:- Chat Provider
//    
//    @IBAction private func chatWithProvider() {
//        
//        print("Chat")
//    }
    
    // MARK:- Cancel Share Action
    
    @IBAction private func cancelShareAction() {
        
        if let status = request?.status,[RideStatus.accepted, .started, .arrived].contains(status) {
            self.onClickCancel?()
        } else {
//            self.onClickShare?()
        }
        
    }
    
    @IBAction private func shareAction() {
        self.onClickShare?()
    }
    
}


extension RideStatusView : FloatyDelegate {
    
     func floatyWillOpen(_ floaty: Floaty) {
        print("Clocked")
    }

}
