

//
//  AppDelegate.swift
//  Centros_Camprios
//
//  Created by imac on 12/18/17.
//  Copyright © 2017 Appoets. All rights reserved.
//

import UIKit
import UserNotifications
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift
import CoreData
import Intents
import Crashlytics
import Fabric
import Stripe
import FirebaseMessaging
import FirebaseCore
import GoogleSignIn
import AuthenticationServices
import SwiftKeychainWrapper
import DTTJailbreakDetection
import PopupDialog

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var reachability : Reachability?
    static let shared = AppDelegate()
    let gcmMessageIDKey = "gcm.message_id"
    var locationManager:CLLocationManager!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        guard !DTTJailbreakDetection.isJailbroken() else{
            let sb = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "jailbrokenDeviceVC")
            self.window?.rootViewController = sb
            self.window?.makeKeyAndVisible()
            showAppTerminateAlert(title: "6ixTaxi", message: "This app is not allowed to run on insecure (jailbroken) devices")
            return false
        }
        
        
        FirebaseApp.configure()
        
        UIApplication.shared.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
        self.appearence()
        self.google()
        self.IQKeyboard()
        //  self.siri()
        
        
        self.stripe()
        window?.rootViewController = Router.setWireFrame()
        window?.becomeKey()
        window?.makeKeyAndVisible()
        DispatchQueue.global(qos: .background).async {
            self.startReachabilityChecking()
        }
        self.checkUpdates()
        
        if #available(iOS 13.0, *)
        {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            appleIDProvider.getCredentialState(forUserID: KeychainWrapper.standard.string(forKey: "UserIdentifier") ?? "") { (credentialState, error) in
                switch credentialState {
                case .authorized:
                    // The Apple ID credential is valid. Show Home UI Here
                    DispatchQueue.main.async {
                        //                    HomeViewController.Push()
                        print("YAY! Valid Credentials")
                    }
                    break
                case .revoked:
                    // The Apple ID credential is revoked. Show SignIn UI Here.
                    DispatchQueue.main.async {
                        //                    HomeViewController.Push()
                        print("Revoked")
                    }
                    break
                case .notFound:
                    // No credential was found. Show SignIn UI Here.
                    
                    DispatchQueue.main.async {
                        //                    HomeViewController.Push()
                        print("NOT FOUND")
                    }
                    break
                default:
                    break
                }
            }
        }
        initiateLocationManager()
         return true
    }
    
    func showAppTerminateAlert(title: String, message: String){
        
        let alert = PopupDialog(title: title, message: message)
        let action = DestructiveButton(title: "Close app") {
            exit(0)
        }
        alert.addButton(action)
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK:- Core Data
    
    lazy var persistentContainer : NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (descriptionString, error) in
            
            print("Error in Context  ",error ?? "")
            
        })
        return container
    }()
}

extension AppDelegate {
    
    
    func initiateLocationManager(){
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 200
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    // MARK:- Appearence
    private func appearence() {
        
        if let languageStr = UserDefaults.standard.value(forKey: Keys.list.language) as? String, let language = Language(rawValue: languageStr) {
            setLocalization(language: language)
        }else {
            setLocalization(language: .english)
        }
//        UINavigationBar.appearance().barTintColor = .white
//        UINavigationBar.appearance().tintColor = .darkGray
        var attributes = [NSAttributedString.Key : Any]()
        attributes.updateValue(UIColor.black, forKey: .foregroundColor)
        attributes.updateValue(UIFont(name: FontCustom.Bold.rawValue, size: 16.0)!, forKey : NSAttributedString.Key.font)
        UINavigationBar.appearance().titleTextAttributes = attributes
        attributes.updateValue(UIFont(name:FontCustom.Medium.rawValue, size: 18.0)!, forKey : NSAttributedString.Key.font)
        if #available(iOS 11.0, *) {
            UINavigationBar.appearance().largeTitleTextAttributes = attributes
        }
        
        UIPageControl.appearance().pageIndicatorTintColor = .lightGray
        UIPageControl.appearance().currentPageIndicatorTintColor = .primary
        UIPageControl.appearance().backgroundColor = .clear
        
    }
    
    // MARK:- Check Update
    private func checkUpdates() {
        
        var request = ChatPush()
        request.version = Bundle.main.getVersion()
        request.device_type = .ios
        request.sender = .user
        Webservice().retrieve(api: .versionCheck, url: nil, data: request.toData(), imageData: nil, paramters: nil, type: .POST) { (error, data) in
            guard let responseObject = data?.getDecodedObject(from: ChatPush.self),
                let forceUpdate = responseObject.force_update,
                forceUpdate,
                let appUrl = responseObject.url,
                let urlObject = URL(string: appUrl),
                UIApplication.shared.canOpenURL(urlObject)
                else {
                    return
            }
            
            func showUpdateUI() {
                DispatchQueue.main.async {
                    let alert = showAlert(message: Constants.string.newVersionAvailableMessage.localize(), actionButtonTitle: Constants.string.update.localize(), handler: { (_) in
                        UIApplication.shared.open(urlObject, options: [:], completionHandler: nil)
                    }, showCancel: true)
                    UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
                }
            }
            showUpdateUI()
        }
    }
    
}



    
    // MARK:- Google
    
extension AppDelegate {
    
