//
//  ChangeDestinationViewController.swift
//  TranxitUser
//
//  Created by Hexacrew on 15/04/2020.
//  Copyright © 2020 Appoets. All rights reserved.
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
    
    //var riderStatus : RideStatus = .none // Provider Current Status
    
class ChangeDestinationViewController: UIViewController {
    
    
    
    var changeDestinationDelegate:ChangeDestinationProtocol?
    
    
    
    var estimateFarePop:EstimatedFareViewController!
    var popUpDialog:PopupDialog!
    
    
        
        var updateRoute = true
        var isCPRouteTrigged = true
        var isPDRouteTrigged = true
        var shortDistance:Double = 0
        var currLocation:CLLocation!
        
        
        
        
        
    
        @IBOutlet private var viewSideMenu : UIView! //This is back button
        @IBOutlet private var viewCurrentLocation : UIView! //this is done button
        @IBOutlet weak var viewMapOuter : UIView! //this is map view
    
        //@IBOutlet weak private var viewFavouriteSource : UIView!
    
        //@IBOutlet weak private var viewFavouriteDestination : UIView!
    
        //@IBOutlet weak private var imageViewFavouriteSource : ImageView!
    
       // @IBOutlet weak private var imageViewFavouriteDestination : ImageView!
       // @IBOutlet weak private var viewSourceLocation : UIView!
        @IBOutlet weak private var viewDestinationLocation : UIView!
        @IBOutlet weak private var viewAddress : UIView!
        @IBOutlet weak var viewAddressOuter : UIView!
     //   @IBOutlet weak private var textFieldSourceLocation : UITextField!
        @IBOutlet weak private var textFieldDestinationLocation : UITextField!
        @IBOutlet weak private var imageViewMarkerCenter : UIImageView!
        @IBOutlet weak private var imageViewSideBar : UIImageView!
//        @IBOutlet weak var buttonSOS : UIButton!
//        @IBOutlet weak private var viewHomeLocation : UIView!
//        @IBOutlet weak private var viewWorkLocation : UIView!
//        @IBOutlet weak var viewLocationButtons : UIStackView!
//        @IBOutlet weak var homeImageView: UIImageView!
        
       // private var sourceCoordinate = LocationCoordinate()
        private var destinationCoordinate = LocationCoordinate()
        final var currentProvider: Provider?
        var updateStatus: RideStatus?
        
      //  @IBOutlet var constraint : NSLayoutConstraint!
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
            marker.map = self.mapViewHelper?.mapView
            return marker
        }()
        
        private var selectedLocationView = UIView() // View to change the location p
            {
            didSet{
                if !([ viewDestinationLocation].contains(selectedLocationView)) {
                    [ viewDestinationLocation].forEach({ $0?.transform = .identity })
                }
            }
        }
        
        var isOnBooking = false {  // Boolean to handle back using side menu button
            didSet {
                self.imageViewSideBar.image = isOnBooking ? #imageLiteral(resourceName: "back-icon") : #imageLiteral(resourceName: "menu_icon")
            }
        }
        
        private var isUserInteractingWithMap = false // Boolean to handle Mapview User interaction
        // private let transition = CircularTransition()  // Translation to for location Tap
        var mapViewHelper : GoogleMapsHelper?
//        private var favouriteViewSource : LottieView?
//        private var favouriteViewDestination : LottieView?
        
//        private var isSourceFavourited = false {  // Boolean to handle favourite source location
//            didSet{
//                self.isAddFavouriteLocation(in: self.viewFavouriteSource, isAdd: isSourceFavourited)
//            }
//        }
        
