//
//  HomeScreenEstimateExtension.swift
//  TranxitUser
//
//  Created by Hexacrew on 11/06/2020.
//  Copyright © 2020 Appoets. All rights reserved.
//

import Foundation
import UIKit
import KWDrawerController
import GoogleMaps
import GooglePlaces
import DateTimePicker
import MapKit
import FirebaseDatabase
import PopupDialog




extension HomeViewController{
    
    func popUpwaitTime(){
        
        
        waitTimePop = WaitTimeViewController(nibName: "WaitTimeViewController", bundle: nil)
        popUpDialog = PopupDialog(viewController: waitTimePop, buttonAlignment: .horizontal, transitionStyle: .fadeIn, tapGestureDismissal: true)
        
        waitTimePop.waitTimeDelegate = self
        
//        estimateFarePop.estimatedFareAskLabel.text = Constants.string.confirmEstimatedFare.localize()
//        estimateFarePop.estimatedFareTagLabel.text = Constants.string.EstimatedFare.localize()
//        estimateFarePop.estimatedFareLabel.text = estimatedFareString
//
//        estimateFarePop.cancelButton.addTarget(self, action: #selector(dismissPopUpEstimate), for: .touchUpInside)
//        estimateFarePop.comfirmButton.addTarget(self, action: #selector(donePopUpEstimate), for: .touchUpInside)
        //let containerAppearance = PopupDialogContainerView.appearance()
        
        //containerAppearance.backgroundColor = UIColor(red:0.23, green:0.23, blue:0.27, alpha:1.00)
        // containerAppearance.cornerRadius    = 25
        present(popUpDialog, animated: true, completion: nil)
        
    }
    
    
    func popUpEstimatedFare(estimatedFareString : String){
        
        estimateFarePop = EstimatedFareViewController(nibName: "EstimatedFareViewController", bundle: nil)
        popUpDialog = PopupDialog(viewController: estimateFarePop, buttonAlignment: .horizontal, transitionStyle: .fadeIn, tapGestureDismissal: true)
        
        estimateFarePop.estimatedFareAskLabel.text = Constants.string.confirmEstimatedFare.localize()
        estimateFarePop.estimatedFareTagLabel.text = Constants.string.EstimatedFare.localize()
        estimateFarePop.estimatedFareLabel.text = estimatedFareString
        
        estimateFarePop.cancelButton.addTarget(self, action: #selector(dismissPopUpEstimate), for: .touchUpInside)
        estimateFarePop.comfirmButton.addTarget(self, action: #selector(donePopUpEstimate), for: .touchUpInside)
        //let containerAppearance = PopupDialogContainerView.appearance()
        
        //containerAppearance.backgroundColor = UIColor(red:0.23, green:0.23, blue:0.27, alpha:1.00)
        // containerAppearance.cornerRadius    = 25
        present(popUpDialog, animated: true, completion: nil)
        
    }
    
    @objc func dismissPopUpEstimate(){
        self.popUpDialog.dismiss()
    }
             
    @objc func donePopUpEstimate(){
            //Here we will call the request api
        
        if let positions = self.updatePositions{
            self.updateStopsRequest(with: positions)
        }else{
            UserDefaults.standard.setValue(true, forKey: "onRide")
            //let selectedPaymentDetail : CardEntity?
            let paymentType : PaymentType = (User.main.isCashAllowed ? .CASH : User.main.isCardAllowed ? .CARD : .NONE)
            self.service?.round_trip = 1
            
            
            print(self.service?.waiting_minutes,"Waiting minutes are")
            
            
            //self.createRequest(for: self.service!, isScheduled: false, scheduleDate: nil, cardEntity: nil, paymentType: paymentType)
            self.sendRequest()
        }
       
        self.popUpDialog.dismiss()
        
    }
    
    

    func updateStopsRequest(with detail : [Positions]) {
        
        guard [RideStatus.accepted, .arrived, .pickedup, .started].contains(riderStatus) else { return } // Update Location only if status falls under certain category
        
        let request = Request()
        request.request_id = self.currentRequestId
        

    
            
            var toGoArray = [Any]()
            
            for val in detail{
                
                toGoArray.append(val.JSONRepresentation)
            }
            
            
            if let jsonString = convertIntoJSONString2(arrayObject: toGoArray){
                print("Is updating send the req - \(jsonString)")
                request.positions = jsonString
            }
        
            self.presenter?.post(api: .updateRequest, data: request.toData())
        
    }
    
    
}


extension HomeViewController: WaitTimeDelegate{
    func crossAction() {
        self.popUpDialog.dismiss {
        }
    }
    
    func confirmTimeAction(minutes: Int) {
        
        if let id = self.selectedService?.id {
            self.popUpDialog.dismiss {
                self.isRoundTrip = true
                self.service?.round_trip = 1
                self.service?.waiting_minutes = minutes
                self.getEstimateFareFor(serviceId: id,isRoundTrip:1, waitingMin: minutes)
            }
        }
        
        
        
        
    }
    
    
    
    
}
