//
//  HomeViewController.swift
//  User
//
//  Created by CSS on 02/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit
import KWDrawerController
import GoogleMaps
import GooglePlaces
import DateTimePicker
import MapKit
//import IQKeyboardManagerSwift
import FirebaseDatabase
import PopupDialog
import SwiftKeychainWrapper
import ScalingCarousel
import SwiftUI
import StripeUICore
import KRProgressHUD
var riderStatus : RideStatus = .none // Provider Current Status

class HomeViewController: UIViewController {
    // single trip
    @IBOutlet weak var driverFindingLabel: UILabel!
    @IBOutlet weak var offerCancelButton: UIButton!
    @IBOutlet weak var raiseButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var roundTripButton: UIButton!
    @IBOutlet weak var singleTripButton: UIButton!
    @IBOutlet weak var cashImage: UIImageView!
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var vehicleNameLabel: UILabel!
   
    @IBOutlet weak var tripTypeLabel: UILabel!
    @IBOutlet weak var tripCurrentFareLabel: UILabel!
    @IBOutlet weak var addFareLabel: UILabel!
    @IBOutlet weak var minusFareLabel: UILabel!
    @IBOutlet weak var tripDistanceLabel: UILabel!
    @IBOutlet weak var tripTimeLAbel: UILabel!
    @IBOutlet weak var tripDesLabel: UILabel!
    @IBOutlet weak var tripSourceAddressLabel: UILabel!
    @IBOutlet weak var tripPriceLabel: UILabel!
    
    @IBOutlet weak var locationViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var offerTopView: NSLayoutConstraint!
    @IBOutlet weak var estmView: UIView!
    @IBOutlet weak var priceTextfield: UITextField!
    @IBOutlet weak var bottomRaiseView: UIView!
    @IBOutlet weak var topRideDetailView: UIView!
    @IBOutlet weak var estPRiceLabel: UILabel!
    @IBOutlet weak var addressVieww: UIView!
    @IBOutlet weak var moreLabel: UILabel!
    @IBOutlet weak var mileLabel: UILabel!
    @IBOutlet weak var timeLAbel: UILabel!
    @IBOutlet weak var cardButton: UIButton!
    @IBOutlet weak var cashButton: UIButton!
    @IBOutlet weak var messageTextfield: UITextField!
    @IBOutlet weak var roundTripViewBottomConstriant: NSLayoutConstraint!
    @IBOutlet weak var locationViewButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var vehicleCollectionView: ScalingCarouselView!
   // @IBOutlet weak var offerCancelButton: UIButton!
    @IBOutlet weak var offerTableView: UITableView!
    @IBOutlet weak var offerView: UIView!
    var isEstimationCall = false
    var isAlreadyPopulated = false
    
    var currentEstimation : EstimateFare?
    var currentUserMapLocatio : CLLocationCoordinate2D?
    var currency : String?
    var isOfferAccepted = false
    var isWaitngForOffer = false
    var currntRequest : Request?
    var rides = [Service]()
    var offers = [Offer]()
    var selectedVehIndex = 0
    var newPaymentType : PaymentType = .CASH
    var selectedService : Service?
    var curOfferAmountByUser : Double = 0.0
    {
        didSet {
            let p = Formatter.shared.limit(string: "\(curOfferAmountByUser)", maximumDecimal: 2)
            self.tripCurrentFareLabel.text = "C$\(p)"
            self.tripPriceLabel.text = "C$\(p)"
            self.priceTextfield.text = "\(p)"
            
        }
    }
    
    var firtstimatedFare : Double = 0.0
    
    var updatingDestination = false
    var isRoundTrip = false
    var updatePositions:[Positions]?
    var estimateFarePop:EstimatedFareViewController!
    
    var waitTimePop:WaitTimeViewController!
    
    
    @IBOutlet weak var localSelectionParentView: View!
    @IBOutlet weak var sourceAddressLabel: UILabel!
    @IBOutlet weak var stop1AddressLabel: UILabel!
    @IBOutlet weak var stop2AddressLabel: UILabel!
    @IBOutlet weak var stop3AddressLabel: UILabel!
    @IBOutlet weak var stop2StackView: UIStackView!
    @IBOutlet weak var stop3StackView: UIStackView!
    
    
    
    
    var service:Service?
    var is_booster_cable:Int?
    var instructions = ""
    
    var instructionsTowPop:TowTruckInstructionViewController!
    var boosterCablePop:BoosterCableViewController!
    var popUpDialog:PopupDialog!
    
    
    
    var updateRoute = true
    var isCPRouteTrigged = true
    var isPDRouteTrigged = true
    var shortDistance:Double = 0
    var currLocation:CLLocation!
    
    
    
    
    @IBOutlet weak var gpsBtn: Button!
    
    @IBOutlet weak var sideMenuBtn: UIButton!
    @IBOutlet weak var viewMapOuter : UIView!
    //@IBOutlet weak private var viewFavouriteSource : UIView!
    //@IBOutlet weak private var viewFavouriteDestination : UIView!
    //@IBOutlet weak private var imageViewFavouriteSource : ImageView!
    //@IBOutlet weak private var imageViewFavouriteDestination : ImageView!
    
    
    @IBOutlet weak private var imageViewMarkerCenter : UIImageView!
    @IBOutlet weak var buttonSOS : UIButton!
    @IBOutlet weak private var viewHomeLocation : UIView!
    @IBOutlet weak private var viewWorkLocation : UIView!
    @IBOutlet weak var viewLocationButtons : UIStackView!
    @IBOutlet weak var homeImageView: UIImageView!
    
    @IBOutlet weak var changeDestinationButton:UIButton!
    
    
    private var sourceCoordinate = LocationCoordinate()
    private var destinationCoordinate = LocationCoordinate()
    final var currentProvider: Provider?
    var updateStatus: RideStatus?
    var providerForMsg: Provider!
    
    var stops : [Stops]?
    