    private func google(){
        
        GMSServices.provideAPIKey(googleMapKey)
        GMSPlacesClient.provideAPIKey(googleMapKey)
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url as! URL)
    }
    
    private func IQKeyboard() {
        IQKeyboardManager.shared.enable = false
    }
    
    private func siri() {
        
        if INPreferences.siriAuthorizationStatus() != .authorized {
            INPreferences.requestSiriAuthorization { (status) in
                print("Is Siri Authorized  -",status == .authorized)
            }
        }
    }
    
    //MARK:- Stripe
    
    private func stripe(){
        
        STPAPIClient.shared.publishableKey = stripePublishableKey
        
    }
}

// MARK:- Reachability

extension AppDelegate {
    
    // MARK:- Register Push
    private func registerPush(forApp application : UIApplication){
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
//        let center = UNUserNotificationCenter.current()
//        center.requestAuthorization(options:[.alert, .sound]) { (granted, error) in
//
//            if granted {
//                DispatchQueue.main.async {
//                    application.registerForRemoteNotifications()
//                }
//            }
//        }
    }
    
    // MARK:- Offline Booking on No Internet Connection
    
    func startReachabilityChecking() {
        
        self.reachability = Reachability()
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityAction), name: NSNotification.Name.reachabilityChanged, object: nil)
      //  self.reachability?.startNotifier()
        do {
            try self.reachability?.startNotifier()
        } catch let err {
            print("Error in Reachability", err.localizedDescription)
        }
    }
    

    func stopReachability() {
        // MARK:- Stop Reachability
        self.reachability?.stopNotifier()
    }
    
    // MARK:- Reachability Action
    
    @objc private func reachabilityAction(notification : Notification) {
        
        print("Reachability \(self.reachability?.connection.description ?? .Empty)", #function)
        guard self.reachability != nil else { return }
        if self.reachability!.connection == .none && riderStatus == .none {
            if let rootView = UIApplication.shared.keyWindow?.rootViewController?.children.last, rootView.children.count > 0 , (rootView.children.last is HomeViewController), retrieveUserData() {
                rootView.present(id: Storyboard.Ids.OfflineBookingViewController, animation: true)
            }
        } else {
            (UIApplication.topViewController() as? OfflineBookingViewController)?.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
}



// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        let userInfo = notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            debugPrint("Message ID: \(messageID)")
        }
        print("<<--\(userInfo)")
        debugPrint(userInfo)
        //Handle the notification ON APP
//        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler([.sound,.alert,.badge])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
    
        let userInfo = response.notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            debugPrint("Message ID: \(messageID)")
        }
        print("<<--\(userInfo)")
        
        //Handle the notification ON BACKGROUND
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")
        deviceTokenString = fcmToken ?? ""
      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    func resetBadgesCount(){
        if UIApplication.shared.applicationIconBadgeNumber > 0{
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}

////////////////
extension AppDelegate {
    

//    private func application(application: UIApplication,
//                         didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
//            Messaging.messaging().apnsToken = deviceToken as Data
//    //        let deviceTokenString = deviceToken.hexString
//    //        UserDefaults.standard.setValue(deviceTokenString, forKey: self.globalR.devicetoken)
//            print("Registered Notification")
//        }
    // MARK: - FIREBASE
        
        func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any])
        {
            
            if let messageID = userInfo[gcmMessageIDKey]
            {
                debugPrint("Message ID: \(messageID)")
            }
            // Print full message.
            print("<<--\(userInfo)")
            debugPrint(userInfo)
        }
        
        func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                         fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
        {
            if let messageID = userInfo[gcmMessageIDKey]
            {
                debugPrint("Message ID: \(messageID)")
            }
            // Print full message.
            print("<<--\(userInfo)")
            debugPrint(userInfo)
            completionHandler(UIBackgroundFetchResult.newData)
        }
        func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
        {
            debugPrint("Unable to register for remote notifications: \(error.localizedDescription)")
        }

        func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
        {
            let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
            print(token)
            debugPrint("APNs token retrieved: \(deviceToken)")
#if DEVELOPMENT
       //Develop
       Messaging.messaging().setAPNSToken(deviceToken as Data, type: .sandbox)
   #else
       //Production
       Messaging.messaging().setAPNSToken(deviceToken as Data, type: .prod)
   #endif
        }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        resetBadgesCount()
        UIPasteboard.general.items = []
        print("Enter background")
        makeWindowPrivacyProtected()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        resetBadgesCount()
        removePrivacyProtectionFromWindow()
        print("Enter foreground")
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        resetBadgesCount()
    }
    

    private func makeWindowPrivacyProtected() {
        guard let rootVC = self.window?.rootViewController else {
            return
        }

        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = rootVC.view.frame
        
        blurView.tag = 191
        
        rootVC.view.addSubview(blurView)
    }

    private func removePrivacyProtectionFromWindow() {
        guard let rootVC = self.window?.rootViewController else {
            return
        }
        
        rootVC.view.viewWithTag(191)?.removeFromSuperview()
    }
    
    
    
    
}

extension AppDelegate: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationCordinates : CLLocationCoordinate2D = (manager.location?.coordinate)!
        
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        GMSGeocoder.addressFormCoordinate(coordinate: locationCordinates) { myLocation, error in
            print(myLocation?.country ?? "No Country Found")
            userCurrentLocation = myLocation
            
            
        }
    }
     
        
    

}
