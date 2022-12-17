//
//  Global.swift
//  User
//
//  Created by imac on 1/1/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit
import Foundation
import PopupDialog
import AudioUnit

var currentBundle : Bundle!
var selectedShortCutItem : CoreDataEntity?
var selectedLanguage : Language = .english
var userCurrentLocation:MyLocation?
var currentCountryShortName : String?
var currentCountry : String?{
    didSet{
        let countries = Common.getCountries()
        let country = countries.filter{$0.name == currentCountry}.first
        currentCountryShortName = country?.code.lowercased() ?? ""
        print("currentCountryShortName \(currentCountryShortName ?? "" )")
        
    }
}

// Store Favourite Locations

typealias FavouriteLocation = (address :String,location :LocationDetail?)

var favouriteLocations = [FavouriteLocation]()


// MARK:- Store Favourite Locations

func storeFavouriteLocations(from locationService : LocationService?) {
    favouriteLocations.removeAll()
    let coreData = CoreDataHelper()
    // Append Favourite Locations to Service
    if let location = locationService?.home?.first, let address = location.address, let latiude = location.latitude, let longitude = location.longitude {
        coreData.insert(data: LocationDetail(address, LocationCoordinate(latitude: latiude, longitude: longitude)), entityName: .home)
        favouriteLocations.append((Constants.string.home.localize(), LocationDetail(address, LocationCoordinate(latitude: latiude, longitude: longitude))))
    } else {
        coreData.deleteData(from: CoreDataEntity.home.rawValue)
        favouriteLocations.append((Constants.string.home.localize(), nil))
    }
    
    if let location = locationService?.work?.first, let address = location.address, let latiude = location.latitude, let longitude = location.longitude {
        coreData.insert(data: LocationDetail(address, LocationCoordinate(latitude: latiude, longitude: longitude)), entityName: .work)
        favouriteLocations.append((Constants.string.work.localize(), LocationDetail(address, LocationCoordinate(latitude: latiude, longitude: longitude))))
    } else {
        coreData.deleteData(from: CoreDataEntity.work.rawValue)
        favouriteLocations.append((Constants.string.work.localize(), nil))
    }
    
    if let recents = locationService?.recent {
        
        for recent in recents where recent.address != nil && recent.latitude != nil && recent.longitude != nil{
        favouriteLocations.append((recent.address!, LocationDetail(recent.address!, LocationCoordinate(latitude: recent.latitude!, longitude: recent.longitude!))))
        }
    }
    
    if let others = locationService?.others {
        
        for other in others where other.address != nil && other.latitude != nil && other.longitude != nil{
            favouriteLocations.append((other.address!, LocationDetail(other.address!, LocationCoordinate(latitude: other.latitude!, longitude: other.longitude!))))
        }
    }
    
}


//MARK:- Show Alert
func showAlert(message : String?, actionButtonTitle: String = Constants.string.OK, handler : ((UIAlertAction) -> Void)? = nil, showCancel: Bool = false)->UIAlertController{
    
    let alert = UIAlertController(title: AppName, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title:  actionButtonTitle, style: .default, handler: handler))
    if showCancel{
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    }
    //alert.view.tintColor = .primary
    return alert
    
    
}