    var service_type_id :Int?
    
    
    @IBOutlet var constraint : NSLayoutConstraint!
    var OTPScreen : OTPScreenView?
    var userOtp : String?
    var providerLastLocation = LocationCoordinate()
    lazy var markerProviderLocation : GMSMarker = {  // Provider Location Marker
        let marker = GMSMarker()
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        imageView.contentMode =  .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "map-vehicle-icon-black")
        marker.iconView = imageView
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.map = self.mapViewHelper.mapView
        return marker
    }()
    
    var isOnBooking = false {  // Boolean to handle back using side menu button
        didSet {
            
            if topRideDetailView.alpha == 1 {
                sideMenuBtn.setTitle("Cancel", for: .normal)
            }else{
                sideMenuBtn.setImage(isOnBooking ? #imageLiteral(resourceName: "back-icon") : #imageLiteral(resourceName: "menu_icon"), for: .normal)
            }
        }
    }
    
    private var isUserInteractingWithMap = false // Boolean to handle Mapview User interaction
    // private let transition = CircularTransition()  // Translation to for location Tap
    var mapViewHelper = GoogleMapsHelper()
   
    //        private var favouriteViewSource : LottieView?
    //        private var favouriteViewDestination : LottieView?
    
    //        private var isSourceFavourited = false {  // Boolean to handle favourite source location
    //            didSet{
    //                self.isAddFavouriteLocation(in: self.viewFavouriteSource, isAdd: isSourceFavourited)
    //            }
    //        }
    //
    //        private var isDestinationFavourited = false { // Boolean to handle favourite destination location
    //            didSet{
    //                self.isAddFavouriteLocation(in: self.viewFavouriteDestination, isAdd: isDestinationFavourited)
    //            }
    //        }
    
    
    var sourceLocationDetail : Bind<LocationDetail>? = Bind<LocationDetail>(nil)
    
    var positions : [Bind<LocationDetail>]? = [Bind<LocationDetail>(nil)]
    
    var mulitPostions: [Positions]?
    
    var newPositions: [Positions]?
    
    var updateStops: [Stops]?
    
    var destinationLocationDetail : LocationDetail? //{  // Destination Location Detail
    // didSet{
    //  DispatchQueue.main.async {
    //self.isDestinationFavourited = false // reset favourite location on change
    //                    if self.destinationLocationDetail == nil {
    //                        self.isDestinationFavourited = false
    //                    }
    //  }
    //}
    //}
    
    //  private var favouriteLocations : LocationService? //[(type : String,address: [LocationDetail])]() // Favourite Locations of User
    var slatitude = "43.651070"
    var slongitude = "-79.347015"
    
    var currentLocation = Bind<LocationCoordinate>(defaultMapLocation)
    
    var isRateViewShowed:Bool = false
    var isInvoiceShowed:Bool = false
    //var serviceSelectionView : ServiceSelectionView?
    var estimationFareView : RequestSelectionView?
    var couponView : CouponView?
    var locationSelectionView : LocationSelectionView?
    var requestLoaderView : LoaderView?
    var rideStatusView : RideStatusView? {
        didSet {
            if self.rideStatusView == nil {
                //self.floatyButton?.removeFromSuperview()
                self.msgButton?.removeFromSuperview()
            }
        }
    }
   
    var invoiceView : InvoiceView?
    var ratingView : RatingView?
    var rideNowView : RideNowView?
    var floatyButton : Floaty?
    var msgButton: Button?
    var reasonView : ReasonView?
    var walletAlertView:WalletAlertView?
    
    lazy var loader  : UIView = {
        return createActivityIndicator(self.view)
    }()
    
    var currentRequestId = 0
    var timerETA : Timer?
    private var isScheduled = false // Flag For Schedule
    
    //MARKERS
    
    var sourceMarker : GMSMarker = {
        let marker = GMSMarker()
        marker.title = Constants.string.ETA.localize()
        print(Constants.string.ETA.localize())
        marker.appearAnimation = .pop
        marker.icon =  #imageLiteral(resourceName: "sourcePin").resizeImage(newWidth: 30)
        return marker
    }()
    
    private var destinationMarker : GMSMarker = {
        let marker = GMSMarker()
        marker.appearAnimation = .pop
        marker.icon =  #imageLiteral(resourceName: "destinationPin").resizeImage(newWidth: 30)
        return marker
    }()
    
    var markersProviders = [GMSMarker]()
    
    // MARK:- Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let heightOfSuperview = self.view.bounds.height
        self.navigationController?.isNavigationBarHidden = true
        self.initialLoads()
        
        self.localize()
        print("riderstatus>>>>>.",riderStatus)
        riderStatus = .none
        cashImage.image = UIImage(named: "cash_black")
        cardImage.image = UIImage(named: "card_white")
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotification(notification:)), name: Notification.Name("message"), object: nil)
        downButton.isUserInteractionEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewWillAppearCustom()
        NotificationCenter.default.addObserver(self, selector: #selector(isChatPushRedirection), name: NSNotification.Name("ChatPushRedirection"), object: nil)
        
//        offerView.isHidden = false
//        offerView.alpha = 1
//        offerCancelButton.isHidden = false
        //IQKeyboardManager.shared.enable = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if  User.main.isShowOutstanding{
             self.showOutstandingAlertView()
        }
    }
    
    @objc func handleNotification(notification: Notification) {
        print("message noti")
        self.rideStatusView?.messageBadgeView.isHidden = false
    }
   
    @objc func isChatPushRedirection() {
        self.rideStatusView?.messageBadgeView.isHidden = true

        if let ChatPage = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.SingleChatController) as? SingleChatController {
            ChatPage.set(user: self.currentProvider ?? Provider(), requestId: self.currentRequestId)
            //ChatPage.startObservers()
            let navigation = UINavigationController(rootViewController: ChatPage)
            self.present(navigation, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.viewLayouts()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
                changeInterfaceStyle()
            }
        } else {
            changeInterfaceStyle()
        }
    }
    
    func changeInterfaceStyle(){
        
        if #available(iOS 12.0, *) {
            
            if traitCollection.userInterfaceStyle == .dark{
                mapViewHelper.traitHasBeenChanged(interfaceStyle: .dark)
            }else{
                mapViewHelper.traitHasBeenChanged(interfaceStyle: .light)
            }
            
        }
    }
    
    @IBAction func addStopBtnTapped(_ sender: UIButton) {
        locationSelectionTapAction()
    }
    @IBAction func singleBtnTapped(_ sender: UIButton) {
        self.isRoundTrip = false
        self.singleTripButton.setTitleColor(.white, for: .normal)
        self.singleTripButton.backgroundColor = .black
        self.roundTripButton.setTitleColor(.black, for: .normal)
        self.roundTripButton.backgroundColor = .white
        self.tripTypeLabel.text = "Single Trip"

        sendRequest()
        
    }
  
    @IBAction func offerCancelBtnTapped(_ sender: UIButton) {
        topRideDetailView.alpha = 0
        bottomRaiseView.alpha = 0
        offerCancelButton.alpha = 0
        offerCancelButton.alpha = 0
        driverFindingLabel.alpha = 0
        self.cancelRequest()
    }
    @IBAction func sendRaiseSubmBtnTapped(_ sender: UIButton) {
        self.cancelRequest()
       // sendRequest()

    }
    @IBAction func downFareBtnTapped(_ sender: UIButton) {
        if curOfferAmountByUser > self.firtstimatedFare {
            curOfferAmountByUser = curOfferAmountByUser - 1
        }
        tripCurrentFareLabel.text = "C$\(curOfferAmountByUser)"
    }
    @IBAction func raiseFateBtnTapped(_ sender: UIButton) {
        // request sent
        downButton.isUserInteractionEnabled = true

        curOfferAmountByUser = curOfferAmountByUser + 1
        tripCurrentFareLabel.text = "C$\(curOfferAmountByUser)"

    }
    @IBAction func roundTripBtnTapped(_ sender: UIButton) {
        self.isRoundTrip = true
        self.singleTripButton.setTitleColor(.black, for: .normal)
        self.singleTripButton.backgroundColor = .white
        self.roundTripButton.setTitleColor(.white, for: .normal)
        self.roundTripButton.backgroundColor = .black
        //sendRequest()
        self.popUpwaitTime()
        self.tripTypeLabel.text = "Round Trip"
        self.isAlreadyPopulated = false
    }
    @IBAction func cashBtnTapped(_ sender: UIButton) {
        

        cashImage.image = UIImage(named: "cash_black")

        cardImage.image = UIImage(named: "card_white")
        self.newPaymentType = .CASH

    }
    @IBAction func cardBtnTapped(_ sender: UIButton) {
        cashImage.image = UIImage(named: "cash_white")
        cardImage.image = UIImage(named: "card_black")
        UIApplication.shared.keyWindow?.make(toast: Constants.string.selectCardToContinue.localize())
        self.newPaymentType = .CARD

    }
    @IBAction func offerCancelBtnTapped1(_ sender: UIButton) {
        //offerView.isHidden.toggle()
        offerView.alpha = 0
        offerCancelButton.alpha = 0
    }
    
    @IBAction func cancelRideBtnTapped(_ sender: UIButton) {
    }
    func sendRequest(){
        UserDefaults.standard.setValue(true, forKey: "onRide")
        self.service?.round_trip = 0
        
        if curOfferAmountByUser ==  0.0 {
            self.showToast(string: "Please enter your offer price")
            return
        }
         
        guard let service = self.selectedService else {
            self.showToast(string: "Please select")

            return
        }
        
     
        //self.tripCurrentFareLabel.text = "C$\(curOfferAmountByUser)"
        
        self.createRequest(for: service, isScheduled: false, scheduleDate: nil, cardEntity: nil, paymentType: self.newPaymentType, price: self.curOfferAmountByUser.precised(2))
    }
}



// MARK:- Methods


