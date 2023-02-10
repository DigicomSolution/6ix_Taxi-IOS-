//
//  MultiLocationSelectionViewController.swift
//  TranxitUser
//
//  Created by Somi on 30/05/2020.
//  Copyright © 2020 Appoets. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import MapKit
import IQKeyboardManagerSwift

protocol MultiLocationVCDelegate {
    func backPressed(gmHelperRef: GoogleMapsHelper)
}

class MultiLocationSelectionViewController: UIViewController,GMSMapViewDelegate {
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var topView: View!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var sourceTextfield: UITextField!
    @IBOutlet weak var mTableView: UITableView!
    @IBOutlet weak var tableViewBottom: UITableView!
    @IBOutlet weak var locationMapView: UIView!
    @IBOutlet weak var locationCentreImage: UIImageView!
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    var mapViewHelper : GoogleMapsHelper?
    private var isUserInteractingWithMap = false
    
    var delegate: MultiLocationVCDelegate?
    var destinationArray = [String]()
    var activeTextfield = UITextField()
    var activeTextFieldTag = 0
    var callback : (([Bind<LocationDetail>],Bind<LocationDetail>) ->())?
    var destinationChanged: (([Stops],[Positions]) -> ())?
    var selectedTextfield: Int?
    
    var destin = [String]()
    var src = ""
    var changeDest = false
    
    var currentPositions : [Positions]?
    
    var keyboardAprHeightInc: CGFloat = 0.0
    
    

    var sourceLocationDetail : Bind<LocationDetail>? = Bind<LocationDetail>(nil)
    var destinationLocationDetail : [Bind<LocationDetail>]? = [Bind<LocationDetail>(nil)]
    var currentLocation = Bind<LocationCoordinate>(defaultMapLocation)
    var stops: [Stops]?
    
    var currLocation:CLLocation!
    var shortDistance:Double = 0
    var updateRoute = true
    
    var numberOfRows = 1
    
    private var googlePlacesHelper : GooglePlacesHelper?
    
    private var datasource = [GMSAutocompletePrediction]() {  // Predictions List
        didSet {
             DispatchQueue.main.async {
                print("Reloaded")
                self.tableViewBottom.reloadData()
                
             }
        }
    }
    
    private func getPredications(from string : String?){
        
        self.googlePlacesHelper?.getAutoComplete(with: string, with: { (predictions) in
            self.datasource = predictions
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewControllerName = String.init(describing: self.classForCoder)
        print("VCName***: \(viewControllerName)")
        self.viewBottom.alpha = 0
        addMapView()
//        if #available(iOS 13.0, *) {
//            self.navigationController?.navigationBar.barTintColor = .systemBackground
//        }
        self.navigationController?.isNavigationBarHidden = true
        
        if changeDest
        {
            self.sourceTextfield.isHidden = true
            //self.tableViewHeight.constant = 180
            numberOfRows = self.stops?.count ?? 0
            self.myspecial()
        }
//        else
//        {
            if self.numberOfRows == 1
            {
                self.tableViewHeight.constant = 60
            }
            else if self.numberOfRows == 2
            {
                self.tableViewHeight.constant = 120
            }
            else if self.numberOfRows == 3
            {
                self.tableViewHeight.constant = 180
            }
        //}
        
        self.googlePlacesHelper = GooglePlacesHelper()
        self.tableViewBottom.register(UINib(nibName: XIB.Names.LocationTableViewCell, bundle: nil), forCellReuseIdentifier:XIB.Names.LocationTableViewCell)
        self.tableViewBottom.register(UINib(nibName: XIB.Names.LocationHeaderTableViewCell, bundle: nil), forCellReuseIdentifier:XIB.Names.LocationHeaderTableViewCell)
        
        if sourceLocationDetail != nil
        {
            sourceTextfield.text = sourceLocationDetail?.value?.address
        }
        
        if selectedTextfield == 1
        {
            sourceTextfield.becomeFirstResponder()
        }
        

        sourceTextfield.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        //sourceTextfield.clearButtonMode = .whileEditing
        //navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonTapped))
        doneBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(doneButtonTapped)))
        navigationItem.rightBarButtonItem?.tintColor = .red
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18)], for: .normal)
        