func toastSuccess(_ view:UIView,message:NSString,smallFont:Bool,isPhoneX:Bool, color:UIColor){
    var labelView = UIView()
    labelView.showAnimateView(labelView, isShow: true, direction: .top)
    if(isPhoneX){
        labelView = UILabel(frame: CGRect(x: 0,y: 0,width:view.frame.size.width, height: 80))
    }else{
        labelView = UILabel(frame: CGRect(x: 0,y: 0,width:view.frame.size.width, height: 60))
    }
    labelView.backgroundColor = color
    
    //UIColor(red: 35/255, green: 86/255, blue: 142/255, alpha: 1)
    
    
    let  toastLabel = UILabel(frame: CGRect(x: 0,y:(labelView.frame.size.height/2),width:view.frame.size.width, height: labelView.frame.size.height/2))
    toastLabel.textColor = UIColor.white
    toastLabel.textAlignment = NSTextAlignment.center
    toastLabel.numberOfLines = 2
    if(smallFont){
        // toastLabel.font = UIFont.boldSystemFont(ofSize: 10)
        toastLabel.font = UIFont(name: "Avenir Next Medium", size: 14)
    }else{
        // toastLabel.font = toastLabel.font.withSize(14)
        toastLabel.font = UIFont(name: "Avenir Next Medium", size: 18)
    }
    
    labelView.addSubview(toastLabel)
    view.addSubview(labelView)
    toastLabel.text = message as String
    labelView.alpha = 1.0
    let deadlineTime = DispatchTime.now() + .seconds(2)
    DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
        labelView.alpha = 0.0
        labelView.showAnimateView(labelView, isShow: false, direction: .bottom)
        labelView.removeFromSuperview()
    }
}

//MARK:- Show Alert With Action

 func showAlert(message : String?, okHandler : (()->Void)?, fromView : UIViewController){
    
   /* let alert = UIAlertController(title: AppName,
                                  message: message,
        preferredStyle: .alert)
    let okAction = UIAlertAction(title: Constants.string.OK, style: .default, handler: okHandler)
    
    let cancelAction = UIAlertAction(title: Constants.string.Cancel, style: .destructive, handler: nil)
    
    alert.addAction(okAction)
    alert.addAction(cancelAction)
    alert.view.tintColor = .primary */
    
    let alert = PopupDialog(title: message, message: nil)
    let okButton =  PopupDialogButton(title: Constants.string.OK.localize(), action: {
        okHandler?()
        alert.dismiss()
    })
    alert.transitionStyle = .zoomIn
    alert.addButton(okButton)
    fromView.present(alert, animated: true, completion: nil)
    
}


//MARK:- Show Alert With Action

func showAlert(message : String?, okHandler : (()->Void)?, cancelHandler : (()->Void)?, fromView : UIViewController){
    
    let alert = PopupDialog(title: message, message: nil)
    let okButton =  PopupDialogButton(title: Constants.string.OK.localize(), action: {
        okHandler?()
        alert.dismiss()
    })
    let cancelButton =  PopupDialogButton(title: Constants.string.Cancel.localize(), action: {
        cancelHandler?()
        alert.dismiss()
    })
    alert.transitionStyle = .zoomIn
    cancelButton.titleColor = .red
    okButton.titleColor = .primary
    alert.addButton(okButton)
    alert.addButton(cancelButton)
    fromView.present(alert, animated: true, completion: nil)
    
}

//MARK:- ShowLoader

internal func createActivityIndicator(_ uiView : UIView)->UIView{
    
    let container: UIView = UIView(frame: CGRect.zero)
    container.layer.frame.size = uiView.frame.size
    container.center = CGPoint(x: uiView.bounds.width/2, y: uiView.bounds.height/2)
    container.backgroundColor = UIColor(white: 0.2, alpha: 0.3)
    
    let loadingView: UIView = UIView()
    loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
    loadingView.center = container.center
    loadingView.backgroundColor = .primary//UIColor(white:0.1, alpha: 0.7)
    loadingView.clipsToBounds = true
    loadingView.layer.cornerRadius = 10
    loadingView.layer.shadowRadius = 5
    loadingView.layer.shadowOffset = CGSize(width: 0, height: 4)
    loadingView.layer.opacity = 2
    loadingView.layer.masksToBounds = false
    loadingView.layer.shadowColor = UIColor.gray.cgColor
    
    let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    actInd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
    actInd.clipsToBounds = true
    actInd.style = .whiteLarge
    
    actInd.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
    loadingView.addSubview(actInd)
    container.addSubview(loadingView)
    container.isHidden = true
    uiView.addSubview(container)
    actInd.startAnimating()
    
    return container
    
}