extension HomeViewController {
    func resetAll()
    {
     print("Reset")
        //self.textFieldSourceLocation.text = ""
        mapViewHelper.getCurrentLocation(onReceivingLocation: { (location) in
            print("Reset In the location")
            self.mapViewHelper.moveTo(location: LocationCoordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), with: self.viewMapOuter.center)
            
            self.mapViewHelper.getPlaceAddress(from: location.coordinate, on: { (locationDetail) in  // On Tapping current location, set
                DispatchQueue.main.async {
                    
                    //self.textFieldSourceLocation.text = locationDetail.address
                    self.sourceLocationDetail?.value = locationDetail
                }
                
            })
        })
        
        
    }
    private func initialLoads() {
        localSelectionParentView.alpha = 0
        vehicleCollectionView.register(UINib(nibName: "VehicleColCell", bundle: nil), forCellWithReuseIdentifier: "VehicleColCell")
        vehicleCollectionView.inset = 50
        vehicleCollectionView.delegate = self
        vehicleCollectionView.dataSource = self
        priceTextfield.delegate = self
        offerTableView.register(UINib(nibName: "OfferCell", bundle: nil), forCellReuseIdentifier: "OfferCell")
//        localSelectionParentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(locationSelectionTapAction)))
//
        addressVieww.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(locationSelectionTapAction)))
      
        let lat =   currentLocation.value?.latitude
        
        UserDefaults.standard.set(lat, forKey: "lat")
        let long =   currentLocation.value?.longitude
        UserDefaults.standard.set(long, forKey: "long")
        
        self.addMapView()
        self.getFavouriteLocations()
        sideMenuBtn.addTarget(self, action: #selector(sideMenuAction), for: .touchUpInside)
        //            self.navigationController?.isNavigationBarHidden = true
        //            self.viewFavouriteDestination.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.favouriteLocationAction(sender:))))
        //            self.viewFavouriteSource.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.favouriteLocationAction(sender:))))
        
        self.currentLocation.bind(listener: { (locationCoordinate) in
            // TODO:- Handle Current Location
            
            if locationCoordinate != nil {
                self.mapViewHelper.moveTo(location: LocationCoordinate(latitude: locationCoordinate!.latitude, longitude: locationCoordinate!.longitude), with: self.viewMapOuter.center)
            }
        })
        gpsBtn.addTarget(self, action: #selector(getCurrentLocation), for: .touchUpInside)
        self.sourceLocationDetail?.bind(listener: { (locationDetail) in
            //                if locationDetail == nil {
            //                    self.isSourceFavourited = false
            //                }
            let sourceAddress = locationDetail?.address
            
            if self.updateStatus != .accepted && self.updateStatus != .started && self.updateStatus != .arrived && self.updateStatus != .pickedup && self.updateStatus != .searching {
                DispatchQueue.main.async {
                    
                    self.sourceAddressLabel.text = sourceAddress
                    //self.isSourceFavourited = false // reset favourite location on change
                    
                    
                }
                
            }
        })
        
        self.checkForProviderStatus()
        
        self.buttonSOS.isHidden = true
        
        self.buttonSOS.addTarget(self, action: #selector(self.buttonSOSAction), for: .touchUpInside)
        
        self.changeDestinationButton.isHidden = true
        
        self.changeDestinationButton.addTarget(self, action: #selector(self.changeDestinationAction), for: .touchUpInside)
        self.setDesign()
        NotificationCenter.default.addObserver(self, selector: #selector(self.observer(notification:)), name: .providers, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.networkChanged(notification:)), name: NSNotification.Name.reachabilityChanged, object: nil)
        
        //            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShowRateView(info:)), name: .UIKeyboardWillShow, object: nil)
        //            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHideRateView(info:)), name: .UIKeyboardWillHide, object: nil)      }
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        
    }
    
    // MARK:- View Will appear
    
    private func viewWillAppearCustom() {
        
        self.presenter?.get(api: .getProfile, parameters: nil)
        
        isRateViewShowed = false
        isInvoiceShowed = false
        self.navigationController?.isNavigationBarHidden = true
        //self.localize()
        self.getFavouriteLocationsFromLocal()
        
        print("wallet ballance \(User.main.wallet_balance ?? 0.00)")
        
    }
    
    // MARK: - PROVIDERS LIST
    
    private func getProviders(){
        DispatchQueue.global(qos: .background).async {
          //  guard let currentLoc = self.sourceCoordinate .value  else { return }
            let json = [Constants.string.latitude : self.currentLocation.value?.latitude ?? 0.0, Constants.string.longitude : self.currentLocation.value?.longitude ?? 0.0] as [String : Any]
                self.presenter?.get(api: .getProviders, parameters: json)
        }
    }
    
    // MARK:- View Will Layouts
    
    private func viewLayouts() {
        self.mapViewHelper.mapView?.frame = viewMapOuter.bounds
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @objc func getCurrentLocation(){
        gpsBtn.addPressAnimation()
        mapViewHelper.getCurrentLocation(onReceivingLocation: { (location) in
            self.mapViewHelper.moveTo(location: location.coordinate, with: self.viewMapOuter.center)
            self.mapViewHelper.getPlaceAddress(from: location.coordinate, on: { (locationDetail) in  // On Tapping current location, set
                DispatchQueue.main.async {
                    //self.sourceAddressLabel.text = locationDetail.address
                    self.sourceLocationDetail?.value = locationDetail
                }
            })
        })
    }
    
    // MARK:- Localize
    
    private func localize(){
    }
    
    // MARK:- Set Design
    
    private func setDesign() {
    }
    
    // MARK:- Add Mapview
    
    private func addMapView(){
        
        self.mapViewHelper = GoogleMapsHelper()
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark{
                self.mapViewHelper.getMapView(withDelegate: self, in: self.viewMapOuter, interfaceStyle: .dark)
            }else{
                self.mapViewHelper.getMapView(withDelegate: self, in: self.viewMapOuter, interfaceStyle: .light)
            }
        } else {
            self.mapViewHelper.getMapView(withDelegate: self, in: self.viewMapOuter, interfaceStyle: .light)
        }
        self.getCurrentLocationDetails()
    }
    
    
    
    private func showToast(string : String?) {
        
        self.view.makeToast(string, point: CGPoint(x: UIScreen.main.bounds.width/2 , y: UIScreen.main.bounds.height/2), title: nil, image: nil, completion: nil)
        
    }
    //Getting current location detail
    func getCurrentLocationDetails() {
        self.mapViewHelper.getCurrentLocation(onReceivingLocation: { (location) in
            
            
            
            print("Current LOC ")
            //  self.showToast(string: "\(location.coordinate.latitude)")
            
            
            self.perKmUpdateRouteCheck(newLocation: location)
            
            
            if self.sourceLocationDetail?.value == nil {
                self.mapViewHelper.getPlaceAddress(from: location.coordinate, on: { (locationDetail) in
                    DispatchQueue.main.async {
                        
                        self.sourceAddressLabel.text = locationDetail.address
                        self.sourceLocationDetail?.value = locationDetail
                    }
                    
                })
            }
            self.currentLocation.value = location.coordinate
        })
    }
    
    // MARK:- Observer
    
    @objc private func observer(notification : Notification) {
        
        if notification.name == .providers, let serviceArray = notification.userInfo?[Notification.Name.providers.rawValue] as? [Service] {
            showProviderInCurrentLocation(with: serviceArray)
        }
        
    }
    
    
    // MARK:- Get Favourite Location From Local
    
    private func getFavouriteLocationsFromLocal() {
        
        let favouriteLocationFromLocal = CoreDataHelper().favouriteLocations()
        [self.viewHomeLocation, self.viewWorkLocation].forEach({
            $0?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewLocationButtonAction(sender:))))
            $0?.isHidden = true
        })
        for location in favouriteLocationFromLocal
        {
            switch location.key {
            case CoreDataEntity.work.rawValue where location.value is Work:
                if let workObject = location.value as? Work, let address = workObject.address {
                    if let index = favouriteLocations.firstIndex(where: { $0.address == Constants.string.work}) {
                        favouriteLocations[index] = (location.key, (address, LocationCoordinate(latitude: workObject.latitude, longitude: workObject.longitude)))
                    } else {
                        favouriteLocations.append((location.key, (address, LocationCoordinate(latitude: workObject.latitude, longitude: workObject.longitude))))
                    }
                    self.viewWorkLocation.isHidden = false
                }
            case CoreDataEntity.home.rawValue where location.value is Home:
                if let homeObject = location.value as? Home, let address = homeObject.address {
                    if let index = favouriteLocations.firstIndex(where: { $0.address == Constants.string.home}) {
                        favouriteLocations[index] = (location.key, (address, LocationCoordinate(latitude: homeObject.latitude, longitude: homeObject.longitude)))
                    } else {
                        favouriteLocations.append((location.key, (address, LocationCoordinate(latitude: homeObject.latitude, longitude: homeObject.longitude))))
                    }
                    self.viewHomeLocation.isHidden = false
                }
            default:
                break
                
            }
        }
    }
    
    // MARK:- View Location Action
    
    @IBAction private func viewLocationButtonAction(sender : UITapGestureRecognizer) {
        
        guard let senderView = sender.view else { return }
        self.positions = [Bind<LocationDetail>(nil)]
        if senderView == viewHomeLocation, let location = CoreDataHelper().favouriteLocations()[CoreDataEntity.home.rawValue] as? Home, let addressString = location.address {
            self.positions?[0].value = (addressString, LocationCoordinate(latitude: location.latitude, longitude: location.longitude))
        } else if senderView == viewWorkLocation, let location = CoreDataHelper().favouriteLocations()[CoreDataEntity.work.rawValue] as? Work, let addressString = location.address {
            self.positions?[0].value = (addressString, LocationCoordinate(latitude: location.latitude, longitude: location.longitude))
        }
        
        if positions == nil { // No Previous Location Avaliable
            self.showLocationView()
        } else {
            
            self.drawPolyline(isReroute: false) // Draw polyline between source and destination
          //  self.getServicesList() // get Services
        }
        
    }
    
    
    // MARK:- Favourite Location Action
    
    //        @IBAction private func favouriteLocationAction(sender : UITapGestureRecognizer) {
    //
    //            guard let senderView = sender.view else { return }
    //            senderView.addPressAnimation()
    //            if senderView == viewFavouriteSource {
    //                self.isSourceFavourited = self.sourceLocationDetail?.value != nil ? !self.isSourceFavourited : false
    //            } else if senderView == viewFavouriteDestination {
    //                self.isDestinationFavourited = self.destinationLocationDetail != nil ? !self.isDestinationFavourited : false
    //            }
    //        }
    
    // MARK:- Favourite Location Action
    
    //        private func isAddFavouriteLocation(in viewFavourite : UIView, isAdd : Bool) {
    //
    //            if viewFavourite == viewFavouriteSource {
    //                self.imageViewFavouriteSource.image = (isAdd ? #imageLiteral(resourceName: "like") : #imageLiteral(resourceName: "unlike")).withRenderingMode(.alwaysTemplate)
    //            } else {
    //                self.imageViewFavouriteDestination.image = (isAdd ? #imageLiteral(resourceName: "like") : #imageLiteral(resourceName: "unlike")).withRenderingMode(.alwaysTemplate)
    //            }
    //            self.favouriteLocationApi(in: viewFavourite, isAdd: isAdd) // Send to Api Call
    //
    //        }
    
    // MARK:- Favourite Location Action
    
    @objc func locationSelectionTapAction() {
        
        if  User.main.isShowOutstanding{
             self.showOutstandingAlertView()
            return
        }
        
        if riderStatus != .none {
            // Ignore if user is onRide and trying to change source location
            return
        }
        
        self.showLocationView()
    }
    
    private func plotMarker(marker : inout GMSMarker, with coordinate : CLLocationCoordinate2D){
        
        marker.position = coordinate
        marker.map = self.mapViewHelper.mapView
        //            self.mapViewHelper?.mapView?.animate(toLocation: coordinate)
    }
    
    
    // MARK:- Show Location View
    
    @IBAction private func showLocationView() {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MultiLocationSelectionViewController") as! MultiLocationSelectionViewController
        
        vc.mapViewHelper = mapViewHelper
        vc.delegate = self
        
        if self.positions != nil
        {
            vc.destinationLocationDetail = self.positions
            vc.numberOfRows = self.positions?.count ?? 0
        }
        
        vc.callback = { [weak self] (positions,source)in
            
            guard let self = self else { return }
            
            if positions.count > 1 {
                self.moreLabel.text = "+\(positions.count - 1) more"
            }
//            DispatchQueue.main.async {
//                self.callFareApi(index: 0)
//
//            }
            
            self.vehicleCollectionView.isHidden = false
            self.vehicleCollectionView.alpha = 1
            
            let p  = positions[0].value!.coordinate
            let p1 = self.sourceLocationDetail!.value!.coordinate
            self.currentUserMapLocatio = p1
            let l1 = CLLocationCoordinate2D(latitude: p.latitude, longitude: p.longitude)
            let l2 = CLLocationCoordinate2D(latitude: p1.latitude, longitude: p1.longitude)

            self.mapViewHelper.mapView?.getNewEstimation(between: l1, to: l2) { time, dis in
                DispatchQueue.main.async {
                    print("time:\(time), dis:\(dis)")
                    self.tripDistanceLabel.text = dis
                    self.tripTimeLAbel.text = time
                    self.mileLabel.text = dis
                    self.timeLAbel.text = time
                }
               
            }
            self.positions = positions
            self.sourceLocationDetail = source
            self.drawPolyline(isReroute: false)
            
            if [RideStatus.accepted, .arrived, .pickedup, .started].contains(riderStatus) {
                if let dAddress = positions[0].value?.address, let coordinate = positions[0].value?.coordinate {
                    self.updateLocation(with: (dAddress,coordinate))
                }
            } else {
                self.removeUnnecessaryView(with: .cancelled) // Remove services or ride now if previously open
                self.getServicesList() // get Services
            }
            
            if self.sourceLocationDetail != nil
            {
                self.sourceAddressLabel.text = self.sourceLocationDetail?.value?.address
            }
            
            if let positi = self.positions
            {
                let count = positi.count
                
                if count == 1{
                    if let stop1 = positi[0].value?.address
                    {
                        self.stop1AddressLabel.text = stop1
                        self.stop2StackView?.isHidden = true
                        self.stop3StackView?.isHidden = true
                        self.stop2AddressLabel?.text = ""
                        self.stop3AddressLabel?.text = ""
                    }
                }else if count == 2{
                    if let stop1 = positi[0].value?.address
                    {
                        self.stop1AddressLabel.text = stop1
                    }
                    if let stop2 = positi[1].value?.address
                    {
                        self.stop2AddressLabel?.text = stop2
                        
                    }
                    self.stop2StackView?.isHidden = false
                    self.stop3StackView?.isHidden = true
                    self.stop3AddressLabel?.text = ""
                }else if count == 3{
                    if let stop1 = positi[0].value?.address
                    {
                        self.stop1AddressLabel.text = stop1
                    }
                    if let stop2 = positi[1].value?.address
                    {
                        self.stop2AddressLabel.text = stop2
                    }
                    if let stop3 = positi[2].value?.address
                    {
                        self.stop3AddressLabel.text = stop3
                    }
                    self.stop2StackView.isHidden = false
                    self.stop3StackView.isHidden = false
                }
            }
            
            
        }
        
        vc.sourceLocationDetail = self.sourceLocationDetail
        
        
        self.navigationController?.pushViewController(vc, animated: true)
        
        
        
        //            if let locationView = Bundle.main.loadNibNamed(XIB.Names.LocationSelectionView, owner: self, options: [:])?.first as? LocationSelectionView {
        //                locationView.frame = self.view.bounds
        //                locationView.setValues(address: (sourceLocationDetail,destinationLocationDetail)) { [weak self] (address) in
        //                    guard let self = self else {return}
        //                    self.sourceLocationDetail = address.source
        //                    self.destinationLocationDetail = address.destination
        //                    // print("\nselected-->>>>>",self.sourceLocationDetail?.value?.coordinate, self.destinationLocationDetail?.coordinate)
        //                    self.drawPolyline(isReroute: false) // Draw polyline between source and destination
        //                    if [RideStatus.accepted, .arrived, .pickedup, .started].contains(riderStatus) {
        //                        if let dAddress = address.destination?.address, let coordinate = address.destination?.coordinate {
        //                            self.updateLocation(with: (dAddress,coordinate))
        //                        }
        //                    } else {
        //                        self.removeUnnecessaryView(with: .cancelled) // Remove services or ride now if previously open
        //                        self.getServicesList() // get Services
        //                    }
        //                }
        //                self.view.addSubview(locationView)
        //                if selectedLocationView == self.viewSourceLocation {
        //                    locationView.textFieldSource.becomeFirstResponder()
        //                } else {
        //                    locationView.textFieldDestination.becomeFirstResponder()
        //                }
        //                self.selectedLocationView.transform = .identity
        //                self.selectedLocationView = UIView()
        //                self.locationSelectionView = locationView
        //            }
        
    }
    func showWalletVC(){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WalletViewController") as! WalletViewController
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    // MARK:- Remove Location VIew
    
    func removeLocationView() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.locationSelectionView?.tableViewBottom.frame.origin.y = (self.locationSelectionView?.tableViewBottom.frame.height) ?? 0
            self.locationSelectionView?.viewTop.frame.origin.y = -(self.locationSelectionView?.viewTop.frame.height ?? 0)
        }) { (_) in
            self.locationSelectionView?.isHidden = true
            self.locationSelectionView?.removeFromSuperview()
            self.locationSelectionView = nil
        }
        
    }
    func updatePolyline()
    {
        if (Global.shared.isPickup && Global.shared.isStarted)
        {
            
            /* New Added*/
            if !isPDRouteTrigged{
                resetCheck()
                print("IS PD Called")
                
                isPDRouteTrigged = true
            }
            /* Till Here */
            
            //MARK:- set Marker for source and destination
            self.drawPoly(s_latitude: Global.shared.driver_lat, s_longtitude: Global.shared.driver_long, d_latitude: Global.shared.destinationLatitde, d_longtitude: Global.shared.destinationLontitude)
            
            //            self.setMarker(sourceLat: c_lat, sourceLong: c_long, destinationLat: Global.shared.destinationLatitde, destinationLong: Global.shared.destinationLontitude)
        }
        else if (Global.shared.isStarted)
        {
            /* New Added*/
            if !isCPRouteTrigged{
                
                print("IS CP Called")
                
                
                resetCheck()
                isCPRouteTrigged = true
            }
            /* Till Here */
            
            
            //MARK:- set Marker for source and destination
            
            self.drawPoly(s_latitude: Global.shared.driver_lat, s_longtitude: Global.shared.driver_long, d_latitude: Global.shared.sourceLatitute, d_longtitude: Global.shared.sourceLongtitude)
            //            self.setMarker(sourceLat: c_lat, sourceLong: c_long, destinationLat: Global.shared.sourceLongtitude, destinationLong: Global.shared.sourceLongtitude)
        }
    }
    
    //MARK:- Draw Polyline
    
    func drawPoly(s_latitude: Double?, s_longtitude : Double?, d_latitude: Double?, d_longtitude: Double?){
        
        
        if updateRoute{
            //enter code here
            let polyLineSource = CLLocationCoordinate2D(latitude: s_latitude! , longitude: s_longtitude!)
            let polyLineDestination = CLLocationCoordinate2D(latitude: d_latitude!, longitude: d_longtitude!)
            //        self.plotMarker(marker: &sourceMarker, with: polyLineSource)
            sourceMarker.map = nil
            self.plotMarker(marker: &destinationMarker, with: polyLineDestination)
            self.mapViewHelper.mapView?.drawPolygon(from:polyLineSource , to: polyLineDestination)
            
            self.updateRoute = false
        }
        
        
        
        
        
        
        
    }
    
    func drawPolyline(isReroute:Bool) {
        
        let currentuser =   UserDefaults.standard.string(forKey: "location")
        var pointsArr = currentuser?.components(separatedBy: ",")
        print("latituude>>>>",pointsArr?[0] as Any)
        print("longitude>>>>",pointsArr?[1] as Any)
        
        var currentLocationvalue:CLLocationCoordinate2D! //location object
        
        currentLocationvalue = CLLocationCoordinate2D(latitude:pointsArr?[0].toDouble() ?? 0.0, longitude: pointsArr?[1].toDouble() ?? 0.0)
        self.imageViewMarkerCenter.isHidden = true
        //            if var sourceCoordinate = self.sourceLocationDetail?.value?.coordinate,
        //                let destinationCoordinate = self.positions?[0].value?.coordinate {  // Draw polyline from source to destination
        //                self.mapViewHelper?.mapView?.clear()
        //                self.sourceMarker.map = self.mapViewHelper?.mapView
        //                self.destinationMarker.map = self.mapViewHelper?.mapView
        //                if isReroute{
        //                    let coordinate = CLLocationCoordinate2D(latitude: (currentLocation.value?.latitude)!, longitude: (currentLocation.value?.longitude)!)
        //                    sourceCoordinate = coordinate
        //                }
        //                // let cord: CLLocationCoordinate2D = UserDefaults.standard.value(forKey: "location") as! CLLocationCoordinate2D
        //
        //                self.sourceMarker.position = sourceCoordinate
        //                self.destinationMarker.position = destinationCoordinate
        //                //self.selectionViewAction(in: self.viewSourceLocation)
        //                //self.selectionViewAction(in: self.viewDestinationLocation)
        //                self.mapViewHelper?.mapView?.drawPolygon(from:sourceCoordinate , to: destinationCoordinate)
        //                self.selectedLocationView = UIView()
        //            }
        
        //            0...self.positions!.count - 1
        
        if let post = self.positions{
            for (index,posit) in post.enumerated(){
                if index == 0{
                    if var sourceCoordinate = self.sourceLocationDetail?.value?.coordinate,
                       let destinationCoordinate = posit.value?.coordinate{  // Draw polyline from source to destination
                        self.mapViewHelper.mapView?.clear()
                        self.sourceMarker.map = self.mapViewHelper.mapView
                        self.destinationMarker.map = self.mapViewHelper.mapView
                        if isReroute{
                            let coordinate = CLLocationCoordinate2D(latitude: (currentLocation.value?.latitude)!, longitude: (currentLocation.value?.longitude)!)
                            sourceCoordinate = coordinate
                        }
                        // let cord: CLLocationCoordinate2D = UserDefaults.standard.value(forKey: "location") as! CLLocationCoordinate2D
                        
                        self.sourceMarker.position = sourceCoordinate
                        self.destinationMarker.position = destinationCoordinate
                        //self.selectionViewAction(in: self.viewSourceLocation)
                        //self.selectionViewAction(in: self.viewDestinationLocation)
                        self.mapViewHelper.mapView?.drawPolygon(from:sourceCoordinate , to: destinationCoordinate)
                        
                    }
                }
                else{
                    if let sourceCoordinate = self.positions?[index - 1].value?.coordinate,
                       let destinationCoordinate = posit.value?.coordinate{  // Draw polyline from source to destination
                        //                            self.mapViewHelper?.mapView?.clear()
                        //                            self.sourceMarker.map = self.mapViewHelper?.mapView
                        self.destinationMarker.map = self.mapViewHelper.mapView
                        //                            if isReroute{
                        //                                let coordinate = CLLocationCoordinate2D(latitude: (currentLocation.value?.latitude)!, longitude: (currentLocation.value?.longitude)!)
                        //                                sourceCoordinate = coordinate
                        //                            }
                        // let cord: CLLocationCoordinate2D = UserDefaults.standard.value(forKey: "location") as! CLLocationCoordinate2D
                        
                        //                            self.sourceMarker.position = sourceCoordinate
                        self.destinationMarker.position = destinationCoordinate
                        //self.selectionViewAction(in: self.viewSourceLocation)
                        //self.selectionViewAction(in: self.viewDestinationLocation)
                        self.addMarker(coordinates: sourceCoordinate)
                        self.mapViewHelper.mapView?.drawPolygon(from:sourceCoordinate , to: destinationCoordinate)
                        
                    }
                }
                
            }
        }
    }
    
    func addMarker(coordinates: CLLocationCoordinate2D){
        let marker = GMSMarker()
        marker.position = coordinates
        marker.title = "ETA1"
        marker.icon =  #imageLiteral(resourceName: "sourcePin").resizeImage(newWidth: 30)
        marker.map = self.mapViewHelper.mapView
    }
    
    // MARK:- Get Favourite Locations
    
    private func getFavouriteLocations(){
        
        favouriteLocations.append((Constants.string.home,nil))
        favouriteLocations.append((Constants.string.work,nil))
        self.presenter?.get(api: .locationService, parameters: nil)
        
    }
    
    // MARK:- Cancel Request if it exceeds a certain interval
    
    @IBAction func validateRequest() {
        
        if riderStatus == .searching {
            UIApplication.shared.keyWindow?.makeToast(Constants.string.noDriversFound.localize())
            self.cancelRequest()
            
        }
    }
    
    
    // MARK:- SideMenu Button Action
    
    @IBAction private func sideMenuAction(){
        if self.topRideDetailView.alpha == 1{
            self.cancelRequest()
        }

        sideMenuBtn.addPressAnimation()
        
        if self.isOnBooking { // If User is on Ride Selection remove all view and make it to default
            UserDefaults.standard.setValue(false, forKey: "onRide")
            self.clearAllView()
            print("ViewAddressOuter ", #function)
        } else {
            self.drawerController?.openSide(selectedLanguage == .arabic ? .right : .left)
        }
        
        
    }
    
    // Clear Map
    
    func clearAllView() {
        
        
//        self.getCurrentLocationDetails()
        self.positions = [Bind<LocationDetail>(nil)]
        self.stop1AddressLabel.text = "Where to?"
        stop2AddressLabel?.text = ""
        stop3AddressLabel?.text = ""
        stop2StackView?.isHidden = true
        stop3StackView?.isHidden = true
        
        self.removeLoaderView()
        self.removeUnnecessaryView(with: .cancelled)
        self.clearMapview()
        self.viewLocationButtons.isHidden = false
        self.topRideDetailView.alpha = 0
        self.bottomRaiseView.alpha = 0
        self.offerView.alpha = 0
        self.priceTextfield.text = ""
        self.timeLAbel.text = "-"
        self.mileLabel.text = "-"
        self.selectedService = nil
        self.selectedVehIndex = -1
        self.curOfferAmountByUser = 0.0
        offerCancelButton.alpha = 0
        driverFindingLabel.alpha = 0
        self.moreLabel.text = ""
    }
    
    
    // MARK:- Show DateTimePicker
    
    func schedulePickerView(on completion : @escaping ((Date)->())){
        
        var dateComponents = DateComponents()
        dateComponents.day = 7
        let now = Date()
        let maximumDate = Calendar.current.date(byAdding: dateComponents, to: now)
        dateComponents.minute = 5
        dateComponents.day = nil
        let minimumDate = Calendar.current.date(byAdding: dateComponents, to: now)
        let datePicker = DateTimePicker.create(minimumDate: minimumDate, maximumDate: maximumDate)
        datePicker.includesMonth = true
        datePicker.cancelButtonTitle = Constants.string.Cancel.localize()
        
        datePicker.doneButtonTitle = Constants.string.Done.localize()
        datePicker.is12HourFormat = true
        datePicker.dateFormat = DateFormat.list.hhmmddMMMyyyy
        datePicker.highlightColor = .primary
        datePicker.doneBackgroundColor = .secondary
        
        datePicker.completionHandler = { date in
            completion(date)
            print(date)
        }
        datePicker.show()
    }
    
    
    // MARK:- Observe Network Changes
    @objc private func networkChanged(notification : Notification) {
        if let reachability = notification.object as? Reachability, ([Reachability.Connection.cellular, .wifi].contains(reachability.connection)) {
            self.getCurrentLocationDetails()
        }
    }
    
}

