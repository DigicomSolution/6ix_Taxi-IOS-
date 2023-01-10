//
//  ApiCalls.swift
//  TranxitSwift
//
//  Created by Umer Tahir on 02/01/2023.
//  Copyright © 2023 Appoets. All rights reserved.
//

import Foundation
import Alamofire

let acceptOfferEndPoint = "/api/user/v2/request/accept/"
let rejectOfferEndPoint = "/api/user/v2/request/reject/"

struct ApiCalls {
    
    
    func acceptOffer(offerID : Int, requestId: Int,  completion : @escaping ((String?,String?)->Void)) {
        
        let url = baseUrl + acceptOfferEndPoint + "\(requestId)"
  
        let header : HTTPHeaders = [

            "Authorization" : "Bearer \(User.main.accessToken ?? "")"
        ]
        let params  = ["offer_id":offerID]
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { response in
            
            if let data = response.result.value as? [String:Any] {
                if let error = data["error"] as? String {
                    print(error)
                    completion(nil,error)

                }
                if let msg = data["message"] as? String {
                    print(msg)
                    completion(msg,nil)

                }

            }else{
                completion(nil,response.error?.localizedDescription ?? "")
            }
            
        }
        
    }
    
    
    func rejectOffer(offerID : Int, requestId: Int,  completion : @escaping ((String?,String?)->Void)) {
        
        let url = baseUrl + rejectOfferEndPoint + "\(requestId)"
  
        let header : HTTPHeaders = [

            "Authorization" : "Bearer \(User.main.accessToken ?? "")"
        ]
        let params  = ["offer_id":offerID]
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { response in
            
            if let data = response.result.value as? [String:Any] {
                if let error = data["error"] as? String {
                    print(error)
                    completion(nil,error)

                }
                if let msg = data["message"] as? String {
                    print(msg)
                    completion(msg,nil)

                }

            }else{
                completion(nil,response.error?.localizedDescription ?? "")
            }
            
        }
        
    }
    

    
}
