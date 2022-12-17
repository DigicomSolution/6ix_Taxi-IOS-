//
//  HomePageHelper.swift
//  User
//
//  Created by CSS on 01/06/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation
import UIKit

class HomePageHelper {
    
    private var timer : Timer?
    static var shared = HomePageHelper()
    // MARK:- Start Listening for Provider Status Changes
    func startListening(on completion : @escaping ((CustomError?,Request?)->Void)) {
        
        DispatchQueue.main.async {
            self.stopListening()
            self.timer = Timer.scheduledTimer(withTimeInterval: requestCheckInterval, repeats: true, block: { (_) in
                self.getData(on: { (error, request) in
                    completion(error,request)
                })
            })
            self.timer?.fire()
        }
        
    }
    
    //MARK:- Stop Listening
    func stopListening() {
        // DispatchQueue.main.async {
        self.timer?.invalidate()
        self.timer = nil
        // }
    }
    
    
    //MARK:- Get Request Data From Service
    
    private func getData(on completion : @escaping ((CustomError?,Request?)->Void)) {
        
        
        
        Webservice().retrieve(api: .checkRequest, url: nil, data: nil, imageData: nil, paramters: nil, type: .GET) { (error, data) in
            
            guard error == nil else {
                completion(error, nil)
               // DispatchQueue.main.async { self.stopListening() }
                return
            }
            
            guard let data = data,
                let request = data.getDecodedObject(from: RequestModal.self)
                else {
                    completion(error, nil)
                   // DispatchQueue.main.async { self.stopListening() }
                    return
            }
        
            // Checking whether the Cash or card payment is disabled
            if let isCardEnabledInt = request.card, let isCashEnabledInt = request.cash {
                let isCashEnabled = (isCashEnabledInt == 1)
                let isCardEnabled = (isCardEnabledInt == 1)
                if User.main.isCashAllowed != isCashEnabled || User.main.isCardAllowed != isCardEnabled {
                    User.main.isCashAllowed = isCashEnabled
                    User.main.isCardAllowed = isCardEnabled
                    storeInUserDefaults()
                }
            }
            
            guard let requestFirst = request.data?.first else {
                completion(nil, nil)
                riderStatus = .none
               // DispatchQueue.main.async { self.stopListening() }
                return
            }
            completion(nil, requestFirst)
        }
    }
    
//    deinit {
//
//        DispatchQueue.main.async {
//            self.timer?.invalidate()
//            self.reachability?.stopNotifier()
//        }
//
//    }
    
    
}