// MARK:- MapView

extension HomeViewController : GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        if self.isUserInteractingWithMap {
            
            func getUpdate(on location : CLLocationCoordinate2D, completion :@escaping ((LocationDetail)->Void)) {
                self.drawPolyline(isReroute: false)
           //     self.getServicesList()
                self.mapViewHelper.getPlaceAddress(from: location, on: { (locationDetail) in
                    completion(locationDetail)
                })
            }
            
            //                if self.sourceLocationDetail != nil {
            //
            //                    if let location = mapViewHelper.mapView?.projection.coordinate(for: viewMapOuter.center) {
            //                        self.sourceLocationDetail?.value?.coordinate = location
            //                        getUpdate(on: location) { (locationDetail) in
            //                            self.sourceLocationDetail?.value = locationDetail
            //                        }
            //                    }
            //                } else if self.destinationLocationDetail != nil {
            //
            //                    if let location = mapViewHelper.mapView?.projection.coordinate(for: viewMapOuter.center) {
            //                        self.destinationLocationDetail?.coordinate = location
            //                        getUpdate(on: location) { (locationDetail) in
            //                            self.destinationLocationDetail = locationDetail
            //                            self.updateLocation(with: locationDetail) // Update Request Destination Location
            //                        }
            //                    }
            //                }
        }
        self.isMapInteracted(false)
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
        print("Gesture ",gesture)
        self.isUserInteractingWithMap = gesture
        
        if self.isUserInteractingWithMap {
            self.isMapInteracted(true)
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        // return
        
        //            if isUserInteractingWithMap {
        //
        //                if self.sourceLocationDetail != nil {
        //
        //                    self.sourceMarker.map = nil
        //                    self.imageViewMarkerCenter.tintColor = .secondary
        //                    self.imageViewMarkerCenter.image = #imageLiteral(resourceName: "sourcePin").withRenderingMode(.alwaysTemplate)
        //                    self.imageViewMarkerCenter.isHidden = false
        //                    //                if let location = mapViewHelper?.mapView?.projection.coordinate(for: viewMapOuter.center) {
        //                    //                    self.sourceLocationDetail?.value?.coordinate = location
        //                    //                    self.mapViewHelper?.getPlaceAddress(from: location, on: { (locationDetail) in
        //                    //                        print(locationDetail)
        //                    //                        self.sourceLocationDetail?.value = locationDetail
        //                    ////                        let sLocation = self.sourceLocationDetail
        //                    ////                        self.sourceLocationDetail = sLocation
        //                    //                    })
        //                    //                }
        //
        //
        //                } else if self.destinationLocationDetail != nil {
        //
        //                    self.destinationMarker.map = nil
        //                    self.imageViewMarkerCenter.tintColor = .primary
        //                    self.imageViewMarkerCenter.image = #imageLiteral(resourceName: "destinationPin").withRenderingMode(.alwaysTemplate)
        //                    self.imageViewMarkerCenter.isHidden = false
        //                    //                if let location = mapViewHelper?.mapView?.projection.coordinate(for: viewMapOuter.center) {
        //                    //                    self.destinationLocationDetail?.coordinate = location
        //                    //                    self.mapViewHelper?.getPlaceAddress(from: location, on: { (locationDetail) in
        //                    //                        print(locationDetail)
        //                    //                        self.destinationLocationDetail = locationDetail
        //                    //                    })
        //                    //                }
        //                }
        //
        //            }
        //            //        else {
        //            //            self.destinationMarker.map = self.mapViewHelper?.mapView
        //            //            self.sourceMarker.map = self.mapViewHelper?.mapView
        //            //            self.imageViewMarkerCenter.isHidden = true
        //            //        }
        //
    }
    
    func hideSEarchRideView(isHide:Bool){
        if isHide {
     
            self.clearAllView()
        }else{
            self.bottomRaiseView.alpha =  1
            self.topRideDetailView.alpha = 1
            self.roundTripViewBottomConstriant.constant = 20
            offerCancelButton.alpha = 1
            driverFindingLabel.alpha = 1
        }
    }
    
}

