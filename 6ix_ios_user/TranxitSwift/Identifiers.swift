//
//  Identifiers.swift
//  User
//
//  Created by imac on 12/19/17.
//  Copyright © 2017 Appoets. All rights reserved.
//

import Foundation

// MARK:- Storyboard Id
struct Storyboard {
    
    static let Ids = Storyboard()
    
    let LaunchViewController = "LaunchViewController"
    let EmailViewController = "EmailViewController"
    let PasswordViewController = "PasswordViewController"
    let ForgotPasswordViewController = "ForgotPasswordViewController"
    let SocialLoginViewController = "SocialLoginViewController"
    let SignUpTableViewController = "SignUpUserTableViewController"
    let WalkThroughPreviewController = "WalkThroughPreviewController"
    let DrawerController = "DrawerController"
    let ProfileViewController = "ProfileViewController"
    let LocationSelectionViewController = "LocationSelectionViewController"
    let PaymentViewController = "PaymentViewController"
    let YourTripsPassbookViewController = "YourTripsPassbookViewController"
    let CouponViewController = "CouponViewController"
    let WalletViewController = "WalletViewController"
    let HelpViewController = "HelpViewController"
    let SettingTableViewController = "SettingTableViewController"
    let ChangeResetPasswordController = "ChangeResetPasswordController"
    let YourTripsDetailViewController = "YourTripsDetailViewController"
    let OfflineBookingViewController = "OfflineBookingViewController"
    let SingleChatController = "SingleChatController"
    let AddCardViewController = "AddCardViewController"
    let SideBarTableViewController = "SideBarTableViewController"
    let LaunchNavigationController = "LaunchNavigationController"
    let ConvergeElavonViewController = "ConvergeElavonViewController"
    let CoporateUserViewController = "CoporateUserViewController"
    let FeedbackViewController = "FeedbackViewController"
    
    
    let SignUpMobileNumberViewController = "SignUpMobileNumberViewController"
    let VerifyMobileNumberViewController = "VerifyMobileNumberViewController"
    
    
    let ChangeDestinationViewController =  "ChangeDestinationViewController"

}





//MARK:- XIB Cell Names

struct XIB {
    
    static let Names = XIB()
    let WalkThroughView = "WalkThroughView"
    let LocationTableViewCell = "LocationTableViewCell"
    let LocationHeaderTableViewCell = "LocationHeaderTableViewCell"
    let ServiceSelectionCollectionViewCell = "ServiceSelectionCollectionViewCell"
    let LocationSelectionView = "LocationSelectionView"
    let ServiceSelectionView = "ServiceSelectionView"
    let RequestSelectionView = "RequestSelectionView"
    let LoaderView = "LoaderView"
    let RideStatusView = "RideStatusView"
    let InvoiceView = "InvoiceView"
    let RatingView = "RatingView"
    let YourTripCell = "YourTripCell"
    let PassbookTableViewCell = "PassbookTableViewCell"
    let RateView = "RateView"
    let RideNowView = "RideNowView"
    let CancelListTableViewCell = "CancelListTableViewCell"
    let ReasonView = "ReasonView"
    let CouponCollectionViewCell = "CouponCollectionViewCell"
    let CouponView = "CouponView"
    let PassbookWalletTransaction = "PassbookWalletTransaction"
    let OTPScreenView = "OTPScreenView"
    
    let TowInstructionsView = "TowInstructionsView"
    let WalletAlertView = "WalletAlertView"
    let feedbackCell = "feedbackCell"
}




//MARK:- Notification

extension Notification.Name {
   public static let providers = Notification.Name("providers")
}