//        let lat =   currentLocation.value?.latitude
//        UserDefaults.standard.set(lat, forKey: "lat")
//        let long =   currentLocation.value?.longitude
//        UserDefaults.standard.set(long, forKey: "long")


        
        self.currentLocation.bind(listener: { (locationCoordinate) in
            // TODO:- Handle Current Location
            
            if locationCoordinate != nil {
                self.mapViewHelper?.moveTo(location: LocationCoordinate(latitude: locationCoordinate!.latitude, longitude: locationCoordinate!.longitude), with: self.locationMapView.center)
            }
        })
        
        registerkeyboardNotification()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.mapViewHelper?.mapView?.frame = locationMapView.bounds
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.isNavigationBarHidden = false
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //self.navigationController?.isNavigationBarHidden = true
//        if #available(iOS 13.0, *) {
//            self.navigationController?.navigationBar.barTintColor = .systemBackground
//        } else {
//            // Fallback on earlier versions
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.backPressed(gmHelperRef: mapViewHelper!)
    }

    
    private func addMapView(){
        
        //self.mapViewHelper = GoogleMapsHelper()
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark{
                self.mapViewHelper?.getMapView(withDelegate: self, in: self.locationMapView, interfaceStyle: .dark, isMultilocVC: true)
            }else{
                self.mapViewHelper?.getMapView(withDelegate: self, in: self.locationMapView, interfaceStyle: .light, isMultilocVC: true)
            }
        } else {
            self.mapViewHelper?.getMapView(withDelegate: self, in: self.locationMapView, interfaceStyle: .light, isMultilocVC: true)
        }
        self.getCurrentLocationDetails()
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
    
    private func getCurrentLocationDetails() {
        self.mapViewHelper?.getCurrentLocation(onReceivingLocation: { (location) in
            
            
            
            print("Current LOC ")
          //  self.showToast(string: "\(location.coordinate.latitude)")
            
            
//            self.perKmUpdateRouteCheck(newLocation: location)
            
            
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

    
    func resetCheck(){
        updateRoute = true
        shortDistance = 0
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSourceClear(_ sender: UITextField) {
        sourceTextfield.text = ""
    }
    
}

extension MultiLocationSelectionViewController: UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView {
        case mTableView:
            return 1
        case tableViewBottom:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rowCount: Int
        
        switch tableView {
        case mTableView:
            if !changeDest
            {
                rowCount = destinationLocationDetail?.count ?? 0
                print("destin row count",rowCount)
            }
            else
            {
                rowCount = self.stops?.count ?? 0
                print("stops row count",rowCount)
            }
        case tableViewBottom:
            rowCount = (section == 0) ? (datasource.count>0 ? 0 : favouriteLocations.count) : datasource.count
        default:
            rowCount = 0
        }
        
        return rowCount
        
        
//        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView {
        case tableViewBottom:
            return indexPath.section == 0 ? (datasource.count>0 ? 0 : 60) : 70
        default:
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableView
        {
        case mTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MultiLocationTableViewCell") as! MultiLocationTableViewCell
            
            if !changeDest
            {
                if let source = self.destinationLocationDetail?[indexPath.row]{
                    cell.locationTextField.text = source.value?.address
                    cell.addButton.tag = indexPath.row
                    cell.crossButton.tag = indexPath.row
                    cell.locationTextField.tag = indexPath.row
                    cell.delegate = self
                    cell.stopTitleLabel.text = "Stop \(indexPath.row + 1)"
                    cell.locationTextField.removeTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
                    cell.locationTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
                    //cell.locationTextField.clearButtonMode = .whileEditing
                    
                }
                
                if let source = self.destinationLocationDetail{
                    
                    if source.count - 1 == indexPath.row {
                        //this mean I m last row
                        if indexPath.row != 2{
                            cell.addButton.isHidden = false
                            cell.crossButton.isHidden = true
                        }else{
                            cell.addButton.isHidden = true
                            cell.crossButton.isHidden = false
                        }
                    }else{
                        //show the cross button
                        cell.addButton.isHidden = true
                        cell.crossButton.isHidden = false
                    }
                }
                
                if indexPath.row == 0
                {
                    if self.selectedTextfield == 2
                    {
                        cell.locationTextField.becomeFirstResponder()
                    }
                }
                else if indexPath.row == 1
                {
                    if self.selectedTextfield == 3
                    {
                        cell.locationTextField.becomeFirstResponder()
                    }
                }
                else if indexPath.row == 2
                {
                    if self.selectedTextfield == 4
                    {
                        cell.locationTextField.becomeFirstResponder()
                    }
                }
            }
            else
            {
                if let stops = self.stops{
                    
                    if stops.count - 1 == indexPath.row {
                        //this mean I m last row
                        if indexPath.row != 2{
                            cell.addButton.isHidden = false
                            cell.crossButton.isHidden = true
                        }else{
                            cell.addButton.isHidden = true
                            cell.crossButton.isHidden = false
                        }
                    }else{
                        //show the cross button
                        cell.addButton.isHidden = true
                        cell.crossButton.isHidden = false
                    }
                }
                
                if let stop = self.stops?[indexPath.row]{
                    cell.locationTextField.text = stop.d_address
                    cell.addButton.tag = indexPath.row
                    cell.crossButton.tag = indexPath.row
                    cell.locationTextField.tag = indexPath.row
                    cell.delegate = self
                    cell.locationTextField.removeTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
                    cell.locationTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
                    cell.locationTextField.clearButtonMode = .whileEditing
                    if stop.status == "DROPPED"
                    {
                        cell.locationTextField.isEnabled = false
                        cell.locationTextField.textColor = .lightGray
                        cell.addButton.isHidden = true
                        cell.crossButton.isHidden = true
                    }
                    
                }
                

            }

            
            let rows = mTableView.numberOfRows(inSection: 0)
            
            if rows == 1
            {
                if indexPath.row == 0
                {
                    cell.locationTextField.placeholder = "Add Stop 1"
                }
            }
            
            if rows == 2
            {
                if indexPath.row == 0
                {
                    cell.locationTextField.placeholder = "Add Stop 1"
                }
                
                if indexPath.row == 1
                {
                    cell.locationTextField.placeholder = "Add Stop 2"
                }
            }
            
            if rows == 3
            {
                if indexPath.row == 0
                {
                    cell.locationTextField.placeholder = "Add Stop 1"
                }
                
                if indexPath.row == 1
                {
                    cell.locationTextField.placeholder = "Add Stop 2"
                }
                if indexPath.row == 2
                {
                    cell.locationTextField.placeholder = "Add Stop 3"
                }
            }
            
            return cell
            
        case tableViewBottom:
            
            return self.getCell(for: indexPath)
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.5) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        self.select(at: indexPath)
        self.viewBottom.alpha = 0
    }
    
    private func getCell(for indexPath : IndexPath)->UITableViewCell{
        
        if indexPath.section == 0 { // Favourite Locations
            
            if let tableCell = self.tableViewBottom.dequeueReusableCell(withIdentifier: XIB.Names.LocationHeaderTableViewCell, for: indexPath) as? LocationHeaderTableViewCell, favouriteLocations.count>indexPath.row {
            
                tableCell.textLabel?.text = favouriteLocations[indexPath.row].address.localize()
                tableCell.detailTextLabel?.text = favouriteLocations[indexPath.row].location?.address ?? Constants.string.addLocation.localize()
                Common.setFont(to: tableCell.textLabel!)
                Common.setFont(to: tableCell.detailTextLabel!, size : 12)
                return tableCell
            }
            
        } else  { // Predications
            
            if let tableCell = self.tableViewBottom.dequeueReusableCell(withIdentifier: XIB.Names.LocationTableViewCell, for: indexPath) as? LocationTableViewCell, datasource.count>indexPath.row{
                tableCell.imageLocationPin.image = #imageLiteral(resourceName: "ic_location_pin")
                let placesClient = GMSPlacesClient.shared()
                placesClient.lookUpPlaceID(datasource[indexPath.row].placeID, callback: { (place, error) -> Void in
                    if let error = error {
                        print("lookup place id query error: \(error.localizedDescription)")
                        return
                    }
                    if let place = place {
                        let formatAddress = place.formattedAddress
                        let addressName = place.name
                        let formatAddressString = formatAddress!.replacingOccurrences(of: "\(addressName), ", with: "", options: .literal, range: nil)
                        tableCell.lblLocationTitle.text = addressName
                        tableCell.lblLocationSubTitle.text = formatAddressString
                    }
                })
                Common.setFont(to: tableCell.lblLocationTitle!)
                Common.setFont(to: tableCell.lblLocationSubTitle!)
                return tableCell
            }
            
        }
        
        return UITableViewCell()
        
    }
    
    private func select(at indexPath : IndexPath){
        
        
//        if self.changeDest{w
//            if let stops = self.stops{
//                print(stops, indexPath.row)
//                let stop = stops[indexPath.row]
//
//                if stop.status != "PENDING"{
//                    return
//                }
//
//            }else{
//                return
//            }
//        }
        
        
        
        if indexPath.section == 0 {
            
            if favouriteLocations[indexPath.row].location != nil {
                
                self.autoFill(with: favouriteLocations[indexPath.row].location)

            } else {
                
                
                
                
                self.googlePlacesHelper?.getGoogleAutoComplete(completion: { (place) in
                    
                    favouriteLocations[indexPath.row].location = (place.formattedAddress ?? .Empty, place.coordinate)
                    
                    let service = Service() // Save Favourite location in Server
                    service.address = place.formattedAddress
                    service.latitude = place.coordinate.latitude
                    service.longitude = place.coordinate.longitude
                    let type : CoreDataEntity = indexPath.row == 0 ? .home : .work
                    service.type = type.rawValue.lowercased()
                    CoreDataHelper().insert(data: (String.removeNil(place.formattedAddress), LocationCoordinate(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)), entityName: type) //
                    DispatchQueue.main.async {
                        self.autoFill(with: favouriteLocations[indexPath.row].location)
                    }
                    
                })
            }
        } else {
            
            self.autoFill(with: (datasource[indexPath.row].attributedFullText.string, LocationCoordinate(latitude: 0, longitude: 0)))
            
            
            if datasource.count > indexPath.row{
                let placeID = datasource[indexPath.row].placeID
                GMSPlacesClient.shared().lookUpPlaceID(placeID) { (place, error) in
                    
                    if error != nil {
                        
                        self.view.make(toast: error!.localizedDescription)
                        
                    } else if let addressString = place?.formattedAddress, let coordinate = place?.coordinate{
                        

                       // print("\nselected ---- ",coordinate)
                        self.autoFill(with: (addressString,coordinate))
                    }
                }
            }
        }
    }
    
    private func autoFill(with location : LocationDetail?)
    { //, with array : [T]
        let index = self.activeTextFieldTag
        
        if self.activeTextFieldTag == -1
        {
            self.activeTextfield.text = location?.address
            self.sourceLocationDetail?.value = location
        }
        else if self.activeTextFieldTag >= 0 && self.activeTextFieldTag < 3
        {
            self.activeTextfield.text = location?.address
            if !changeDest
            {
               self.destinationLocationDetail?[index].value = location
            }
            else
            {
                self.stops?[index].d_address = location?.address
                self.stops?[index].d_latitude = location?.coordinate.latitude
                self.stops?[index].d_longitude = location?.coordinate.longitude
                
                self.currentPositions?[index].d_address = location?.address
                self.currentPositions?[index].d_latitude = location?.coordinate.latitude
                self.currentPositions?[index].d_longitude = location?.coordinate.longitude
                
                if self.currentPositions?[index].action == nil{
                    self.currentPositions?[index].action = "update"
                }

            }
            
        }
    }
}
extension MultiLocationSelectionViewController: locationButtonsDelegate
{
    func addRow(row: Int)
    {
        let index = IndexPath(row: row, section: 0)
        if self.numberOfRows < 3
        {
            if !changeDest
            {
                self.destinationLocationDetail?.append(Bind<LocationDetail>(nil))
            }
            else
            {
                self.stops?.append(Stops())
                let position = Positions()
                position.action = "create"
                self.currentPositions?.append(position)
            }

            self.numberOfRows += 1
            mTableView.reloadData()
            animateRowIncDec(constant: self.tableViewHeight.constant + CGFloat(60))
        }
    }
    
    func removeRow(row: Int)
    {
//        let index = IndexPath(row: row, section: 0)
        self.numberOfRows -= 1
        if !changeDest
        {
            self.destinationLocationDetail?.remove(at: row)
        }
        else
        {
            self.stops?.remove(at: row)
            self.currentPositions?[row].action = "delete"
        }
        mTableView.reloadData()
        animateRowIncDec(constant: self.tableViewHeight.constant - CGFloat(60))
    }
    
    func animateRowIncDec(constant: CGFloat){
        self.tableViewHeight.constant = constant
        self.topView.layoutIfNeeded()
    }
    
}

extension MultiLocationSelectionViewController {

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {

        if self.isUserInteractingWithMap {

            func getUpdate(on location : CLLocationCoordinate2D, completion :@escaping ((LocationDetail)->Void)) {
                self.mapViewHelper?.getPlaceAddress(from: location, on: { (locationDetail) in
                    completion(locationDetail)
                })
            }

            if self.activeTextfield.tag == -1 {
                
                if let location = mapViewHelper?.mapView?.projection.coordinate(for: locationMapView.center) {
                    self.sourceLocationDetail?.value?.coordinate = location
                    getUpdate(on: location) { (locationDetail) in
                        self.sourceLocationDetail?.value = locationDetail
                        DispatchQueue.main.async {
                            self.sourceTextfield.text = locationDetail.address
                        }

                    }
                }
            }
            else if self.activeTextFieldTag >= 0 && self.activeTextFieldTag < 3 {

                let index = self.activeTextFieldTag

                if let location = mapViewHelper?.mapView?.projection.coordinate(for: locationMapView.center) {
                    if !changeDest
                    {
                        self.destinationLocationDetail?[index].value?.coordinate = location
                        getUpdate(on: location) { (locationDetail) in
                            self.destinationLocationDetail?[index].value = locationDetail
                            
                            DispatchQueue.main.async
                                {
                                    self.mTableView.reloadData()
                            }
                        }
                    }
                    else
                    {
                        
                      
                        
                        self.stops?[index].d_latitude = location.latitude
                        self.stops?[index].d_longitude = location.longitude
                        getUpdate(on: location) { (locationDetail) in
                            
                            self.stops?[index].d_address = locationDetail.address
                            self.stops?[index].d_latitude = locationDetail.coordinate.latitude
                            self.stops?[index].d_longitude = locationDetail.coordinate.longitude
                            
                            self.currentPositions?[index].d_address = locationDetail.address
                            self.currentPositions?[index].d_latitude = locationDetail.coordinate.latitude
                            self.currentPositions?[index].d_longitude = locationDetail.coordinate.longitude
                            
                            if self.currentPositions?[index].action == nil{
                                self.currentPositions?[index].action = "update"
                            }
                            
                            DispatchQueue.main.async
                                {
                                    self.mTableView.reloadData()
                            }
                        }
                    }
                }
        }
    }
}

    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {

        print("Gesture ",gesture)
        self.isUserInteractingWithMap = gesture
        
        self.activeTextfield.resignFirstResponder()

//        if self.isUserInteractingWithMap {
//            self.isMapInteracted(true)
//        }

    }

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        self.locationCentreImage.tintColor = .secondary
        self.locationCentreImage.image = UIImage(named: "MarkerFullIcon")// #imageLiteral(resourceName: "sourcePin").withRenderingMode(.alwaysTemplate)
        self.locationCentreImage.isHidden = false
        
    }
    
}
extension MultiLocationSelectionViewController: UITextFieldDelegate
{
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        self.activeTextfield = textField
        self.activeTextFieldTag = textField.tag
        print(textField.tag)
        self.datasource = []
        self.getPredications(from: textField.text)
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.datasource = []
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let searchText = textField.text, searchText.removingWhitespaces().count > 0 else {
            self.datasource = []
            return
        }
        
        self.getPredications(from: searchText)
        self.viewBottom.alpha = 1
    }
    
   
    
}