// MARK:- Service Calls

extension HomeViewController  {
    
    // Check For Service Status
    
    private func checkForProviderStatus() {
        
        HomePageHelper.shared.startListening(on: { [weak self] (error, requestModel , offers) in
            
            guard let self = self else {
                return
            }
            
            //List of all available providers
            self.getProviders()
            var currentStatus : RideStatus = .none
            if let r =  requestModel?.data?.first {
                self.currntRequest = r
               // self.setEstimation()
//                self.bottomRaiseView.alpha =  1
//                self.topRideDetailView.alpha = 1
//                self.roundTripViewBottomConstriant.constant = -80
//
                 currentStatus = r.status ?? .none
                print("ride_Status: \(currentStatus)")
                //self.offers = requestModel?.requests ?? []
                
                let rs = requestModel?.requests ?? []
                
                self.offers.forEach { r in
                    
                    if rs.contains(where: { r1 in
                        r.requestID == r1.requestID
                    }) {
                        print("older exist")
                    } else{
                        print("older removed")
                        self.offers.removeAll { r1 in
                            r.requestID == r1.requestID
                        }
                        self.offerTableView.reloadData()
                    }
                            
                }
                
                rs.forEach { r in
                    
                    if self.offers.contains(where: { r1 in
                        r.requestID == r1.requestID
                    }) {
                        print("new exist older")
                    }else{
                        print("new added older")
                        self.offers.append(r)
                        self.offerTableView.reloadData()
                    }
                    
                }
                
                self.handle(request: r)

            }else{
                self.currntRequest = nil
                self.offers.removeAll()
                self.offerView.alpha = 0
                if self.isWaitngForOffer {
                    self.isWaitngForOffer = false
                  self.clearAllView()
                }
//                self.bottomRaiseView.alpha =  0
//                self.topRideDetailView.alpha = 0
//                self.roundTripViewBottomConstriant.constant = 20
            }
            self.currency = requestModel?.currency
            let request = self.currntRequest
            
            if error != nil {
                riderStatus = .none
                self.showToast(string: error?.localizedDescription ?? "error")
            } else if request != nil {
                
              
                if let stops = request?.stops{
                    
                    
                    self.stops = stops
                    
                }
                
                if let stops = request?.stops{
                    
                    for (index,stop) in stops.enumerated()
                    {
                        print("bhai status",index,stop.status as Any)
                    }
                    
                    
                    if stops.count == 1 {
                        let stop1 = stops[0]
                        self.stop1AddressLabel.text = stop1.d_address
                        self.tripDesLabel.text = stop1.d_address
                        self.stop2StackView?.isHidden = true
                        self.stop3StackView?.isHidden = true
                        self.stop2AddressLabel?.text = ""
                        self.stop3AddressLabel?.text = ""
                        if stop1.status == "DROPPED"{
                            self.stop1AddressLabel.textColor = .systemGray
                        }
                    }
                    else if stops.count == 2
                    {
                        
                        let stop1 = stops[0]
                        self.stop1AddressLabel.text = stop1.d_address
                        let stop2 = stops[1]
                        self.stop2AddressLabel?.text = stop2.d_address
                        if stop1.status == "DROPPED"{
                            self.stop1AddressLabel.textColor = .systemGray
                        }
                        if stop2.status == "DROPPED"{
                            self.stop2AddressLabel?.textColor = .systemGray
                        }
                        self.stop2StackView?.isHidden = false
                        self.stop3StackView?.isHidden = true
                        self.stop3AddressLabel?.text = ""
                    }
                    else if stops.count == 3{
                        let stop1 = stops[0]
                        self.stop1AddressLabel?.text = stop1.d_address
                        let stop2 = stops[1]
                        self.stop2AddressLabel?.text = stop2.d_address
                        let stop3 = stops[2]
                        self.stop3AddressLabel?.text = stop3.d_address
                        if stop1.status == "DROPPED"
                        {
                            self.stop1AddressLabel?.textColor = .systemGray
                        }
                        if stop2.status == "DROPPED"
                        {
                            self.stop2AddressLabel?.textColor = .systemGray
                        }
                        if stop3.status == "DROPPED"
                        {
                            self.stop3AddressLabel?.textColor = .systemGray
                        }
                        
                        self.stop2StackView?.isHidden = false
                        self.stop3StackView?.isHidden = false
                    }
                }
                
                
                self.updateStatus = request?.status
                
                if let requestId = request?.id {
                    self.currentRequestId = requestId
                }
                if let service_type_id = request?.service_type_id{
                    self.service_type_id = service_type_id
                    self.vehicleNameLabel.text = request?.service?.name
                    
                }
                if let pLatitude = request?.provider?.latitude, let pLongitude = request?.provider?.longitude {
                    DispatchQueue.main.async {
                        //                            self.moveProviderMarker(to: LocationCoordinate(latitude: pLatitude, longitude: pLongitude))
                        //                            self.getDataFromFirebase(providerID: (request?.provider?.id)!)
                        // MARK:- Showing Provider ETA
                        
                       
                        let sourceLat = request?.s_latitude
                        print("sourceLat>>>>.",sourceLat)
                        let siurceLong = request?.s_longitude
                        print("sourceLong >>>>>>",siurceLong)
                        //                            let destinationLat = request?.d_latitude
                        //                            let destinationLong = request?.d_longitude
                        print("mytestlat", request?.latitude)
                        print("mytestlng", request?.longitude)
                        
                        
                        if [RideStatus.accepted, .started].contains(currentStatus) {
                            
                            print("I m in accepted state")
                            
                            self.offerView.alpha = 0
                            self.vehicleCollectionView.alpha = 0
                            self.localSelectionParentView.alpha = 0
                            
                            
                            self.showETA(destinatoin: LocationCoordinate(latitude: pLatitude, longitude: pLongitude),sorce: LocationCoordinate(latitude: self.sourceLocationDetail?.value?.coordinate.latitude ?? 0.0, longitude: self.sourceLocationDetail?.value?.coordinate.longitude ?? 0.0))
                            
                            Global.shared.isStarted = true
                            Global.shared.driver_lat = request?.provider?.latitude ?? 0.0
                            Global.shared.driver_long = request?.provider?.longitude ?? 0.0
                            Global.shared.sourceLatitute = self.sourceLocationDetail?.value?.coordinate.latitude ?? 0.0
                            Global.shared.sourceLongtitude = self.sourceLocationDetail?.value?.coordinate.longitude ?? 0.0
                            
                            
                        }else if [RideStatus.pickedup].contains(currentStatus){
                            
                            print("I m in Picked up state")
                            
                            
                            //self.showETA(destinatoin: LocationCoordinate(latitude: destinationLat!, longitude: destinationLong!), sorce: LocationCoordinate(latitude: self.currentLocation.value?.latitude ?? 0.0, longitude: self.currentLocation.value?.longitude ?? 0.0))
                            
                            
                            Global.shared.isStarted = true
                            Global.shared.isPickup = true
                            Global.shared.driver_lat = request?.provider?.latitude ?? 0.0
                            Global.shared.driver_long = request?.provider?.longitude ?? 0.0
                            //                                Global.shared.destinationLatitde = destinationLat ?? 0.0
                            //                                Global.shared.destinationLontitude = destinationLong ?? 0.0
                            
                            //
                            
                        }
                        else if [RideStatus.arrived].contains(currentStatus)
                        {
                            
                        }
                        
                        self.updatePolyline()
                    }
                }
                guard riderStatus != request?.status else {
                    return
                }
                
                
                riderStatus = request?.status ?? .none
                self.isScheduled = ((request?.is_scheduled ?? false) && riderStatus == .searching)
                self.handle(request: request!)
            } else {
                
                self.updateStatus = request?.status
                
                let previousStatus = riderStatus
                riderStatus = request?.status ?? .none
                if riderStatus != previousStatus {
                    //self.clearMapview()
                }
                if self.isScheduled {
                    self.isScheduled = false
                    //                        if let yourtripsVC = Router.main.instantiateViewController(withIdentifier: Storyboard.Ids.YourTripsPassbookViewController) as? YourTripsPassbookViewController {
                    //                            yourtripsVC.isYourTripsSelected = true
                    //                            yourtripsVC.isFirstBlockSelected = false
                    //                            self.navigationController?.pushViewController(yourtripsVC, animated: true)
                    //                        }
                    self.removeUnnecessaryView(with: .cancelled)
                } else {
                    self.removeUnnecessaryView(with: .none)
                }
                
            }
            
           
        })
    }
    