//        private var isDestinationFavourited = false { // Boolean to handle favourite destination location
//            didSet{
//                self.isAddFavouriteLocation(in: self.viewFavouriteDestination, isAdd: isDestinationFavourited)
//            }
//        }
        
    
    
        var currentDestinationLocationDetail : LocationDetail?
    
    
        
        var sourceLocationDetail : Bind<LocationDetail>? = Bind<LocationDetail>(nil)
        
        var destinationLocationDetail : LocationDetail? {  // Destination Location Detail
            didSet{
                DispatchQueue.main.async {
                    self.textFieldDestinationLocation.text = (self.destinationLocationDetail?.address.removingWhitespaces().isEmpty ?? true) ? nil : self.destinationLocationDetail?.address
                }
            }
        }
        
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
                    self.floatyButton?.removeFromSuperview()
                }
            }
        }
        var invoiceView : InvoiceView?
        var ratingView : RatingView?
        var rideNowView : RideNowView?
        var floatyButton : Floaty?
        var reasonView : ReasonView?
      
    
    
        var service_type_id : Int?
        
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
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
        let viewControllerName = String.init(describing: self.classForCoder)
        print("VCName***: \(viewControllerName)")
            
            
            self.initialLoads()
            
            self.localize()
            print("riderstatus>>>>>.",riderStatus)
            
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.viewWillAppearCustom()
             NotificationCenter.default.addObserver(self, selector: #selector(isChatPushRedirection), name: NSNotification.Name("ChatPushRedirection"), object: nil)
            
            //IQKeyboardManager.shared.enable = true
        }
        
        
        @objc func isChatPushRedirection() {
            
            if let ChatPage = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.SingleChatController) as? SingleChatController {
                ChatPage.set(user: self.currentProvider ?? Provider(), requestId: self.currentRequestId)
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
                    mapViewHelper?.traitHasBeenChanged(interfaceStyle: .dark)
                }else{
                    mapViewHelper?.traitHasBeenChanged(interfaceStyle: .light)
                }
                
            }
        }
        
        
}
    
    // MARK:- Methods
    
    
extension ChangeDestinationViewController {
    
