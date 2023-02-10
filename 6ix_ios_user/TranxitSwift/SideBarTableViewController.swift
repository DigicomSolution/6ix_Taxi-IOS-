//
//  SideBarTableViewController.swift
//  User
//
//  Created by CSS on 02/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class SideBarTableViewController: UITableViewController {
    
    @IBOutlet private var imageViewProfile : UIImageView!
    @IBOutlet private var labelName : UILabel!
    @IBOutlet private var labelEmail : UILabel!
    @IBOutlet private var viewShadow : UIView!
    @IBOutlet private weak var profileImageCenterContraint : NSLayoutConstraint!
    
//     private let sideBarList = [Constants.string.payment,Constants.string.yourTrips,Constants.string.coupon,Constants.string.wallet,Constants.string.passbook,Constants.string.settings,Constants.string.help,Constants.string.share,Constants.string.inviteReferral,Constants.string.faqSupport,Constants.string.termsAndConditions,Constants.string.privacyPolicy,Constants.string.logout]
    
    private var sideBarList:[String]{

        if let userLocation = userCurrentLocation, userLocation.isPakistan{
            return [
                    Constants.string.yourTrips,
                    Constants.string.offer,
//                    Constants.string.wallet,
                    Constants.string.CoprateUser,
                    Constants.string.settings,
                    Constants.string.help,
                    Constants.string.share,
                    Constants.string.becomeADriver,
                    Constants.string.logout]
        }

       return [Constants.string.payment,
               Constants.string.yourTrips,
               Constants.string.offer,
//               Constants.string.wallet,
               Constants.string.CoprateUser,
               Constants.string.settings,
               Constants.string.help,
               Constants.string.share,
               Constants.string.becomeADriver,
               Constants.string.logout]
    }
    
    private let cellId = "cellId"
    
    private lazy var loader : UIView = {
        
        return createActivityIndicator(self.view)
        
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let viewControllerName = String.init(describing: self.classForCoder)
        print("VCName***: \(viewControllerName)")
        self.initialLoads()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.localize()
        self.setValues()
        self.navigationController?.isNavigationBarHidden = true
        //self.prefersStatusBarHidden = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.setLayers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       // self.prefersStatusBarHidden = false
    }
    
}

// MARK:- Methods

extension SideBarTableViewController {
    