    func getDataFromFirebase(providerID:Int)  {
        print("Testing Providers: \(providerID)")
        Database.database()
            .reference()
            .child("loc_p_\(providerID)").observe(.value, with: { (snapshot) in
                guard let dict = snapshot.value as? NSDictionary else {
                    print("Error")
                    return
                }
                var latDouble = 0.0 //for android sending any or double
                var longDouble = 0.0
                if let latitude = dict.value(forKey: "lat") as? Double {
                    latDouble = Double(latitude)
                    print("latitude>>>>>>>>",latitude)
                }else{
                    let strLat = dict.value(forKey: "lat")
                    latDouble = Double("\(strLat ?? 0.0)")!
                    print("strLat>>>>>>>>",strLat as Any)
                }
                if let longitude = dict.value(forKey: "lng") as? Double {
                    longDouble = Double(longitude)
                    print("longitude>>>>>>>>",longitude as Any)
                }else{
                    let strLong = dict.value(forKey: "lng")
                    longDouble = Double("\(strLong ?? 0.0)")!
                    print("strLong>>>>>>>>",strLong as Any)
                }
                
                //                    if let pLatitude = latDouble, let pLongitude = longDouble {
                DispatchQueue.main.async {
                    print("Moving \(latDouble) \(longDouble)")
                    print("latitude>>>>>>",latDouble)
                    print("longitude >>>",longDouble)
                    self.moveProviderMarker(to: LocationCoordinate(latitude: latDouble , longitude: longDouble ))
                    if polyLinePath.path != nil {
                        self.mapViewHelper.checkPolyline(coordinate:  LocationCoordinate(latitude: latDouble , longitude: longDouble ))
                    }
                }
                
                drawpolylineCheck = {
                    self.drawPolyline(isReroute: true)
                }
                //                    }
            })
        
    }
    
    // Get Services provided by Provider
    