    func resetAll(){
        
        //self.textFieldSourceLocation.text = ""
        mapViewHelper?.getCurrentLocation(onReceivingLocation: { (location) in
            
            self.mapViewHelper?.moveTo(location: LocationCoordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), with: self.viewMapOuter.center)
            
            self.mapViewHelper?.getPlaceAddress(from: location.coordinate, on: { (locationDetail) in  // On Tapping current location, set
                DispatchQueue.main.async {
                    
                    //self.textFieldSourceLocation.text = locationDetail.address
                    self.sourceLocationDetail?.value = locationDetail
                }
                
            })
        })
        
        
    }
    private func initialLoads() {
        
        let lat =   currentLocation.value?.latitude
        
        UserDefaults.standard.set(lat, forKey: "lat")
        let long =   currentLocation.value?.longitude
        UserDefaults.standard.set(long, forKey: "long")
        
        
        if let currentDestination = self.currentDestinationLocationDetail{
            
            self.destinationLocationDetail = currentDestination
            
        }
        
        
        
            
            self.addMapView()
            self.getFavouriteLocations()
            self.viewSideMenu.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.sideMenuAction)))
            self.navigationController?.isNavigationBarHidden = true
            //self.viewFavouriteDestination.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.favouriteLocationAction(sender:))))
            //self.viewFavouriteSource.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.favouriteLocationAction(sender:))))
            [self.viewDestinationLocation].forEach({ $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.locationTapAction(sender:))))})
            self.currentLocation.bind(listener: { (locationCoordinate) in
                // TODO:- Handle Current Location
                
                if locationCoordinate != nil {
                    self.mapViewHelper?.moveTo(location: LocationCoordinate(latitude: locationCoordinate!.latitude, longitude: locationCoordinate!.longitude), with: self.viewMapOuter.center)
                }
            })
            self.viewCurrentLocation.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.getCurrentLocation)))
            self.sourceLocationDetail?.bind(listener: { (locationDetail) in
//                if locationDetail == nil {
//                    self.isSourceFavourited = false
//                }
                let sourceAddress = locationDetail?.address
                
                if self.updateStatus != .accepted && self.updateStatus != .started && self.updateStatus != .arrived && self.updateStatus != .pickedup && self.updateStatus != .searching {
//                    DispatchQueue.main.async {
//
//                        self.isSourceFavourited = false // reset favourite location on change
//
//                        if let address = sourceAddress{
//                            self.textFieldSourceLocation.text = address
//                        }
//                    }
                }
            })
            self.viewDestinationLocation.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            self.checkForProviderStatus()
           // self.buttonSOS.isHidden = true
            //self.buttonSOS.addTarget(self, action: #selector(self.buttonSOSAction), for: .touchUpInside)
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
        
    }
        
        // MARK:- View Will Layouts
        
        private func viewLayouts() {
            
            self.viewCurrentLocation.makeRoundedCorner()
            self.mapViewHelper?.mapView?.frame = viewMapOuter.bounds
            self.viewSideMenu.makeRoundedCorner()
            self.navigationController?.isNavigationBarHidden = true
        }
        
        @IBAction private func getCurrentLocation(){
            
            
            // Here we will call new api for fare estimate
            
            
            if let service_type_id = self.service_type_id{
                self.getEstimateFareFor(serviceId: service_type_id)
            }
            
            
            
//            self.viewCurrentLocation.addPressAnimation()
//            mapViewHelper?.getCurrentLocation(onReceivingLocation: { (location) in
//
//                self.mapViewHelper?.moveTo(location: location.coordinate, with: self.viewMapOuter.center)
//                self.mapViewHelper?.getPlaceAddress(from: location.coordinate, on: { (locationDetail) in  // On Tapping current location, set
//                    DispatchQueue.main.async {
//                        //self.textFieldSourceLocation.text = locationDetail.address
//                        self.sourceLocationDetail?.value = locationDetail
//                    }
//
//
//                })
//            })
        }
    
        // MARK:- Localize
        
        private func localize(){
            
           // self.textFieldSourceLocation.placeholder = Constants.string.source.localize()
            self.textFieldDestinationLocation.placeholder = Constants.string.destination.localize()
            
        }
        
        // MARK:- Set Design
        
        private func setDesign() {
            
          //  Common.setFont(to: textFieldSourceLocation)
            Common.setFont(to: textFieldDestinationLocation)
        }
        
        // MARK:- Add Mapview
        
        private func addMapView(){
           
            self.mapViewHelper = GoogleMapsHelper()
            if #available(iOS 12.0, *) {
                if traitCollection.userInterfaceStyle == .dark{
                    self.mapViewHelper?.getMapView(withDelegate: self, in: self.viewMapOuter, interfaceStyle: .dark)
                }else{
                    self.mapViewHelper?.getMapView(withDelegate: self, in: self.viewMapOuter, interfaceStyle: .light)
                }
            } else {
                self.mapViewHelper?.getMapView(withDelegate: self, in: self.viewMapOuter, interfaceStyle: .light)
            }
            self.getCurrentLocationDetails()
        }
    
    
    
    private func showToast(string : String?) {
        
        self.view.makeToast(string, point: CGPoint(x: UIScreen.main.bounds.width/2 , y: UIScreen.main.bounds.height/2), title: nil, image: nil, completion: nil)
        
    }
    //Getting current location detail
    private func getCurrentLocationDetails() {
        self.mapViewHelper?.getCurrentLocation(onReceivingLocation: { (location) in
            
            
            
            print("Current LOC ")
         //   self.showToast(string: "\(location.coordinate.latitude)")
            
            
            self.perKmUpdateRouteCheck(newLocation: location)
       
            
            if self.sourceLocationDetail?.value == nil {
                self.mapViewHelper?.getPlaceAddress(from: location.coordinate, on: { (locationDetail) in
                    DispatchQueue.main.async {
                        
                        //self.textFieldSourceLocation.text = locationDetail.address
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
//            [self.viewHomeLocation, self.viewWorkLocation].forEach({
//                 $0?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.viewLocationButtonAction(sender:))))
//                 $0?.isHidden = true
//            })
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
                          //  self.viewWorkLocation.isHidden = false
                        }
                   case CoreDataEntity.home.rawValue where location.value is Home:
                        if let homeObject = location.value as? Home, let address = homeObject.address {
                            if let index = favouriteLocations.firstIndex(where: { $0.address == Constants.string.home}) {
                                favouriteLocations[index] = (location.key, (address, LocationCoordinate(latitude: homeObject.latitude, longitude: homeObject.longitude)))
                            } else {
                                favouriteLocations.append((location.key, (address, LocationCoordinate(latitude: homeObject.latitude, longitude: homeObject.longitude))))
                            }
                           // self.viewHomeLocation.isHidden = false//
                        }
                default:
                    break
                    
                }
            }
        }
        
        // MARK:- View Location Action
        
        @IBAction private func viewLocationButtonAction(sender : UITapGestureRecognizer) {
            
            guard let senderView = sender.view else { return }
            if  let location = CoreDataHelper().favouriteLocations()[CoreDataEntity.home.rawValue] as? Home, let addressString = location.address {
                self.destinationLocationDetail = (addressString, LocationCoordinate(latitude: location.latitude, longitude: location.longitude))
            } else if let location = CoreDataHelper().favouriteLocations()[CoreDataEntity.work.rawValue] as? Work, let addressString = location.address {
                self.destinationLocationDetail = (addressString, LocationCoordinate(latitude: location.latitude, longitude: location.longitude))
            }
            
            if destinationLocationDetail == nil { // No Previous Location Avaliable
                self.showLocationView()
            } else {
                self.drawPolyline(isReroute: false) // Draw polyline between source and destination
                self.getServicesList() // get Services
            }
            
        }
        
        
        // MARK:- Favourite Location Action
        
        @IBAction private func favouriteLocationAction(sender : UITapGestureRecognizer) {
            
            guard let senderView = sender.view else { return }
            senderView.addPressAnimation()
//             if senderView == viewFavouriteDestination {
//                self.isDestinationFavourited = self.destinationLocationDetail != nil ? !self.isDestinationFavourited : false
//            }
        }
        
        // MARK:- Favourite Location Action
        
        private func isAddFavouriteLocation(in viewFavourite : UIView, isAdd : Bool) {
            
           
         //   self.imageViewFavouriteDestination.image = (isAdd ? #imageLiteral(resourceName: "like") : #imageLiteral(resourceName: "unlike")).withRenderingMode(.alwaysTemplate)
            
          //  self.favouriteLocationApi(in: viewFavourite, isAdd: isAdd) // Send to Api Call

        }
        
        // MARK:- Favourite Location Action
        
        @IBAction private func locationTapAction(sender : UITapGestureRecognizer) {
            
            guard let senderView = sender.view  else { return }
         

//            if riderStatus != .none, senderView == viewDestinationLocation { // Ignore if user is onRide and trying to change Destination location
//                return
//            }
            self.selectedLocationView.transform = CGAffineTransform.identity
            
            if self.selectedLocationView == senderView {
                self.showLocationView()
            } else {
                self.selectedLocationView = senderView
                self.selectionViewAction(in: senderView)
            }
            self.selectedLocationView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            self.viewAddress.bringSubviewToFront(self.selectedLocationView)
            // self.showLocationView()
        }
        
        
        // MARK:- Show Marker on Location
        
        private func selectionViewAction(in currentSelectionView : UIView){
            
             if currentSelectionView == self.viewDestinationLocation {
                
                if let coordinate = self.destinationLocationDetail?.coordinate{
                    self.plotMarker( marker: &destinationMarker, with: coordinate)
                    print("Destination Marker - ", coordinate.latitude, " ",coordinate.longitude)
                } else {
                    self.showLocationView()
                }
            }
            
        }
        
        private func plotMarker(marker : inout GMSMarker, with coordinate : CLLocationCoordinate2D){
           
            marker.position = coordinate
            marker.map = self.mapViewHelper?.mapView
//            self.mapViewHelper?.mapView?.animate(toLocation: coordinate)
        }
        
        
        // MARK:- Show Location View
        
        @IBAction private func showLocationView() {
            
            if let locationView = Bundle.main.loadNibNamed(XIB.Names.LocationSelectionView, owner: self, options: [:])?.first as? LocationSelectionView {
                locationView.frame = self.view.bounds
                locationView.setValues(address: (sourceLocationDetail,destinationLocationDetail)) { [weak self] (address) in
                    guard let self = self else {return}
                    self.sourceLocationDetail = address.source
                    self.destinationLocationDetail = address.destination
                   // print("\nselected-->>>>>",self.sourceLocationDetail?.value?.coordinate, self.destinationLocationDetail?.coordinate)
                    self.drawPolyline(isReroute: false) // Draw polyline between source and destination
                    if [RideStatus.accepted, .arrived, .pickedup, .started].contains(riderStatus) {
                        if let dAddress = address.destination?.address, let coordinate = address.destination?.coordinate {
                         
                        }
                    } else {
                        self.removeUnnecessaryView(with: .cancelled) // Remove services or ride now if previously open
                        self.getServicesList() // get Services
                    }
                }
                self.view.addSubview(locationView)
                locationView.textFieldDestination.becomeFirstResponder()
                self.selectedLocationView.transform = .identity
                self.selectedLocationView = UIView()
                self.locationSelectionView = locationView
            }
            
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
            self.mapViewHelper?.mapView?.drawPolygon(from:polyLineSource , to: polyLineDestination)
            
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
            if var sourceCoordinate = self.sourceLocationDetail?.value?.coordinate,
                let destinationCoordinate = self.destinationLocationDetail?.coordinate {  // Draw polyline from source to destination
                self.mapViewHelper?.mapView?.clear()
                self.sourceMarker.map = self.mapViewHelper?.mapView
                self.destinationMarker.map = self.mapViewHelper?.mapView
                if isReroute{
                    let coordinate = CLLocationCoordinate2D(latitude: (currentLocation.value?.latitude)!, longitude: (currentLocation.value?.longitude)!)
                    sourceCoordinate = coordinate
                }
                // let cord: CLLocationCoordinate2D = UserDefaults.standard.value(forKey: "location") as! CLLocationCoordinate2D
                
                self.sourceMarker.position = sourceCoordinate
                self.destinationMarker.position = destinationCoordinate
                //self.selectionViewAction(in: self.viewSourceLocation)
                //self.selectionViewAction(in: self.viewDestinationLocation)
                self.mapViewHelper?.mapView?.drawPolygon(from:sourceCoordinate , to: destinationCoordinate)
                self.selectedLocationView = UIView()
            }
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
            
            
//            if self.isOnBooking { // If User is on Ride Selection remove all view and make it to default
//               self.clearAllView()
//                print("ViewAddressOuter ", #function)
//            } else {
//                self.drawerController?.openSide(selectedLanguage == .arabic ? .right : .left)
//                self.viewSideMenu.addPressAnimation()
//            }
            
            self.navigationController?.popViewController(animated: true)
            
        }
    
      // Clear Map
    
     func clearAllView() {
        self.removeLoaderView()
        self.removeUnnecessaryView(with: .cancelled)
        self.clearMapview()
        self.viewAddressOuter.isHidden = false
        //self.viewLocationButtons.isHidden = false//
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
    
extension ChangeDestinationViewController : GMSMapViewDelegate {
        
        func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
            
            if self.isUserInteractingWithMap {
                
                func getUpdate(on location : CLLocationCoordinate2D, completion :@escaping ((LocationDetail)->Void)) {
                    self.drawPolyline(isReroute: false)
                    self.getServicesList()
                    self.mapViewHelper?.getPlaceAddress(from: location, on: { (locationDetail) in
                        completion(locationDetail)
                    })
                }
                
                 if self.selectedLocationView == self.viewDestinationLocation, self.destinationLocationDetail != nil {
                    
                    if let location = mapViewHelper?.mapView?.projection.coordinate(for: viewMapOuter.center) {
                        self.destinationLocationDetail?.coordinate = location
                        getUpdate(on: location) { (locationDetail) in
                            self.destinationLocationDetail = locationDetail
                           
                        }
                    }
                }
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
            
            if isUserInteractingWithMap {
                 if self.selectedLocationView == self.viewDestinationLocation, self.destinationLocationDetail != nil {
                    
                    self.destinationMarker.map = nil
                    self.imageViewMarkerCenter.tintColor = .primary
                    self.imageViewMarkerCenter.image = #imageLiteral(resourceName: "destinationPin").withRenderingMode(.alwaysTemplate)
                    self.imageViewMarkerCenter.isHidden = false
                    //                if let location = mapViewHelper?.mapView?.projection.coordinate(for: viewMapOuter.center) {
                    //                    self.destinationLocationDetail?.coordinate = location
                    //                    self.mapViewHelper?.getPlaceAddress(from: location, on: { (locationDetail) in
                    //                        print(locationDetail)
                    //                        self.destinationLocationDetail = locationDetail
                    //                    })
                    //                }
                }
                
            }
            //        else {
            //            self.destinationMarker.map = self.mapViewHelper?.mapView
            //            self.sourceMarker.map = self.mapViewHelper?.mapView
            //            self.imageViewMarkerCenter.isHidden = true
            //        }
            
        }
        
}
    
    // MARK:- Service Calls
    
extension ChangeDestinationViewController  {
        
        // Check For Service Status
        
        private func checkForProviderStatus() {
            
//            HomePageHelper.shared.startListening(on: { (error, request) in
//
//
//                if error != nil {
//                    riderStatus = .none
//                    //                    DispatchQueue.main.async {
//                    //                        showAlert(message: error?.localizedDescription, okHandler: nil, fromView: self)
//                    //                    }
//                } else if request != nil {
//
//                    self.updateStatus = request?.status
//
//                    if let requestId = request?.id {
//                        self.currentRequestId = requestId
//                    }
//
//                    if let service_type = request?.service_type{
//                        self.service_type_id = service_type
//                    }
//
//
//                    if let pLatitude = request?.provider?.latitude, let pLongitude = request?.provider?.longitude {
//                        DispatchQueue.main.async {
//                            //                            self.moveProviderMarker(to: LocationCoordinate(latitude: pLatitude, longitude: pLongitude))
////                            self.getDataFromFirebase(providerID: (request?.provider?.id)!)
//                            // MARK:- Showing Provider ETA
//
//                            let currentStatus = request?.status ?? .none
//                            let sourceLat = request?.s_latitude
//                            print("sourceLat>>>>.",sourceLat)
//                            let siurceLong = request?.s_longitude
//                            print("sourceLong >>>>>>",siurceLong)
//                            let destinationLat = request?.d_latitude
//                            let destinationLong = request?.d_longitude
//                            print("mytestlat", request?.latitude)
//                            print("mytestlng", request?.longitude)
//
//
//                            if [RideStatus.accepted, .started].contains(currentStatus) {
//
//                                print("I m in accepted state")
//
//                                self.showETA(destinatoin: LocationCoordinate(latitude: pLatitude, longitude: pLongitude),sorce: LocationCoordinate(latitude: self.sourceLocationDetail?.value?.coordinate.latitude ?? 0.0, longitude: self.sourceLocationDetail?.value?.coordinate.longitude ?? 0.0))
//
//                                Global.shared.isStarted = true
//                                Global.shared.driver_lat = request?.provider?.latitude ?? 0.0
//                                Global.shared.driver_long = request?.provider?.longitude ?? 0.0
//                                Global.shared.sourceLatitute = self.sourceLocationDetail?.value?.coordinate.latitude ?? 0.0
//                                Global.shared.sourceLongtitude = self.sourceLocationDetail?.value?.coordinate.longitude ?? 0.0
//
//
//                            }else if [RideStatus.pickedup].contains(currentStatus) {
//
//                                print("I m in Picked up state Change destination class")
//
//                                //self.showETA(destinatoin: LocationCoordinate(latitude: destinationLat!, longitude: destinationLong!), sorce: LocationCoordinate(latitude: self.currentLocation.value?.latitude ?? 0.0, longitude: self.currentLocation.value?.longitude ?? 0.0))
//
//
//                                Global.shared.isStarted = true
//                                Global.shared.isPickup = true
//                                Global.shared.driver_lat = request?.provider?.latitude ?? 0.0
//                                Global.shared.driver_long = request?.provider?.longitude ?? 0.0
//                                Global.shared.destinationLatitde = destinationLat ?? 0.0
//                                Global.shared.destinationLontitude = destinationLong ?? 0.0
//
////
//
//                            }
//
//                            self.updatePolyline()
//                        }
//                    }
//                    guard riderStatus != request?.status else {
//                        return
//                    }
//                    riderStatus = request?.status ?? .none
//                    self.isScheduled = ((request?.is_scheduled ?? false) && riderStatus == .searching)
//                    self.handle(request: request!)
//                } else {
//
//                    self.updateStatus = request?.status
//
//                    let previousStatus = riderStatus
//                    riderStatus = request?.status ?? .none
//                    if riderStatus != previousStatus {
//                         self.clearMapview()
//                    }
//                    if self.isScheduled {
//                        self.isScheduled = false
////                        if let yourtripsVC = Router.main.instantiateViewController(withIdentifier: Storyboard.Ids.YourTripsPassbookViewController) as? YourTripsPassbookViewController {
////                            yourtripsVC.isYourTripsSelected = true
////                            yourtripsVC.isFirstBlockSelected = false
////                            self.navigationController?.pushViewController(yourtripsVC, animated: true)
////                        }
//                        self.removeUnnecessaryView(with: .cancelled)
//                    } else {
//                        self.removeUnnecessaryView(with: .none)
//                    }
//
//                }
//            })
        }
        
        func getDataFromFirebase(providerID:Int)  {
        
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
                                self.mapViewHelper?.checkPolyline(coordinate:  LocationCoordinate(latitude: latDouble , longitude: longDouble ))
                            }
                        }
                
                    drawpolylineCheck = {
                        self.drawPolyline(isReroute: true)
                    }
//                    }
                })
        
        }
        
        // Get Services provided by Provider
        
        private func getServicesList() {
            
//            var latDouble = 0.0 //for android sending any or double
//            var longDouble = 0.0
            let currentLat =  UserDefaults.standard.double(forKey: "lat")
          //  latDouble = Double(currentLat)
            print("latitude>>>>>>>>",currentLat)
           
            let currentLong =  UserDefaults.standard.double(forKey: "long")
          //  longDouble = Double(currentLat)
            print("currentLong>>>>>",currentLong)
            
            
            if self.sourceLocationDetail?.value != nil, self.destinationLocationDetail != nil, riderStatus == .none || riderStatus == .searching { // Get Services only if location Available
                
                
                var estimateFare = LocationRequest()
                estimateFare.s_latitude = self.sourceLocationDetail?.value?.coordinate.latitude
                estimateFare.s_longitude = self.sourceLocationDetail?.value?.coordinate.longitude
                estimateFare.round_trip = 0
                estimateFare.is_round = 0
              
                self.presenter?.get(api: .servicesList, parameters: estimateFare.JSONRepresentation)
//
                
//                self.presenter?.(api: .servicesList,"\(s_latitude=13.0569467&s_longitude=80.24246900000003)", parameters: nil)
            }
        }
        
//     //   MARK:- load OTPScreen
//                func loadOtpScreen(){
//
//        //            guard self.OTPScreen == nil else {
//        //                return
//        //            }
//
//                    self.view.addBlurview { blurView in
//                        //                self.hideSimmerButton()
//                        self.OTPScreen = Bundle.main.loadNibNamed(XIB.Names.OTPScreenView, owner: self, options: nil)?.first as? OTPScreenView
//                        self.OTPScreen?.frame = CGRect(x: 0, y: self.view.frame.height / 3, width: self.view.frame.width, height: 200)
//                        blurView?.contentView.addSubview(self.OTPScreen!)
//                        //                blurView?.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.otpScreenPanGesture(sender:))))
//
//                        self.OTPScreen?.onClickOtp = {
//
//                        }
//                        self.OTPScreen?.set(number: self.userOtp ?? "0", with: { (status) in
//
////                                                if status{
////                                                    self.LoadUpdateStatusAPI(status: Constants.string.pickedUp)
////                                                    self.statusChanged(status: requestType.pickedUp.rawValue)
////                                                }else {
////
////                                                }
//                        })
//                    }
//                }
        //
        
        // Get Estimate Fare
        
        func getEstimateFareFor(serviceId : Int) {
            
            DispatchQueue.global(qos: .userInteractive).async {
                
                
                guard let sourceLocation = self.sourceLocationDetail?.value?.coordinate, let destinationLocation = self.destinationLocationDetail?.coordinate, sourceLocation.latitude>0, sourceLocation.longitude>0, destinationLocation.latitude>0, destinationLocation.longitude>0 else {
                    return
                }
                
                print("source Address",self.sourceLocationDetail?.value?.address)
                print("source latitude",sourceLocation.latitude)
                print("source longitude",sourceLocation.longitude)
                print("destination address",self.destinationLocationDetail?.address)
                print("destination latitude",destinationLocation.latitude)
                print("destination longitude",destinationLocation.longitude)
                
                
                var estimateFare = EstimateFareRequest()
                estimateFare.s_latitude = sourceLocation.latitude
                estimateFare.s_longitude = sourceLocation.longitude
//                estimateFare.d_latitude = destinationLocation.latitude
//                estimateFare.d_longitude = destinationLocation.longitude
                estimateFare.service_type = serviceId
                print("EstimateFare", estimateFare)
                //print(estimateFare)
                self.presenter?.get(api: .estimateFare, parameters: estimateFare.JSONRepresentation)
                
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
        
        func createRequest(for service : Service, isScheduled : Bool, scheduleDate : Date?, cardEntity entity : CardEntity?, paymentType : PaymentType) {
            // Validate whether the card entity has valid data
            if paymentType == .CARD && entity == nil {
                UIApplication.shared.keyWindow?.make(toast: Constants.string.selectCardToContinue.localize())
                return
            }
            
            self.showLoaderView()
            DispatchQueue.global(qos: .background).async {
                let request = Request()
                request.s_address = self.sourceLocationDetail?.value?.address
                request.s_latitude = self.sourceLocationDetail?.value?.coordinate.latitude
                request.s_longitude = self.sourceLocationDetail?.value?.coordinate.longitude
//                request.d_address = self.destinationLocationDetail?.address
//                request.d_latitude = self.destinationLocationDetail?.coordinate.latitude
//                request.d_longitude = self.destinationLocationDetail?.coordinate.longitude
                request.service_type = service.id
               // request.service_type_id = service.id
                request.payment_mode = paymentType
                request.distance = "\(service.pricing?.distance ?? 0)"
                request.use_wallet = service.pricing?.useWallet
                request.card_id = entity?.card_id
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
        
        // MARK:- Favourite Location on Other Category
        func favouriteLocationApi(in view : UIView, isAdd : Bool) {
            
            guard isAdd else { return }
            
            let service = Service() // Save Favourite location in Server
            service.type = CoreDataEntity.other.rawValue.lowercased()
             if self.destinationLocationDetail != nil {
                service.address = self.destinationLocationDetail!.address
                service.latitude = self.destinationLocationDetail!.coordinate.latitude
                service.longitude = self.destinationLocationDetail!.coordinate.longitude
            } else { return }
            
            self.presenter?.post(api: .locationServicePostDelete, data: service.toData())
            
        }
}
    
    // MARK:- PostViewProtocol
    
extension ChangeDestinationViewController : PostViewProtocol {
        
        func onError(api: Base, message: String, statusCode code: Int) {
            
            DispatchQueue.main.async {
                self.loader.isHidden = true
                if api == .locationServicePostDelete {
                    UIApplication.shared.keyWindow?.make(toast: message)
                } else {
                    if code != StatusCode.notreachable.rawValue && api != .checkRequest && api != .cancelRequest{
                        showAlert(message: message, okHandler: nil, fromView: self)
                    }
                    
                    
                }
                if api == .sendRequest {
                    self.removeLoaderView()
                }
            }
        }
    
    
    func getEstimateFare(api: Base, data: EstimateFare?) {
        
        
        print(data)
        
        if data != nil {
            if let estimated_fare = data?.estimated_fare{
//                let estimatedFareString = "C$ \(estimated_fare)"
                
                
                let estimatedFareString = "\(String.removeNil(User.main.currency)) \(Formatter.shared.limit(string: "\(estimated_fare)", maximumDecimal: 2))"
                
                self.popUpEstimatedFare(estimatedFareString: estimatedFareString)
            }
            
        }
        
        
        
        
        
    }

    
    
    func popUpEstimatedFare(estimatedFareString : String){
        
        
        
        estimateFarePop = EstimatedFareViewController(nibName: "EstimatedFareViewController", bundle: nil)
        popUpDialog = PopupDialog(viewController: estimateFarePop, buttonAlignment: .horizontal, transitionStyle: .fadeIn, tapGestureDismissal: true)
        
        estimateFarePop.estimatedFareAskLabel.text = Constants.string.confirmEstimatedFare.localize()
        estimateFarePop.estimatedFareTagLabel.text = Constants.string.EstimatedFare.localize()
        estimateFarePop.estimatedFareLabel.text = estimatedFareString
        
        estimateFarePop.cancelButton.addTarget(self, action: #selector(dismissPopUpTime), for: .touchUpInside)
        estimateFarePop.comfirmButton.addTarget(self, action: #selector(donePopUpTime), for: .touchUpInside)
        let containerAppearance = PopupDialogContainerView.appearance()
        
        containerAppearance.backgroundColor = UIColor(red:0.23, green:0.23, blue:0.27, alpha:1.00)
        // containerAppearance.cornerRadius    = 25
        present(popUpDialog, animated: true, completion: nil)
        
    }
    
    @objc func dismissPopUpTime(){
        self.popUpDialog.dismiss()
    }
             
    @objc func donePopUpTime(){
            //Here we will call the request api
        
        if let destination = self.destinationLocationDetail{
            self.updateLocation(with: destination)
        }
        self.popUpDialog.dismiss()
        
    }
    
    
    
        
        func getServiceList(api: Base, data: [Service]) {
            print("getServiceList>>>>>",data)
            
            if api == .servicesList {
            
                DispatchQueue.main.async {  // Show Services
                    self.showRideNowView(with: data)
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
                
                if self.changeDestinationDelegate != nil {
                    self.changeDestinationDelegate?.updatedDestination(destination: self.destinationLocationDetail)
                }
                
                
                
                self.navigationController?.popViewController(animated: true)
              //  riderStatus = .none
                return
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
                }
//                DispatchQueue.main.async {
//                    self.view.makeToast(message)
//                }
            } else {
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
        
}
    
    
    
extension ChangeDestinationViewController{
        
            func resetCheck(){
                updateRoute = true
                shortDistance = 0
            }
            
            func perKmUpdateRouteCheck(newLocation: CLLocation?){
                if currLocation != nil{
                    shortDistance += self.currLocation.distance(from: newLocation!)
                    print("short distance is",shortDistance)
                  //  self.showToast(string: "Distance \(shortDistance)")
                    if shortDistance >= 1000 {
                        self.resetCheck()
                    }
                }
                currLocation = newLocation
        }
}




protocol ChangeDestinationProtocol {
    func updatedDestination(destination:LocationDetail?)
}