extension MultiLocationSelectionViewController
{
    @objc func doneButtonTapped()
    {
        if changeDest
        {
            
            if let stops = self.stops , let newPositions = self.currentPositions{
                destinationChanged?(stops , newPositions)
            }
        }
        else if !changeDest
        {
            if let destinationLocationDetail
            {
                if let _ = destinationLocationDetail[0].value?.coordinate
                {
                    callback?(self.destinationLocationDetail!,self.sourceLocationDetail!)
                }
            }
            
        }
        self.changeDest = false
        deRegisterkeyboardNotification()
        
        self.navigationController?.popViewController(animated: true)
    }
}

extension MultiLocationSelectionViewController
{
    func registerkeyboardNotification()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func deRegisterkeyboardNotification()
    {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification)
    {
        
        mTableView.isScrollEnabled = true
        
        guard
            let info = notification.userInfo,
            let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey]as? NSValue)?.cgRectValue.size
        else {return}
        
        let screenHeight = self.view.frame.size.height - 55
        let keyBoardHeight = keyboardSize.height + viewBottom.frame.size.height
        let topLocationViewHeight = topView.frame.size.height
        let leftHeight = abs(screenHeight-keyBoardHeight)
        let finalValue = leftHeight-topLocationViewHeight
        if Int(finalValue).signum() == -1{
            mTableView.contentSize = CGSize(width: mTableView.contentSize.width, height: mTableView.contentSize.height+abs(finalValue))
            keyboardAprHeightInc = abs(finalValue)
        }
        
        let window = UIApplication.shared.keyWindow
        if #available(iOS 11.0, *) {
            let bottomPadding = window?.safeAreaInsets.bottom ?? 0.0
            animateKeyboardAppearance(constant: keyboardSize.height - bottomPadding)
        } else {
            // Fallback on earlier versions
           animateKeyboardAppearance(constant: keyboardSize.height)
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification)
    {
        
        if keyboardAprHeightInc > 0{
            mTableView.contentSize = CGSize(width: mTableView.contentSize.width, height: mTableView.contentSize.height-keyboardAprHeightInc)
        }
        mTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        mTableView.isScrollEnabled = false
        animateKeyboardAppearance(constant: 0)
    }
    
    func animateKeyboardAppearance(constant: CGFloat){
        UIView.animate(withDuration: 0.1) {
            self.bottomViewBottomConstraint?.constant = constant
            self.view.layoutIfNeeded()
        }
    }
}


extension MultiLocationSelectionViewController{
    
    
    func myspecial(){
        
        var positions = [Positions]()
        
        if let stops = self.stops{
            
            for stop in stops{
                
                //if stop.status == "PENDING"{
                    var position = Positions()
                    position.d_latitude = stop.d_latitude
                    position.d_longitude = stop.d_longitude
                    position.d_address = stop.d_address
                    position.stop_id = stop.id
                    
                    positions.append(position)
              //  }
            }
            
            self.currentPositions = positions
            
            
        }
        
        
    }
    
}