    func getServicesList() {
        
        //            var latDouble = 0.0 //for android sending any or double
        //            var longDouble = 0.0
        let currentLat =  UserDefaults.standard.double(forKey: "lat")
        //  latDouble = Double(currentLat)
        print("latitude>>>>>>>>",currentLat)
        
        let currentLong =  UserDefaults.standard.double(forKey: "long")
        //  longDouble = Double(currentLat)
        print("currentLong>>>>>",currentLong)
        
        self.getMultiPositions()
        if self.sourceLocationDetail?.value != nil, self.positions != nil, riderStatus == .none || riderStatus == .searching { // Get Services only if location Available
            
            
            var estimateFare = LocationRequest()
            estimateFare.s_latitude = self.sourceLocationDetail?.value?.coordinate.latitude
            estimateFare.s_longitude = self.sourceLocationDetail?.value?.coordinate.longitude
            estimateFare.round_trip = 0
            estimateFare.is_round = 0
            
            self.presenter?.get(api: .servicesList, parameters: estimateFare.JSONRepresentation)
        }
    }
    
   
    
    // Get Estimate Fare
    
    func getEstimateFareFor(serviceId : Int, isRoundTrip:Int, waitingMin:Int) {
        
        DispatchQueue.main.async {
            
            
            //                guard let sourceLocation = self.sourceLocationDetail?.value?.coordinate, let destinationLocation = self.positions?[0].value?.coordinate, sourceLocation.latitude>0, sourceLocation.longitude>0, destinationLocation.latitude>0, destinationLocation.longitude>0 else {
            //                    return
            //                }
            
            guard let sourceLocation = self.sourceLocationDetail?.value?.coordinate, sourceLocation.latitude != 0.0, sourceLocation.longitude != 0 else {
                return
            }
            var estimateFare = EstimateFareRequest()
            estimateFare.s_latitude = sourceLocation.latitude
            estimateFare.s_longitude = sourceLocation.longitude
            
            
            
            if self.updatingDestination{
                
                
                if let array = self.updatePositions{
                    
                    var toGoArray = [Any]()
                    
                    for val in array{
                        if val.action != "delete"{
                            toGoArray.append(val.JSONRepresentation)
                        }
                    }
                    
                    
                    if let jsonString = convertIntoJSONString2(arrayObject: toGoArray){
                        print("jsonString - \(jsonString)")
                        //                        estimateFare.positions = jsonString
                        let urlwithPercentEscapes = jsonString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
                        
                        print(urlwithPercentEscapes)
                        
                        estimateFare.positions = urlwithPercentEscapes//jsonString
                    }
                }
                
            }else{
                
                
                if let array = self.mulitPostions{
                    
                    var toGoArray = [Any]()
                    
                    for val in array{
                        
                        toGoArray.append(val.JSONRepresentation)
                    }
                    
                    
                    if let jsonString = convertIntoJSONString2(arrayObject: toGoArray){
                        print("jsonString - \(jsonString)")
                        //                        estimateFare.positions = jsonString
                        let urlwithPercentEscapes = jsonString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
                        
                        print(urlwithPercentEscapes)
                        
                        estimateFare.positions = urlwithPercentEscapes//jsonString
                    }
                }
                
            }
            
            
            
            //estimateFare.positions = self.mulitPostions
            //                estimateFare.d_latitude = destinationLocation.latitude
            //                estimateFare.d_longitude = destinationLocation.longitude
            estimateFare.service_type = serviceId
            estimateFare.round_trip = isRoundTrip
            estimateFare.waiting_minutes = waitingMin
            print("EstimateFare", estimateFare)
            print(estimateFare.JSONRepresentation)
            KRProgressHUD.show()
            
            self.presenter?.get(api: .estimateFare, parameters: estimateFare.JSONRepresentation)
        //    self.sendRequest()
        }
    }
    
    
    
    // Cancel Request
    
    func cancelRequest(reason : String? = nil) {
        
        if self.currentRequestId>0 {
            let request = Request()
            request.request_id = self.currentRequestId
            request.cancel_reason = reason
            self.presenter?.post(api: .cancelRequest, data: request.toData())
        }
    }
    
    
    
    // Create Request
    
    func createRequest(for service : Service, isScheduled : Bool, scheduleDate : Date?, cardEntity entity : CardEntity?, paymentType : PaymentType, price: Double) {
        // Validate whether the card entity has valid data
        if paymentType == .CARD && entity == nil {
            UIApplication.shared.keyWindow?.make(toast: Constants.string.selectCardToContinue.localize())
            return
        }
        self.getMultiPositions()
        self.showLoaderView()
        DispatchQueue.global(qos: .background).async {
            let request = Request()
            request.s_address = self.sourceLocationDetail?.value?.address
            request.s_latitude = self.sourceLocationDetail?.value?.coordinate.latitude
            request.s_longitude = self.sourceLocationDetail?.value?.coordinate.longitude
            
            
            
            
            if let array = self.mulitPostions{
                
                var toGoArray = [Any]()
                
                for val in array{
                    
                    toGoArray.append(val.JSONRepresentation)
                }
                
                
                if let jsonString = convertIntoJSONString2(arrayObject: toGoArray){
                    print("jsonString - \(jsonString)")
                    request.positions = jsonString
                }
            }
            
            
            
            
            //  self.mulitPostions
            //                request.d_address = self.destinationLocationDetail?.address
            //                request.d_latitude = self.destinationLocationDetail?.coordinate.latitude
            //                request.d_longitude = self.destinationLocationDetail?.coordinate.longitude
            //request.service_type_id = service.id
            request.service_type = service.id
            request.is_round =  self.isRoundTrip ? 1 : 0 //service.round_trip
            request.waiting_minutes = service.waiting_minutes
            request.payment_mode = paymentType
            request.distance = "\(service.pricing?.distance ?? 0)" //currentEstimation
            request.use_wallet = service.pricing?.useWallet
            request.card_id = entity?.card_id
            request.offer_price =  price
            if service.id == 7{
                request.is_booster_cable = service.is_booster_cable
            }
            if service.id == 6{
                
                request.is_booster_cable = service.is_booster_cable
                
                request.instructions = service.instructions
            }
            if isScheduled {
                if let dateString = Formatter.shared.getString(from: scheduleDate, format: DateFormat.list.ddMMyyyyhhmma) {
                    let dateArray = dateString.components(separatedBy: " ")
                    request.schedule_date = dateArray.first
                    request.schedule_time = dateArray.last
                }
            }
            if let couponId = service.promocode?.id {
                request.promocode_id = couponId
            }
            
            self.presenter?.post(api: .sendRequest, data: request.toData())
            
        }
    }
    
    // MARK:- Update Location for Existing Request
    
    func updateLocation(with detail : LocationDetail) {
        
        guard [RideStatus.accepted, .arrived, .pickedup, .started].contains(riderStatus) else { return } // Update Location only if status falls under certain category
        
        //            self.viewAddressOuter.isHidden = true
        
        let request = Request()
        request.request_id = self.currentRequestId
        request.address = detail.address
        request.latitude = detail.coordinate.latitude
        request.longitude = detail.coordinate.longitude
        self.presenter?.post(api: .updateRequest, data: request.toData())
        
    }
    
    // MARK:- Change Payment Type For existing Request
    func updatePaymentType(with cardDetail : CardEntity) {
        
        let request = Request()
        request.request_id = self.currentRequestId
        request.payment_mode = .CARD
        request.card_id = cardDetail.card_id
        self.loader.isHideInMainThread(false)
        self.presenter?.post(api: .updateRequest, data: request.toData())
        
    }
    
    // MARK:- Change Payment Type For existing Request
    func updatePaymentTypeToCash() {
        
        let request = Request()
        request.request_id = self.currentRequestId
        request.payment_mode = .CASH
        self.loader.isHideInMainThread(false)
        self.presenter?.post(api: .updateRequest, data: request.toData())
        
    }
    
    // MARK:- Favourite Location on Other Category
    //        func favouriteLocationApi(in view : UIView, isAdd : Bool) {
    //
    //            guard isAdd else { return }
    //
    //            let service = Service() // Save Favourite location in Server
    //            service.type = CoreDataEntity.other.rawValue.lowercased()
    //            if view == self.viewFavouriteSource, let address = self.sourceLocationDetail?.value {
    //                service.address = address.address
    //                service.latitude = address.coordinate.latitude
    //                service.longitude = address.coordinate.longitude
    //            } else if view == self.viewFavouriteDestination, self.positions != nil {
    //                service.address = self.positions?[0].value?.address
    //                service.latitude = self.positions?[0].value?.coordinate.latitude
    //                service.longitude = self.positions?[0].value?.coordinate.longitude
    //            } else { return }
    //
    //            self.presenter?.post(api: .locationServicePostDelete, data: service.toData())
    //
    //        }
}

// MARK:- PostViewProtocol

