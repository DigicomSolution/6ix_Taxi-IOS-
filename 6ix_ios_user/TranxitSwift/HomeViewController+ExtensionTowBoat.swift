//
//  HomeViewController+ExtensionTowBoat.swift
//  TranxitUser
//
//  Created by Hexacrew on 05/05/2020.
//  Copyright © 2020 Appoets. All rights reserved.
//

import Foundation
import UIKit
import PopupDialog



extension HomeViewController {
    
    

        // MARK:- Show Ride Now View
        
//        func showInstructionsView(with source : [Service]) {
//            guard let sourceLocation = self.sourceLocationDetail?.value, let destinationLocation = self.destinationLocationDetail else { return }
//
//            if self.instructionsView == nil {
//                self.instructionsView = Bundle.main.loadNibNamed(XIB.Names.TowInstructionsView, owner: self, options: [:])?.first as? TowInstructionsView
//
//            }
//
//
//
//
//            if self.rideNowView == nil {
//
//                self.rideNowView = Bundle.main.loadNibNamed(XIB.Names.RideNowView, owner: self, options: [:])?.first as? RideNowView
//                self.rideNowView?.frame = CGRect(origin: CGPoint(x: 0, y: self.view.frame.height-self.rideNowView!.frame.height), size: CGSize(width: self.view.frame.width, height: self.rideNowView!.frame.height))
//                self.rideNowView?.clipsToBounds = false
//                self.rideNowView?.show(with: .bottom, completion: nil)
//                self.view.addSubview(self.rideNowView!)
//                self.isOnBooking = true
//                self.rideNowView?.onClickProceed = { [weak self] service in
//                    self?.showEstimationView(with: service)
//                }
//                self.rideNowView?.onClickService = { [weak self] service in
//                    guard let self = self else {return}
//                    self.sourceMarker.snippet = service?.pricing?.time
//                    self.mapViewHelper?.mapView?.selectedMarker = (service?.pricing?.time) == nil ? nil : self.sourceMarker
//                }
//            }
//            self.rideNowView?.setAddress(source: sourceLocation.coordinate, destination: destinationLocation.coordinate)
//            self.rideNowView?.set(source: source)
//        }
    
    
    
    func popUpCableView(service : Service){
        
        self.service = service
        
        boosterCablePop = BoosterCableViewController(nibName: "BoosterCableViewController", bundle: nil)
        popUpDialog = PopupDialog(viewController: boosterCablePop, buttonAlignment: .horizontal, transitionStyle: .zoomIn, tapGestureDismissal: true)
       
        
//        estimateFarePop.estimatedFareAskLabel.text = Constants.string.confirmEstimatedFare.localize()
//        estimateFarePop.estimatedFareTagLabel.text = Constants.string.EstimatedFare.localize()
//        estimateFarePop.estimatedFareLabel.text = estimatedFareString
//
        boosterCablePop.cancelBtn.addTarget(self, action: #selector(dismissPopUpTime), for: .touchUpInside)
        boosterCablePop.doneBtn.addTarget(self, action: #selector(donePopUpTime), for: .touchUpInside)
        let containerAppearance = PopupDialogContainerView.appearance()
        
        containerAppearance.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:1.00)
        // containerAppearance.cornerRadius    = 25
        present(popUpDialog, animated: true, completion: nil)
        
    }
    
    
     func updateService(service:Service){
        
        if let rideNow = self.rideNowView{
            if let id = service.id{
                rideNow.getEstimateFareFor(serviceId: id)
            }
        }
    }
    
    @objc func dismissPopUpTime(){
        self.popUpDialog.dismiss()
    }
             
    @objc func donePopUpTime(){
            //Here we will call the request api
        
        self.is_booster_cable = boosterCablePop.isBooster
        
        if let service = self.service{
            self.service?.is_booster_cable = self.is_booster_cable
            service.is_booster_cable = self.is_booster_cable
            self.updateService(service: service)
        }
        self.popUpDialog.dismiss()
        
    }
    
    

        func popUpInstructionsView(service : Service){
            
            self.service = service
            
            instructionsTowPop = TowTruckInstructionViewController(nibName: "TowTruckInstructionViewController", bundle: nil)
            popUpDialog = PopupDialog(viewController: instructionsTowPop, buttonAlignment: .horizontal, transitionStyle: .zoomIn, tapGestureDismissal: true)
           
   
            instructionsTowPop.cancelBtn.addTarget(self, action: #selector(dismissPopUpTime), for: .touchUpInside)
            instructionsTowPop.doneBtn.addTarget(self, action: #selector(donePopUpInstructions), for: .touchUpInside)
            let containerAppearance = PopupDialogContainerView.appearance()
            
            containerAppearance.backgroundColor = UIColor(red:1, green:1, blue:1, alpha:1.00)
            // containerAppearance.cornerRadius    = 25
            present(popUpDialog, animated: true, completion: nil)
            
        }
    
    
    
    @objc func donePopUpInstructions(){
            //Here we will call the request api
        
        self.instructions = instructionsTowPop.instructionText.text ?? ""
        
        self.is_booster_cable = instructionsTowPop.isBooster
        
        if let service = self.service{
            self.service?.instructions = self.instructions
            service.instructions = self.instructions
            self.service?.is_booster_cable = self.is_booster_cable
            service.is_booster_cable = self.is_booster_cable
            self.updateService(service: service)
        }
        self.popUpDialog.dismiss()
        
    }

    
}


// MARK: - Navigation -

extension HomeViewController {
    func persentWaitingTimeSelectionVC(){
        self.performSegue(withIdentifier: "ShowWaitingTimeSelectionVC", sender: self)
    }
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let wtsVC = segue.destination as? WaitingTimeSelectionViewController{
                wtsVC.service = self.service
                wtsVC.delegate = self
            }
        }
        

}

extension HomeViewController:WaitingTimeSelectionViewControllerDelegate {
    func waitingTimeSelected(_ service: Service) {
        showEstimationView(with: service)
    }
    
    
        

}
