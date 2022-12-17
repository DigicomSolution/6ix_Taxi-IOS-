//
//  YourTripsViewController.swift
//  User
//
//  Created by CSS on 13/06/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class YourTripsDetailViewController: UITableViewController {
    
    @IBOutlet private weak var imageViewMap : UIImageView!
    @IBOutlet private weak var imageViewProvider : UIImageView!
    @IBOutlet private weak var labelProviderName : UILabel!
    @IBOutlet private weak var viewRating : FloatRatingView!
    @IBOutlet private weak var labelDate : UILabel!
    @IBOutlet private weak var labelTime : UILabel!
    @IBOutlet private weak var labelBookingId : UILabel!
    @IBOutlet private weak var labelPayViaString : UILabel!
    @IBOutlet private weak var imageViewPayVia : UIImageView!
    @IBOutlet private weak var labelPayVia : UILabel!
    @IBOutlet private weak var labelPrice : UILabel!
    @IBOutlet private weak var labelCommentsString : UILabel!
    @IBOutlet private weak var textViewComments : UITextView!
    @IBOutlet private weak var buttonCancelRide : UIButton!
    @IBOutlet private weak var buttonViewReciptAndCall : Button!
    @IBOutlet private weak var viewLocation : UIView!
    @IBOutlet private weak var labelSourceLocation : UILabel!
    @IBOutlet private weak var labelDestinationLocation : UILabel!
    @IBOutlet weak var labelStop1: UILabel!
    @IBOutlet weak var labelStop2: UILabel!
    @IBOutlet weak var labelDestinationSecond: UILabel!
    @IBOutlet weak var labelStop3: UILabel!
    @IBOutlet weak var labelDestinationThird: UILabel!
    @IBOutlet private weak var viewComments : UIView!
    @IBOutlet private weak var viewButtons : UIView!
    
    var isUpcomingTrips = false  // Boolean to handle Past and Upcoming Trips
    
    lazy var loader  : UIView = {
        return createActivityIndicator(self.view)
    }()
    
    private var heightArray : [CGFloat] = [62,150,70,145]
    private var dataSource : Request?
    private var viewRecipt : InvoiceView?
    private var blurView : UIView?
    private var requestId : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialLoads()
        self.localize()
        self.setDesign()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.setLayouts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.imageViewMap.image = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewButtons.isHidden = false
//        if isUpcomingTrips {
//        } else {
//            self.viewLocation.removeFromSuperview()
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideRecipt()
        self.viewButtons.isHidden = true
    }

    deinit {
        self.viewButtons.removeFromSuperview()
    }
    
}

// MARK:- Methods

extension YourTripsDetailViewController {
    
