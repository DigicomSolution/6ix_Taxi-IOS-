//
//  RideNowView.swift
//  User
//
//  Created by CSS on 27/06/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class RideNowView: UIView {
    
    
    @IBOutlet weak var progressView : UIProgressView!
    @IBOutlet private weak var collectionViewService : UICollectionView!
    @IBOutlet private weak var buttonProceed : UIButton!

    
    private var datasource = [Service]()
   
    var onClickProceed : ((Service)->Void)? // Onlclick Ride Now
    var onClickService : ((Service?)->Void)? // Onclick each servicetype
    
    
    
    var onClickTowService : ((Service?)->Void)? // Onclick each servicetype
    var onClickBoatService : ((Service?)->Void)? // Onclick each servicetype
    
    
    private var rateView : RateView?
    private var selectedItem : Service?
    private var timer : Timer?
    private let timerSchedule : TimeInterval = 30
    private var timerValue : TimeInterval = 0
    
    private var sourceCoordinate = LocationCoordinate()
    private var destinationCoordinate = LocationCoordinate()
    private var positions : [Positions]?
    private var selectedRow = -1


    // boolean to disable or enable the ride buttons
    private var isRideEnabled = true {
        didSet {
            self.buttonProceed.isEnabled = isRideEnabled
            self.buttonProceed.alpha = isRideEnabled ? 1 : 0.7
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialLoads()
        self.localize()
        self.setDesign()
        //self.setViews()
    }
    
}

extension RideNowView {
    