internal func storeInUserDefaults(){
    
    let data = NSKeyedArchiver.archivedData(withRootObject: User.main)
    UserDefaults.standard.set(data, forKey: Keys.list.userData)
    let groupDefaults = UserDefaults(suiteName: Keys.list.appGroup)
    groupDefaults?.set(true, forKey: Keys.list.isLoggedIn)
    UserDefaults.standard.synchronize()
    groupDefaults?.synchronize()
    print("Store in UserDefaults--", UserDefaults.standard.value(forKey: Keys.list.userData) ?? "Failed")
}

// Retrieve from UserDefaults
internal func retrieveUserData()->Bool{
    
    if let data = UserDefaults.standard.object(forKey: Keys.list.userData) as? Data, let userData = NSKeyedUnarchiver.unarchiveObject(with: data) as? User {
        User.main = userData
    }
    return User.main.id != nil
    
}

// Clear UserDefaults
internal func clearUserDefaults(){
    
    User.main = initializeUserData()  // Clear local User Data
    UserDefaults.standard.set(nil, forKey: Keys.list.userData)
    let groupDefaults = UserDefaults(suiteName: Keys.list.appGroup)
    groupDefaults?.set(false, forKey: Keys.list.isLoggedIn)
    UserDefaults.standard.removeVolatileDomain(forName: Bundle.main.bundleIdentifier!)
    UserDefaults.standard.synchronize()
    groupDefaults?.synchronize()
    print("Clear UserDefaults--", UserDefaults.standard.value(forKey: Keys.list.userData) ?? "Success")
    
}

// MARK:- Force Logout

func forceLogout(with message : String? = nil) {
    let user = User()
    user.id = User.main.id
    Webservice().retrieve(api: .logout, url: nil, data: user.toData(), imageData: nil, paramters: nil, type: .POST, completion: nil)
    DispatchQueue.main.async { // stopping timer on unauthorized status
         HomePageHelper.shared.stopListening()
    }
    clearUserDefaults()
    UIApplication.shared.windows.last?.rootViewController?.popOrDismiss(animation: true)
    let navigationController = UINavigationController(rootViewController: Router.user.instantiateViewController(withIdentifier: Storyboard.Ids.LaunchViewController))
    navigationController.isNavigationBarHidden = true
    UIApplication.shared.windows.first?.rootViewController = navigationController
    UIApplication.shared.windows.first?.makeKeyAndVisible()
    if message != nil {
        UIApplication.shared.keyWindow?.makeToast(message)
    }
}

// MARK:- Add Vibration

func vibrate(with vibration : Vibration) {
    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
}

// Initialize User

internal func initializeUserData()->User
{
    return User()
}


func setLocalization(language : Language){
   
    if let path = Bundle.main.path(forResource: language.code, ofType: "lproj"), let bundle = Bundle(path: path) {
        
        let attribute : UISemanticContentAttribute = language == .arabic ? .forceRightToLeft : .forceLeftToRight
        UIView.appearance().semanticContentAttribute = attribute
        selectedLanguage = language
        currentBundle = bundle
        
    } else {
        currentBundle = .main
    }
    
    
}

import GoogleMaps
class Global {

class var shared : Global {
    
    struct Static {
        static let instance : Global = Global()
    }
    return Static.instance
    }
    var distance = 0.0
    var lat = 0.0
    var long = 0.0
    var newLat = 0.0
    var newLong = 0.0
    var polyline = GMSPolyline()
    
    var sourceLatitute   = 0.0
    var sourceLongtitude = 0.0
    var destinationLatitde = 0.0
    var destinationLontitude = 0.0
    var driver_lat = 0.0
    var driver_long = 0.0
    var isOnRide = false
    var isPickup = false
    var isStarted = false
    
    var invoiceCount = 0
    
    var isGetNullInTotal = false
    
    
    var getZeroo = ""
    
}