    // MARK:- Initial Loads
    private func initialLoads() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(self.backButtonClick))
        if #available(iOS 13.0, *) {
            self.navigationController?.navigationBar.barTintColor = UIColor.systemBackground
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
            self.navigationController?.navigationBar.tintColor = UIColor.label
        }else{
            self.navigationController?.navigationBar.tintColor = UIColor.black
        }
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }
        self.buttonCancelRide.isHidden = !isUpcomingTrips
        self.buttonCancelRide.addTarget(self, action: #selector(self.buttonCancelRideAction(sender:)), for: .touchUpInside)
        self.buttonViewReciptAndCall.addTarget(self, action: #selector(self.buttonCallAndReciptAction(sender:)), for: .touchUpInside)
        self.loader.isHidden = false
        let api : Base = self.isUpcomingTrips ? .upcomingTripDetail : .pastTripDetail
        self.presenter?.get(api: api, parameters: ["request_id":self.requestId!])
        
        self.viewRating.minRating = 1
        self.viewRating.maxRating = 5
        self.viewRating.emptyImage = #imageLiteral(resourceName: "StarEmpty")
        self.viewRating.fullImage = #imageLiteral(resourceName: "StarFull")
        self.imageViewMap.image = #imageLiteral(resourceName: "rd-map")
        UIApplication.shared.keyWindow?.addSubview(self.viewButtons)
        self.viewButtons.translatesAutoresizingMaskIntoConstraints = false
        self.viewButtons.widthAnchor.constraint(equalTo: UIApplication.shared.keyWindow!.widthAnchor, multiplier: 0.8, constant: 0).isActive = true
        self.viewButtons.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.viewButtons.bottomAnchor.constraint(equalTo: UIApplication.shared.keyWindow!.bottomAnchor, constant: -16).isActive = true 
        self.viewButtons.centerXAnchor.constraint(equalTo: UIApplication.shared.keyWindow!.centerXAnchor, constant: 0).isActive = true
        //UIApplication.shared.keyWindow?.addSubview(self.stackViewButtons)
    }
    
    
    func setId(id : Int) {
        self.requestId = id
    }
    
    // MARK:- Localize
    private func localize() {
        
        self.buttonViewReciptAndCall.setTitle((isUpcomingTrips ? Constants.string.call:Constants.string.viewRecipt).localize().uppercased(), for: .normal)
        self.labelPayViaString.text = (isUpcomingTrips ? Constants.string.paymentMethod : Constants.string.payVia).localize()
        
        if isUpcomingTrips {
            self.buttonCancelRide.setTitle(Constants.string.cancelRide.localize().uppercased(), for: .normal)
        } else {
            self.labelCommentsString.text = Constants.string.comments.localize()
        }
        self.navigationItem.title = (isUpcomingTrips ? Constants.string.upcomingTripDetails : Constants.string.pastTripDetails).localize()
        
    }
    
    // MARK:- Set Designs
    
    private func setDesign() {
        
        Common.setFont(to: self.labelCommentsString!, isTitle: true)
        Common.setFont(to: self.labelPayViaString!, isTitle:  true)
        Common.setFont(to: self.labelDate!, size : 12)
        Common.setFont(to: self.labelTime!, size : 12)
        Common.setFont(to: self.labelBookingId!)
        Common.setFont(to: self.labelPrice!)
        Common.setFont(to: self.labelProviderName!)
        Common.setFont(to: self.labelSourceLocation!, size : 12)
        Common.setFont(to: self.labelDestinationLocation!, size : 12)
        Common.setFont(to: self.labelDestinationSecond!, size : 12)
        Common.setFont(to: self.labelDestinationThird!, size : 12)
        Common.setFont(to: self.labelStop1!, size : 13)
        Common.setFont(to: self.labelStop2!, size : 13)
        Common.setFont(to: self.labelStop3!, size : 13)
        Common.setFont(to: self.labelPayVia!)
        Common.setFont(to: self.buttonViewReciptAndCall!, isTitle: true)
        if isUpcomingTrips {
            Common.setFont(to: self.buttonCancelRide!, isTitle: true)
        }
    }
    
    // MARK:- Layouts
    
    private func setLayouts() {
        
        self.imageViewProvider.makeRoundedCorner()
        let height = tableView.tableFooterView?.frame.origin.y ?? 0//(self.buttonViewReciptAndCall.convert(self.buttonViewReciptAndCall.frame, to: UIApplication.shared.keyWindow ?? self.tableView).origin.y+self.buttonViewReciptAndCall.frame.height)
        guard height <= UIScreen.main.bounds.height else { return }
        let footerHeight = UIScreen.main.bounds.height-height
        self.tableView.tableFooterView?.frame.size.height = (footerHeight-(self.buttonViewReciptAndCall.frame.height*2)-(self.navigationController?.navigationBar.frame.height ?? 0))
    }
    
    
    // MARK:- Set values
    
    private func setValues() {
      
        let mapImage = self.dataSource?.static_map?.replacingOccurrences(of: "%7C", with: "|").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        Cache.image(forUrl: mapImage) { (image) in
            if image != nil {
                DispatchQueue.main.async {
                    self.imageViewMap.image = image
                }
            }
        }
        self.labelProviderName.text = String.removeNil(self.dataSource?.provider?.first_name) + " " + String.removeNil(self.dataSource?.provider?.last_name)
        let imageUrl = String.removeNil(self.dataSource?.provider?.avatar).contains(WebConstants.string.http) ? self.dataSource?.provider?.avatar : Common.getImageUrl(for: self.dataSource?.provider?.avatar)
        Cache.image(forUrl: imageUrl) { (image) in
            if image != nil {
                DispatchQueue.main.async {
                    self.imageViewProvider.image = image
                }
            }
        }
        
        self.viewRating.rating = Float(self.dataSource?.rating?.provider_rating ?? 0)
        self.textViewComments.text = self.dataSource?.rating?.provider_comment ?? Constants.string.noComments.localize()
        self.labelSourceLocation.text = self.dataSource?.s_address
//        self.labelDestinationLocation.text = self.dataSource?.stops?[0].d_address
        
        if let stops = self.dataSource?.stops
        {
            self.labelStop2.isHidden = false
            self.labelStop3.isHidden = false
            
            self.labelDestinationSecond.isHidden = false
            self.labelDestinationThird.isHidden = false
            
            
            
            if stops.count == 1
            {
                self.labelDestinationSecond.isHidden = true
                self.labelDestinationThird.isHidden = true
                self.labelStop1.isHidden = true
                self.labelStop2.isHidden = true
                self.labelStop3.isHidden = true
                
                self.labelDestinationLocation.text = stops[0].d_address
            }
            else if stops.count == 2
            {
                self.labelDestinationThird.isHidden = true
                self.labelDestinationLocation.text = stops[0].d_address
                self.labelDestinationSecond.text = stops[1].d_address
                self.labelStop3.isHidden = true
            }
            else if stops.count == 3
            {
                self.labelDestinationLocation.text = stops[0].d_address
                self.labelDestinationSecond.text = stops[1].d_address
                self.labelDestinationThird.text = stops[2].d_address
            }
        }
        
        self.labelPayVia.text = self.dataSource?.payment_mode?.rawValue.localize()
        self.imageViewPayVia.image = self.dataSource?.payment_mode == .CARD ? #imageLiteral(resourceName: "visa") : #imageLiteral(resourceName: "money_icon")
        self.labelBookingId.text = self.dataSource?.booking_id
        
        if let dateObject = Formatter.shared.getDate(from: self.dataSource?.assigned_at, format: DateFormat.list.yyyy_mm_dd_HH_MM_ss) {
            self.labelDate.text = Formatter.shared.getString(from: dateObject, format: DateFormat.list.ddMMMyyyy)
            self.labelTime.text = Formatter.shared.getString(from: dateObject, format: DateFormat.list.hh_mm_a)
        }
        let currency = String.removeNil(User.main.currency)
        let isFlateRate = (self.dataSource?.payment?.isFlatRate ?? false)
        let total =  isFlateRate  ? "\((self.dataSource?.payment?.flat_rate ?? "0").float)" : "\(self.dataSource?.payment?.total ?? 0.0)"
//        self.labelPrice.text = currency + " \(Formatter.shared.limit(string: "\(total)", maximumDecimal: 2))"
        
        
        if let totalFloat = Float(total){
            if let tips = self.dataSource?.payment?.tips{
                let totalToPaid = tips + totalFloat
                self.labelPrice.text = currency + " \(Formatter.shared.limit(string: "\(totalToPaid)", maximumDecimal: 2))"
            }else{
                self.labelPrice.text = currency + " \(Formatter.shared.limit(string: "\(total)", maximumDecimal: 2))"
            }
        }else{
            self.labelPrice.text = currency + " \(Formatter.shared.limit(string: "\(total)", maximumDecimal: 2))"
        }
        
        
    }
    
    // MARK:- Cancel Ride
    
    @IBAction private func buttonCancelRideAction(sender : UIButton) {
        
        if isUpcomingTrips, self.dataSource?.id != nil {
            
            self.loader.isHidden = false
            // Cancel Request
            let request = Request()
            request.request_id = self.dataSource?.id
            self.presenter?.post(api: .cancelRequest, data: request.toData())
        }
        
    }
    
    // MARK:- Call and View Recipt
    
    @IBAction private func buttonCallAndReciptAction(sender : UIButton) {
        
        if isUpcomingTrips {
            if let number = self.dataSource?.provider?.mobile {
                Common.call(to: number)
            }
        } else {
            self.showRecipt()
        }
        
    }
    
    // MARK:- Show Recipt
    private func showRecipt() {
        
        if let viewReciptView = Bundle.main.loadNibNamed(XIB.Names.InvoiceView, owner: self, options: [:])?.first as? InvoiceView, self.dataSource != nil {
            viewReciptView.isShowingRecipt = true
            viewReciptView.isShowingPastRides = true
            viewReciptView.set(request: self.dataSource!)
            viewReciptView.frame = CGRect(origin: CGPoint(x: 0, y: (UIApplication.shared.keyWindow?.frame.height)!-viewReciptView.frame.height), size: CGSize(width: self.view.frame.width, height: viewReciptView.frame.height))
            self.viewRecipt = viewReciptView
            UIApplication.shared.keyWindow?.addSubview(viewReciptView)
            viewReciptView.show(with: .bottom) { [weak self] in
                self?.addBlurView()
            }
            viewReciptView.onClickPaynow = { [unowned self]_ in
                 self.hideRecipt()
            }
            viewReciptView.onDoneClick = { [unowned self]_ in
                self.hideRecipt()
            }
        }
        
    }
    
    
    private func addBlurView() {
        
        self.blurView = UIView(frame: UIScreen.main.bounds)
        self.blurView?.alpha = 0
        self.blurView?.backgroundColor = .black
        self.blurView?.isUserInteractionEnabled = true
        self.view.addSubview(self.blurView!)
        self.blurView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.hideRecipt)))
        UIView.animate(withDuration: 0.2, animations: {
            self.blurView?.alpha = 0.6
        })
        
    }
    
    // MARK:- Remove Recipt
   @IBAction private func hideRecipt() {
        
        self.viewRecipt?.dismissView(onCompletion: {
            self.viewRecipt = nil
            self.blurView?.removeFromSuperview()
        })
        
    }
    
}

// MARK:- Postview Protocol

extension YourTripsDetailViewController: PostViewProtocol {
    
    func onError(api: Base, message: String, statusCode code: Int) {
        DispatchQueue.main.async {
            self.loader.isHidden = true
            showAlert(message: message, okHandler: nil, fromView: self)
        }
    }
    
    
    func getRequestArray(api: Base, data: [Request]) {
        
        print("gettriprequest>>>>",data)
    
        if data.count>0 {
            self.dataSource = data.first
        }
        
        DispatchQueue.main.async {
            self.loader.isHidden = true
            self.setValues()
        }
    
        
    }
    
    
}

//// MARK:- ScrollView Delegate
//
//extension YourTripsDetailViewController {
//
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        guard scrollView.contentOffset.y<0 else { return }
//
//        let inset = abs(scrollView.contentOffset.y/imageViewMap.frame.height)
//
//        self.imageViewMap.transform = CGAffineTransform(scaleX: 1+inset, y: 1+inset)
//
//    }
//
//}

extension YourTripsDetailViewController {
    
   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    if isUpcomingTrips && indexPath.row == 3 {
        return 0
    } else  {
         return heightArray[indexPath.row]
    }

    }
    
}