    private func initialLoads() {

        // self.drawerController?.fadeColor = UIColor
        self.drawerController?.shadowOpacity = 0.2
        let fadeWidth = self.view.frame.width*(0.2)
        //self.profileImageCenterContraint.constant = 0//-(fadeWidth/3)
        self.drawerController?.drawerWidth = Float(self.view.frame.width - fadeWidth)
        self.viewShadow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.imageViewAction)))
    }
    
    // MARK:- Set Designs
    
    private func setLayers(){
        
        //self.viewShadow.addShadow()
        self.imageViewProfile.makeRoundedCorner()
        
    }
    
    
    // MARK:- Set Designs
    
    private func setDesigns () {
        
        Common.setFont(to: labelName!)
        Common.setFont(to: labelEmail!, size : 12)
    }
    
    
    //MARK:- SetValues
    
    private func setValues(){

        let url = (User.main.picture?.contains(WebConstants.string.http) ?? false) ? User.main.picture : Common.getImageUrl(for: User.main.picture)
        
        Cache.image(forUrl: url) { (image) in
            DispatchQueue.main.async {
                self.imageViewProfile.image = image == nil ? #imageLiteral(resourceName: "userPlaceholder") : image
            }
        }
        self.labelName.text = String.removeNil(User.main.firstName)+" "+String.removeNil(User.main.lastName)
        self.labelEmail.text = User.main.email
        self.setDesigns()
    }
    
    
    
    // MARK:- Localize
    private func localize(){
        
        self.tableView.reloadData()
        
    }
    
    // MARK:- ImageView Action
    
    @IBAction private func imageViewAction() {
        
        let homeVC = Router.user.instantiateViewController(withIdentifier: Storyboard.Ids.ProfileViewController)
        (self.drawerController?.getViewController(for: .none) as? UINavigationController)?.pushViewController(homeVC, animated: true)
        self.drawerController?.closeSide()
        
    }
    
    
    // MARK:- Selection Action For TableView
    
    private func select(at indexPath : IndexPath) {
        
       if let userLocation = userCurrentLocation, userLocation.isPakistan{
           switch (indexPath.section,indexPath.row) {

   //        case (0,0):
   //            self.push(to: Storyboard.Ids.PaymentViewController)
           case (0,0):
   //            fallthrough
   //        case (0,4):
               if let vc = self.drawerController?.getViewController(for: .none)?.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.YourTripsPassbookViewController) as? YourTripsPassbookViewController {
                   vc.isYourTripsSelected = indexPath.row == 0
                   if indexPath.row == 0{
                       vc.isFromTrips = true
                   }
                   (self.drawerController?.getViewController(for: .none) as? UINavigationController)?.pushViewController(vc, animated: true)
               }
           case (0,1):
               self.push(to: CouponCollectionViewController())
//           case (0,2):
//              // self.push(to: Storyboard.Ids.WalletViewController)
//               break
           case (0,2):
               self.push(to: Storyboard.Ids.CoporateUserViewController)
           case (0,3):
               self.push(to: Storyboard.Ids.SettingTableViewController)
           case (0,4):
               self.push(to: Storyboard.Ids.HelpViewController)
           case (0,5):
               (self.drawerController?.getViewController(for: .none)?.children.first as? HomeViewController)?.share(items: ["\(AppName)", URL.init(string: baseUrl)!])
           case (0,6):
               Common.open(url: driverUrl)
           case (0,7):
               self.logout()

           default:
               break
           }
       }else {
           switch (indexPath.section,indexPath.row) {

           case (0,0):
               self.push(to: Storyboard.Ids.PaymentViewController)
           case (0,1):
               if let vc = self.drawerController?.getViewController(for: .none)?.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.YourTripsPassbookViewController) as? YourTripsPassbookViewController {
                   vc.isYourTripsSelected = indexPath.row == 1
                   if indexPath.row == 1{
                       vc.isFromTrips = true
                   }
                   (self.drawerController?.getViewController(for: .none) as? UINavigationController)?.pushViewController(vc, animated: true)
               }
           case (0,2):
               self.push(to: CouponCollectionViewController())
//           case (0,3):
//              // self.push(to: Storyboard.Ids.WalletViewController)
//               break
           case (0,3):
               self.push(to: Storyboard.Ids.CoporateUserViewController)
           case (0,4):
               self.push(to: Storyboard.Ids.SettingTableViewController)
           case (0,5):
               self.push(to: Storyboard.Ids.HelpViewController)
           case (0,6):
               (self.drawerController?.getViewController(for: .none)?.children.first as? HomeViewController)?.share(items: ["\(AppName)", URL.init(string: baseUrl)!])
           case (0,7):
               Common.open(url: driverUrl)
           case (0,8):
               self.logout()

           default:
               break
           }
       }
        
    }
    
    private func push(to identifier : String) {
         let viewController = self.storyboard!.instantiateViewController(withIdentifier: identifier)
        (self.drawerController?.getViewController(for: .none) as? UINavigationController)?.pushViewController(viewController, animated: true)
        
    }
    
    private func push(to vc : UIViewController) {
        (self.drawerController?.getViewController(for: .none) as? UINavigationController)?.pushViewController(vc, animated: true)
        
    }
    
    // MARK:- Logout
    
    private func logout() {
        
        let alert = UIAlertController(title: nil, message: Constants.string.areYouSureWantToLogout.localize(), preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: Constants.string.logout.localize(), style: .destructive) { (_) in
            self.loader.isHidden = false
            self.presenter?.post(api: .logout, data: nil)
        }
        
        let cancelAction = UIAlertAction(title: Constants.string.Cancel.localize(), style: .cancel, handler: nil)
        
        //alert.view.tintColor = .primary
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}


// MARK:- TableView

extension SideBarTableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableCell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if #available(iOS 13.0, *) {
            tableCell.textLabel?.textColor = .label
        } else {
            // Fallback on earlier versions
            tableCell.textLabel?.textColor = .secondary
        }
        let title = sideBarList[indexPath.row].localize().capitalizingFirstLetter()
        let isWallet = title == Constants.string.wallet.localize().capitalizingFirstLetter()
        
        tableCell.textLabel?.text = title
        tableCell.detailTextLabel?.text = isWallet ? "\(User.main.walletBalance)" : "" //#00D100
        tableCell.detailTextLabel?.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        Common.setFont(to: tableCell.detailTextLabel!, isTitle: true)
        tableCell.textLabel?.textAlignment = .left
        Common.setFont(to: tableCell.textLabel!, isTitle: true)
        return tableCell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sideBarList.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.select(at: indexPath)
        self.drawerController?.closeSide()
    }
    
}


// MARK:- PostViewProtocol

extension SideBarTableViewController : PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        
        DispatchQueue.main.async {
            self.loader.isHidden = true
            showAlert(message: message, okHandler: nil, fromView: self)
        }
    }
    
    func success(api: Base, message: String?) {
        DispatchQueue.main.async {
            self.loader.isHidden = true
            forceLogout()
        }
    }
}