extension HomeViewController : PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        KRProgressHUD.dismiss()
        DispatchQueue.main.async {
            self.loader.isHidden = true
            if api == .locationServicePostDelete {
                UIApplication.shared.keyWindow?.make(toast: message)
            } else {
                if code != StatusCode.notreachable.rawValue && api != .checkRequest && api != .cancelRequest{
                    print(api)
                    showAlert(message: message, okHandler: nil, fromView: self)
                    self.clearAllView()
                }
                
                
            }
            if api == .sendRequest {
                self.removeLoaderView()
            }
        }
    }
    
    func getServiceList(api: Base, data: [Service]) {
        print("getServiceList>>>>>",data)
        
        if api == .servicesList {
            DispatchQueue.main.async {  // Show Services
                self.showRideNowView(with: data)
            }
            self.rides = data
            self.callFareApi(index: 0)
        }else if api == .getProviders {  // Show Providers in Current Location
            DispatchQueue.main.async {
                self.showProviderInCurrentLocation(with: data)
            }
        }
        
    }
    
    
    func getRequest(api: Base, data: Request?) {
        
        print("getreq>>>>>>",data as Any)
        
        print("getRequest>>>>",data?.payment?.payment_mode as Any)
        
        print(data?.request_id ?? 0)
        if api == .sendRequest {
            self.success(api: api, message: data?.message)
            self.currentRequestId = data?.request_id ?? 0
            self.checkForProviderStatus()
            DispatchQueue.main.async {
                self.showLoaderView(with: self.currentRequestId)
            }
        }
    }
    
    func success(api: Base, message: String?) {
        
        self.loader.isHideInMainThread(true)
        if api == .updateRequest {
            riderStatus = .none
            return
        }
        if api == .sendRequest {
            self.isWaitngForOffer = true
            self.bottomRaiseView.alpha = 1
            self.topRideDetailView.alpha = 1
            self.roundTripViewBottomConstriant.constant = -80
            offerCancelButton.alpha = 1
            driverFindingLabel.alpha = 1
           // self.tripCurrentFareLabel.text = "\(curOfferAmountByUser)"
        }
        
        if api == .locationServicePostDelete {
            self.presenter?.get(api: .locationService, parameters: nil)
        }else if api == .rateProvider  {
            isRateViewShowed = false
            riderStatus = .none
            return
        }
       
        if api != .payNow || api == .cancelRequest{
            if api == .cancelRequest {
                riderStatus = .none
                if self.topRideDetailView.alpha == 1 {
                    self.sendRequest()
                }
            }
           
            //                DispatchQueue.main.async {
            //                    self.view.makeToast(message)
            //                }
        }
        
        else {
            riderStatus = .none // Make Ride Status to Default
            if api == .payNow { // Remove PayNow if Card Payment is Success
                self.removeInvoiceView()
            }
        }
    }
    
    func getLocationService(api: Base, data: LocationService?) {
        
        self.loader.isHideInMainThread(true)
        storeFavouriteLocations(from: data)
        
    }
    func getProfile(api: Base, data: Profile?) {
        print("gethome payment pin>>>",data?.corporate_pin as Any )
        
        UserDefaults.standard.set(data?.corporate_pin, forKey: "corporate_pin")
        
        Common.storeUserData(from: data)
        storeInUserDefaults()
    }
    
    
    func getEstimateFare(api: Base, data: EstimateFare?) {
        KRProgressHUD.dismiss()
        if let d = data {
           // if isEstimationCall {
            self.currentEstimation = data
                isEstimationCall = false
                self.tripDistanceLabel.text = "\(d.distance ?? 0)m"
                self.tripTimeLAbel.text = "\(d.time ?? "-")"
                //self.priceTextfield.text = "\(d.base_price ?? 0)"
                // self.tripCurrentFareLabel.text = "\(d.base_price ?? 0)"
                let p = d.estimated_fare ?? 0 //(Double(d.distance ?? 0) * Double(d.base_price ?? 0)).precised(2)
                self.curOfferAmountByUser = Double(p)
                self.firtstimatedFare = Double(p)
                self.tripPriceLabel.text = "C$\(p)"
                let estimatedFareString = "\(String.removeNil(User.main.currency)) \(Formatter.shared.limit(string: "\(p)", maximumDecimal: 2))"
                if self.isRoundTrip {
                    if !self.isAlreadyPopulated {
                        self.isAlreadyPopulated = true
                        self.popUpEstimatedFare(estimatedFareString: estimatedFareString)
                    }
                }

            //}

        }
//        if self.updatingDestination || self.isRoundTrip {
//            if data != nil {
//                if let estimated_fare = data?.estimated_fare{
//
////                    let estimatedFareString1 = "\(String.removeNil(User.main.currency)) \(Int(estimated_fare))"
//                    let estimatedFareString = "\(String.removeNil(User.main.currency)) \(Formatter.shared.limit(string: "\(estimated_fare)", maximumDecimal: 2))"
//                   // self.priceTextfield.text = estimatedFareString
//                    self.curOfferAmountByUser = Double(estimated_fare)
//                    self.popUpEstimatedFare(estimatedFareString: estimatedFareString)
//                    //self.isRoundTrip = false
//                }
//            }
//        }
    }
    
    
}



extension HomeViewController{
    
    func resetCheck(){
        updateRoute = true
        shortDistance = 0
    }
    
    func perKmUpdateRouteCheck(newLocation: CLLocation?){
        if currLocation != nil{
            shortDistance += self.currLocation.distance(from: newLocation!)
            print("short distance is",shortDistance)
            //   self.showToast(string: "Distance \(shortDistance)")
            if shortDistance >= 1000 {
                self.resetCheck()
            }
        }
        currLocation = newLocation
    }
}



extension String{
    /// EZSE: Converts String to Double
    public func toDouble() -> Double?
    {
        if let num = NumberFormatter().number(from: self) {
            return num.doubleValue
        } else {
            return nil
        }
    }
}


extension HomeViewController:ChangeDestinationProtocol{
    func updatedDestination(destination: LocationDetail?) {
        self.destinationLocationDetail = destination
        self.drawPolyline(isReroute: true)
    }
}


extension HomeViewController{
    
    
    func getMultiPositions(){
        if let positions = self.positions
        {
            
            var mP = [Positions]()
            for (index,position) in positions.enumerated()
            {
                let posi = Positions()
                posi.d_address = position.value?.address
                posi.d_latitude = position.value?.coordinate.latitude
                posi.d_longitude = position.value?.coordinate.longitude
                
                let xx = posi.toData()
                mP.append(posi)
                //   self.mulitPostions?.insert(posi, at: index)
                print(position)
                print(mP.count,"Counts")
                //                    self.mulitPostions?.append(posi)
                print(self.mulitPostions ?? "khocha kya karta hy")
            }
            
            self.mulitPostions=mP
            
        }
        
    }
    
}



func convertIntoJSONString2(arrayObject: [Any]) -> String? {
    //, options: []
    do {
        //  let json = try JSONSerialization.data(withJSONObject: params)
        let jsonData: Data = try JSONSerialization.data(withJSONObject: arrayObject)
        if  let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) {
            return jsonString as String
        }
        
    } catch let error as NSError {
        print("Array convertIntoJSON - \(error.description)")
    }
    return nil
}



extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}


extension HomeViewController: MultiLocationVCDelegate{
    func backPressed(gmHelperRef: GoogleMapsHelper) {
        //mapViewHelper = gmHelperRef
        
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark{
                self.mapViewHelper.getMapView(withDelegate: self, in: self.viewMapOuter, interfaceStyle: .dark, isMultilocVC: true)
            }else{
                self.mapViewHelper.getMapView(withDelegate: self, in: self.viewMapOuter, interfaceStyle: .light, isMultilocVC: true)
            }
        } else {
            self.mapViewHelper.getMapView(withDelegate: self, in: self.viewMapOuter, interfaceStyle: .light, isMultilocVC: true)
        }
        
    }
}
extension HomeViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.offers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OfferCell") as! OfferCell
        let item = self.offers[indexPath.row]
        if let s = self.currentUserMapLocatio {
        let driverLocation = CLLocationCoordinate2D(latitude: item.provider?.latitude ?? 0, longitude: item.provider?.longitude ?? 0)
            self.mapViewHelper.mapView?.getNewEstimation(between: s, to: driverLocation, completion: { time, dis in
                DispatchQueue.main.async {
                    cell.timeLAbel.text = time
                    cell.distanceLabel.text = dis
                }
            })
        }
        
        cell.setData(item: item,currency: self.currency ?? "", currentLocation: currLocation )
        
        cell.acceptBlock = {
            if let id = item.id, let reqID = item.requestID {
                self.acceptOfferAPiCall(id: id,reqId: reqID)
            }
        }
        cell.rejectBlock = {
            DispatchQueue.main.async {
                self.offers.remove(at: indexPath.row)
                self.offerTableView.reloadData()
                if let id = item.id, let reqID = item.requestID {
                    self.rejectOfferAPiCall(id: id,reqId: reqID)
                }
            }
          
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func acceptOfferAPiCall(id:Int, reqId : Int){
        //KRProgressHUD.show()
        
        ApiCalls().acceptOffer(offerID: id, requestId: reqId) { msg, error in
            self.isOfferAccepted = true
            //KRProgressHUD.dismiss()
            if let m = msg {
                self.showToast(string: m)
            }else{
                self.showToast(string: error ?? "")

            }
        }
    }
    
    func rejectOfferAPiCall(id:Int, reqId : Int){
     //   KRProgressHUD.show()

        ApiCalls().rejectOffer(offerID: id, requestId: reqId) { msg, error in
          //  KRProgressHUD.dismiss()
            
            if let m = msg {
                self.showToast(string: m)
            }else{
                self.showToast(string: error ?? "")

            }
        }
    }
    
    func setEstimation(){
        
        if let lat = self.currntRequest?.latitude, let long = self.currntRequest?.longitude {
            let des = CLLocationCoordinate2D(latitude: lat, longitude: long)
            mapViewHelper.mapView?.getNewEstimation(between: sourceCoordinate, to: des, completion: { time, dis in
                self.tripDesLabel.text = dis
                self.tripTimeLAbel.text = time
            })
        }
    }
}


extension HomeViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !textField.text!.isEmpty {
            let am = Double(textField.text!) ?? 0
            if firtstimatedFare > 0 {
                if am < firtstimatedFare {
                    self.priceTextfield.text = "\(firtstimatedFare)"
                    self.showSimpleAlert(title: "Update your offer", message: "Minimum offer is c$ \(firtstimatedFare)")
                    return
                }
            }
            self.curOfferAmountByUser = am
        }
    }
}