    private func initialLoads() {
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        self.collectionViewService.delegate = self
        self.collectionViewService.dataSource = self
        self.collectionViewService.register(UINib(nibName: XIB.Names.ServiceSelectionCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: XIB.Names.ServiceSelectionCollectionViewCell)
        self.buttonProceed.addTarget(self, action: #selector(self.buttonActions(sender:)), for: .touchUpInside)
       
        self.initializeRateView()
        self.setProgressView()
        self.isRideEnabled = false
    }
 
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        collectionViewService.reloadData()
    }
    
    // MARK:- Set Designs
    
    private func setDesign() {
        Common.setFont(to: buttonProceed)
    }
    
    // MARK:- Localize
    
    private func localize(){
        
        self.buttonProceed.setTitle(Constants.string.letsGo.localize(), for: .normal)
       
    }
    
    // MARK:- Button Actions
    
    @IBAction private func buttonActions(sender : UIButton) {
        
        guard self.selectedItem?.pricing != nil else {
            UIApplication.shared.keyWindow?.makeToast(Constants.string.extimationFareNotAvailable.localize())
            return
        }
        self.onClickProceed?(self.selectedItem!)
    }
    
    // Getting service array from  Homeviewcontroller
    func set(source : [Service]) {
        
        self.selectedRow = -1
        self.datasource = source
        self.collectionViewService.reloadData()
        self.isRideEnabled = false
        self.collectionView(collectionViewService, didSelectItemAt: IndexPath(item: 0, section: 0))
    }
    
    // Setting address from HomeViewController
    func setAddress(source : LocationCoordinate, destination : LocationCoordinate,position: [Positions]?) {
        // print("\nselected ------>",self.sourceCoordinate,self.destinationCoordinate)
        self.sourceCoordinate = source
        self.destinationCoordinate = destination
        self.positions = position
    }
    
    // MARK:- Initialize Rate View
    
    private func initializeRateView() {
        
        if self.rateView == nil {
            self.rateView = Bundle.main.loadNibNamed(XIB.Names.RateView, owner: self, options: [:])?.first as? RateView
            self.rateView?.frame = CGRect(origin: CGPoint(x: 0, y: self.frame.height-self.rateView!.frame.height), size: CGSize(width: self.frame.width, height: self.rateView!.frame.height))
            self.rateView?.onCancel = {
                self.removeRateView()
            }
            self.addSubview(self.rateView!)
            self.rateView?.alpha = 0
        }
        // self.rateView?.set(values: self.selectedItem)
        
    }
    
    // MARK:- Remove Rate View
    
    private func removeRateView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.rateView?.frame.origin.y += (self.rateView?.frame.height) ?? 0
            self.rateView?.alpha = 0
        }) { (_) in
            self.rateView?.frame.origin.y -= (self.rateView?.frame.height) ?? 0
        }
    }
    
    // MARK:- Show Rate View
    
    private func showRateView() {
        guard selectedItem?.pricing != nil else {return}
        UIView.animate(withDuration: 0.5) {
            self.rateView?.alpha = 1
        }
        self.rateView?.set(values: self.selectedItem)
        self.rateView?.show(with: .bottom, completion: nil)
        
    }
    
    /*@IBAction private func panAction(sender : UIPanGestureRecognizer) {
     
     /*  guard !isPresented else {
     return
     }
     if sender.state == .began {
     
     self.addRateView()
     self.setTransform(transform: CGAffineTransform(scaleX: 0, y: 0), alpha: 0)
     
     }else */
     if sender.state == .changed {
     let point = sender.translation(in: UIApplication.shared.keyWindow ?? self)
     print("point  ",point)
     let value = (abs(point.y)/self.frame.height)*1.5
     UIView.animate(withDuration: 0.3) {
     self.setTransform(transform: CGAffineTransform(scaleX: value, y: value), alpha: value)
     }
     if value>0.6 {
     //self.isPresented = true
     UIView.animate(withDuration: 0.3) {
     self.setTransform(transform: .identity, alpha: 1)
     }
     }
     
     } else {
     UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
     self.setTransform(transform: CGAffineTransform(scaleX: 0, y: 0), alpha: 0)
     }, completion: { _ in
     self.removeRateView()
     })
     }
     
     }
     
     // MARK:- Transform View
     
     private func setTransform(transform : CGAffineTransform, alpha : CGFloat) {
     
     self.rateView?.alpha = alpha
     self.rateView?.transform = transform
     self.rateView?.center = CGPoint(x: self.rateView!.frame.width/2, y: self.frame.height-(self.rateView!.frame.height/2))
     
     } */
    
    
    // Get Estimate Fare
    
    func getEstimateFareFor(serviceId : Int) {
       // print("\nselected -----",self.sourceCoordinate,self.destinationCoordinate)
        DispatchQueue.global(qos: .userInteractive).async {
            guard self.sourceCoordinate.latitude != 0, self.sourceCoordinate.longitude != 0, self.destinationCoordinate.latitude != 0, self.destinationCoordinate.longitude != 0 else {
                return
            }
            var estimateFare = EstimateFareRequest()
            estimateFare.s_latitude = self.sourceCoordinate.latitude
            estimateFare.s_longitude = self.sourceCoordinate.longitude
            //estimateFare.s_address = ""
           // estimateFare.positions = self.positions
            
            
            
            if let array = self.positions{
                
                var toGoArray = [Any]()
                
                for val in array{
                    
                    toGoArray.append(val.JSONRepresentation)
                }
                
                
                if let jsonString = convertIntoJSONString2(arrayObject: toGoArray){
                    print("jsonString - \(jsonString)")
//                    estimateFare.positions = jsonString
                    
                    let urlwithPercentEscapes = jsonString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
                    
                    print(urlwithPercentEscapes)
                    
                    estimateFare.positions = urlwithPercentEscapes//jsonString
                }
            }
            
            estimateFare.service_type = serviceId
            estimateFare.round_trip   = 0
            print("<<-- \(estimateFare.JSONRepresentation.description)")
           // print("\nselected ---",self.presenter)
            self.presenter?.get(api: .estimateFare, parameters: estimateFare.JSONRepresentation)
        }
        self.resetProgressView()
        self.startProgressing()
    }
    
    // Get Providers In Current Location
    
    private func getProviders(by serviceId : Int){
        DispatchQueue.global(qos: .background).async {
          //  guard let currentLoc = self.sourceCoordinate .value  else { return }
                let json = [Constants.string.latitude : self.sourceCoordinate.latitude, Constants.string.longitude : self.sourceCoordinate.longitude, Constants.string.service : serviceId] as [String : Any]
                self.presenter?.get(api: .getProviders, parameters: json)
        }
    }
    
    // MARK:- Set Progress View
    private func setProgressView() {
        
        self.progressView.progressTintColor = .secondary
        self.resetProgressView()
        self.progressView.progressViewStyle = .bar
        
    }
    
    // MARK:- Reset Progress view
    private func resetProgressView() {
        DispatchQueue.main.async {
            self.progressView.progress = 0
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    private func startProgressing() {
        DispatchQueue.main.async {
            self.timerValue = 0
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
            self.timer?.fire()
        }
    }
    
    
    @IBAction private func timerAction() {
        self.timerValue  += 5
        CATransaction.begin()
        CATransaction.setAnimationDuration(2)
        CATransaction.setCompletionBlock {
             self.progressView.progress = Float(self.timerValue/self.timerSchedule)
        }
        CATransaction.commit()
    }
    
    // MARK:- Set Surge View
    
    private func setSurgeViewAndWallet() {
        
        if self.datasource.count>selectedRow, self.datasource[selectedRow].pricing != nil {
           
        }
        
    }
    
}


extension RideNowView : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return self.getCellFor(itemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       // print("\nselected ",indexPath)
        self.select(at: indexPath)
    }
    
    private func getCellFor(itemAt indexPath : IndexPath)->UICollectionViewCell{
        
        if let collectionCell = self.collectionViewService.dequeueReusableCell(withReuseIdentifier: XIB.Names.ServiceSelectionCollectionViewCell, for: indexPath) as? ServiceSelectionCollectionViewCell {
            if datasource.count > indexPath.row {
                collectionCell.set(value: datasource[indexPath.row])
                if self.selectedRow == indexPath.row {
                    if !collectionCell.isSelected {
                        collectionCell.isSelected = true
                        self.onClickService?(self.datasource[indexPath.row])
                    }
                } else {
                    collectionCell.isSelected = false
                }
            }
            return collectionCell
        }
        
        return UICollectionViewCell()
    }
    
    
    private func select(at indexPath : IndexPath) {
       // print("\nselected -",datasource.count)
        if datasource.count>indexPath.row {
            //let id = datasource[indexPath.row].id
           
            self.collectionViewService.cellForItem(at: IndexPath(item: self.selectedRow, section: 0))?.isSelected = false
            if self.selectedRow == indexPath.row {
                self.showRateView()
                return
            }
            self.selectedItem = self.datasource[indexPath.row]
            //self.labelCapacity.text = "\(Int.removeNil(self.selectedItem?.capacity))"
            self.selectedRow = indexPath.row
            self.setSurgeViewAndWallet()
            self.onClickService?(self.selectedItem)  // Send selectedItem to show the ETA on Map
            
            //self.getProviders(by: id)
        }
        
        if selectedItem?.pricing == nil, let id = self.selectedItem?.id {
           // print("\nselected --",id)
            
            if id == 6 {
                        //here show the popup of isntractions
                
                //    selectedItem?.instructions = "New Instructions"
                
                self.onClickTowService?(self.selectedItem!)
                    
                    }else if id == 7 {
                        //show cable or without cable boots
                
                    self.onClickBoatService?(self.selectedItem!)
                
                    }else{
                       self.getEstimateFareFor(serviceId: id)
                    }
            
          //   self.getEstimateFareFor(serviceId: id)
            
           // self.getEstimateFareFor(serviceId: id)
        }
    }
}

// MARK:- PostViewProtocol

extension RideNowView : PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        DispatchQueue.main.async {
            print("\nController --- ",message,code)
            UIApplication.shared.keyWindow?.makeToast(message)
            self.resetProgressView()
            self.isRideEnabled = false
        }
    }
    
    func getEstimateFare(api: Base, data: EstimateFare?) {
        // print("\nselected ",data)
        if let serviceTypeId = data?.service_type, let index = self.datasource.firstIndex(where: { $0.id == serviceTypeId }) {
            //self.getProviders(by: serviceTypeId)
            self.datasource[index].pricing = data
            DispatchQueue.main.async {
                self.isRideEnabled = (User.main.isCardAllowed || User.main.isCashAllowed) // Allow only if any payment gateway is enabled
                self.resetProgressView()
                self.setSurgeViewAndWallet()
                self.collectionViewService.reloadItems(at: [IndexPath(item: index, section: 0)])
            }
        }
    }
    
    func getServiceList(api: Base, data: [Service]) {
        
        if api == .getProviders {  // Show Providers in Current Location
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .providers, object: nil, userInfo: [Notification.Name.providers.rawValue: data])
            }
        }
    }
    
    
}



