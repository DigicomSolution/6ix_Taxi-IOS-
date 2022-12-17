//
//  WebService.swift
//  User
//
//  Created by imac on 12/19/17.
//  Copyright © 2017 Appoets. All rights reserved.
//

import Foundation
import Alamofire
import Crashlytics

class Webservice : PostWebServiceProtocol {
    
    var interactor: PostInteractorOutputProtocol?
    
    var completion : ((CustomError?, Data?)->())?
    
    let pathOfSSLCertificate = Bundle.main.path(forResource: "server", ofType: "der")
    
    
    var sessionManager: SessionManager?
    
    init() {
        createSessionManager()
    }
    
    private func createSessionManager(){
    
        let nsDataOfSSLCertificate = NSData(contentsOfFile: pathOfSSLCertificate!)!

        let serverTrustPolicy = ServerTrustPolicy.pinCertificates(certificates: [SecCertificateCreateWithData(nil, nsDataOfSSLCertificate)!], validateCertificateChain: false, validateHost: true)

        let serverTrustPolicies = ["https://6ixtaxi.com" : serverTrustPolicy]

        sessionManager = SessionManager(serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
    }
    
    //MARK:- SEND WEBSERVICE REQUEST TO BACKEND
    
    func retrieve(api: Base,url : String?, data: Data?, imageData: [String:Data]?, paramters: [String : Any]?, type: HttpType, completion : ((CustomError?, Data?)->())?) {
        
         print("To url ", api.rawValue)
        
        if data != nil {
            
             print("\nAt Webservice Request  ",String(data: data!, encoding: .utf8) ?? .Empty)
        }
        if paramters != nil {
            
            print("\nAt Webservice Request  ",paramters!)
        }
        
        if imageData != nil {
            
            print("\nImage Data Request  ",imageData!)
        }
        
        if api == .servicesList {
            
            print("\n servicesList Data Request  ",paramters!)
        }
        self.completion = completion
        
        setCrashLog(base: api) // Setting crash log
        
        let reach = Reachability.init(hostname: baseUrl)
       
        guard reach?.connection == .wifi || reach?.connection == .cellular else {  // Internet not available
            NotificationCenter.default.post(name: .reachabilityChanged, object: nil)
            self.interactor?.on(api: api, error: CustomError(description: ErrorMessage.list.notReachable, code : StatusCode.notreachable.rawValue))
            self.completion?(CustomError(description: ErrorMessage.list.notReachable, code : StatusCode.notreachable.rawValue), nil)
            return
        }
        
        
        // If ImageData is available send in multipart
        if imageData != nil {
            
            self.send(api: api, imageData: imageData, parameters: paramters)
            
        } else if url != nil { // send normal GET POST call
            
            self.send(api: api,url : url!, data: data, parameters: paramters, type: type)
            
        } else {
            
            self.send(api: api,url : nil, data: data, parameters: paramters, type: type)
        }
        
    }


    //MARK:- Send Response to Interactor
    
    fileprivate func send(_ response: DefaultDataResponse?) {

        let apiKey = response?.request?.value(forHTTPHeaderField: WebConstants.string.secretKey)

        let apiType = Base.valueFor(Key: apiKey)

        guard let response = response else {
            self.completion?(CustomError(description: ErrorMessage.list.serverError, code : StatusCode.notreachable.rawValue), nil)
            self.interactor?.on(api: apiType, error: CustomError(description: ErrorMessage.list.serverError, code : StatusCode.notreachable.rawValue))
            return
        }
        
        
        if response.response?.statusCode == StatusCode.unAuthorized.rawValue  { // Validation For UnAuthorized Login
            
            var message : String?
            
            if let error = response.data?.getDecodedObject(from: ErrorLogger.self) {  // Retriving Error message from Server
                
                message = error.error
            }
            
            let string = String(decoding: response.data!, as: UTF8.self)
            print(string)
            if apiType == .login{
                self.completion?(CustomError(description:message!, code: response.response?.statusCode ?? StatusCode.ServerError.rawValue), nil)
                self.interactor?.on(api: apiType, error: CustomError(description:message!, code: response.response?.statusCode ?? StatusCode.ServerError.rawValue))
                
            }else{
                self.completion?(CustomError(description: ErrorMessage.list.serverError, code: (response.response?.statusCode) ?? StatusCode.unAuthorized.rawValue), nil)
                
                forceLogout(with: message)
            }
            
            
            
        }else if response.response?.statusCode != StatusCode.success.rawValue {  //  Validation for Error Log
            
            if let error = response.data?.getDecodedObject(from: ErrorLogger.self), error.error != nil { // Retrieving error from Server
                
                self.completion?(CustomError(description: error.error!, code: (response.response?.statusCode) ?? StatusCode.ServerError.rawValue), nil)
                self.interactor?.on(api: apiType, error: CustomError(description: error.error!, code: (response.response?.statusCode) ?? StatusCode.ServerError.rawValue))
                
            } else if response.data != nil  { // Retrieving error from Server
                
                var errMessage : String = .Empty
                
                do {
                    
                    if let errValue = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [String : [Any]] {
                        
                        
                        for err in errValue.values where err.count>0 {
                            
                            errMessage.append("\n\(err.first ?? String.Empty)")
                            
                        }
                        
                    } else if let errValue = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? NSDictionary {
                        
                        
                        for err in errValue.allValues{
                            
                            errMessage.append("\n\(err)")
                            
                        }
                        
                    }
                    
                    
                }catch let err {
                    
                    print("Err  ",err.localizedDescription)
                    
                }
                
                if errMessage.isEmpty {
                    errMessage = ErrorMessage.list.serverError
                }
                
                self.completion?(CustomError(description:errMessage, code: response.response?.statusCode ?? StatusCode.ServerError.rawValue), nil)
                self.interactor?.on(api: apiType, error: CustomError(description:errMessage, code: response.response?.statusCode ?? StatusCode.ServerError.rawValue))
                
            } else {
                
                self.completion?(CustomError(description: response.error!.localizedDescription, code: response.response?.statusCode ?? StatusCode.ServerError.rawValue), nil)
                self.interactor?.on(api: apiType, error: CustomError(description: response.error!.localizedDescription, code: response.response?.statusCode ?? StatusCode.ServerError.rawValue))
            }
            
        
        }else if let data = response.data {  // Validation For Server Data
            
             self.completion?(nil, data)
            let string = String(decoding: data, as: UTF8.self)
            print(string)
            self.interactor?.on(api: apiType, response: data)
            
            
        }  else { // Validation for Exceptional Cases
            
            self.completion?(CustomError(description: ErrorMessage.list.serverError, code: StatusCode.ServerError.rawValue), nil)
            self.interactor?.on(api: apiType, error: CustomError(description: ErrorMessage.list.serverError, code: StatusCode.ServerError.rawValue))
            
            
        }
        
        
       
        
        
        

//
//        if  response.error != nil {
//
//            if response.data != nil, Int(response.data?.count ?? 0) > 0 {
//
//                let err = JSON(response.data!).dictionaryValue
//
//                var str = String.Empty
//
//                for errvalue in err where errvalue.value.arrayValue.count>0 {
//                    str.append("\n \(errvalue.value.arrayValue.first!.stringValue)")
//                }
//
//
//                if str.isEmpty, err.count>0 { // Handle Values error
//
//                    str = String.removeNil(err.first?.value.string)
//
//                }
//
//
//
//                self.interactor?.on(api: apiType, error: CustomError(description: str.isEmpty ? ErrorMessage.list.serverError : str))
//
//
//            } else {
//
//                self.interactor?.on(api: apiType, error: CustomError(description: ErrorMessage.list.serverError))
//
//            }
//
//
//
//        }else if let data = response.data {
//
//            self.interactor?.on(api: apiType, response: JSON(data))
//
//        } else {
//
//            self.interactor?.on(api: apiType, error: CustomError(description: ErrorMessage.list.serverError))
//        }
    }

    
    

    // MARK:- Send Api Normal Request

    func send(api: Base, url appendingUrl : String?, data: Data?, parameters : [String : Any]?, type : HttpType) {

        var url : URL?
        var urlRequest : URLRequest?
        var getParams : String = .Empty

        switch type {
            
        case .GET:
            
            if appendingUrl != nil {
                
                getParams = appendingUrl!
                
            }else {
                
                for (index,param) in (parameters ?? [:]).enumerated() {
                    
                    getParams.append((index == 0 ? "?" : "&")+"\(param.key)=\(param.value)")
                    
                }
                
                getParams = api.rawValue+getParams
            }
            
            
            
            
            
        case .POST:
          
            if appendingUrl == nil {
                getParams = api.rawValue.trimmingCharacters(in: .whitespaces)
                
            } else {
                getParams = appendingUrl!
                
            }
            
        case .DELETE, .PATCH, .PUT :
            
            getParams = appendingUrl ?? .Empty
        
            
        }
        
        
        if api == .appleLogin || api == .isAppleMobileVerify{
            url = URL(string: baseUrlStaging+getParams ) // Setting Base url as FCM incase of FCM Push
        }else{
            url = URL(string: baseUrl+getParams ) // Setting Base url as FCM incase of FCM Push
        }
        
        if url != nil {
            urlRequest = URLRequest(url: url!)
        }
        
        urlRequest?.httpBody = data
        urlRequest?.httpMethod = type.rawValue
        
        
        guard urlRequest != nil else { // Flow validation in url request
            interactor?.on(api: api, error: CustomError(description: ErrorMessage.list.serverError, code: StatusCode.ServerError.rawValue))
            return
        }
        print("Testing URL: \(url)")
         
        // Setting Secret Key to Identify the response Api

        urlRequest?.addValue(api.rawValue, forHTTPHeaderField: WebConstants.string.secretKey)
        urlRequest?.addValue(WebConstants.string.application_json, forHTTPHeaderField: WebConstants.string.Content_Type)
        urlRequest?.addValue(WebConstants.string.XMLHttpRequest, forHTTPHeaderField: WebConstants.string.X_Requested_With)
        urlRequest?.addValue(WebConstants.string.bearer+String.removeNil(User.main.accessToken), forHTTPHeaderField: WebConstants.string.Authorization)

        
        sessionManager?.request(urlRequest!).validate(statusCode: StatusCode.success.rawValue..<StatusCode.multipleResponse.rawValue).response(completionHandler: { (response) in
            
            let api = response.request?.value(forHTTPHeaderField: WebConstants.string.secretKey) ?? .Empty
            if api == Base.estimateFare.rawValue{
                print(api)
            }
            if api == Base.updateRequest.rawValue{
                print(api)
            }
            if api == Base.getProviders.rawValue{ //Now this api is called on trip
                print(api)
            }
            if api == Base.deleteAccount.rawValue{
                print(api)
            }
         //   print("At Webservice Response  at ",api,"   ",response.error ?? "No errors", response.response?.statusCode ?? 0)
            
            print(String(data: response.data!, encoding: .utf8))
            
            
            guard let responseData = response.data else {
                self.send(response)
                return
            }
            
            let string = String(decoding: responseData, as: UTF8.self)
            print(string)
            
            guard let refinedData = String(data: responseData, encoding: .utf8)?.replacingOccurrences(of: "\"", with: "").data(using: .utf8) else{
                self.send(response)
                return
            }
            
            if Data(base64Encoded: refinedData) != nil{
                
                //refinedData.removeSubrange(4...44)
                
                guard let base64EncodedData = Data(base64Encoded: refinedData) else {
                    self.send(response)
                    return
                }
                
                guard let decodedData = String(data: base64EncodedData, encoding: .utf8)?.data(using: .utf8) else{
                    self.send(response)
                    return
                }
                
                self.send(DefaultDataResponse(request: response.request, response: response.response, data: decodedData, error: response.error, timeline: response.timeline, metrics: response.metrics))
                
            }else{
                self.send(response)
            }
            
            
        })
    }
    
   
    
     // MARK:- Send Api with Image

    private func send(api: Base, imageData: [String:Data]?, parameters: [String : Any]?){
    
        guard let url = URL(string: baseUrl+api.rawValue) else {  // Validating Url
            print("Invalid Url")
            return
        }

        var headers = HTTPHeaders()

        headers.updateValue(api.rawValue, forKey: WebConstants.string.secretKey)
        headers.updateValue(WebConstants.string.multipartFormData, forKey: WebConstants.string.Content_Type)
        headers.updateValue(WebConstants.string.XMLHttpRequest, forKey: WebConstants.string.X_Requested_With)
        headers.updateValue(WebConstants.string.bearer+String.removeNil(User.main.accessToken), forKey: WebConstants.string.Authorization)


        sessionManager?.upload(multipartFormData: { (multipartFormData) in

            for (key, value) in parameters ?? [:]{
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
                }
            

            if let imageArray = imageData{
                
                for array in imageArray {
                    multipartFormData.append(array.value, withName: array.key, fileName: "image.png", mimeType: "image/png")
                }
                
            }


        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.response { (response) in
                    self.send(response)
                }
            case .failure(let error ):
                 self.send(nil)
                print("Error in upload: \(error.localizedDescription)")

            }
            
        }
    
    
    
    }




    // Crash Analytics

    private func setCrashLog(base : Base){
        
        if let fName = User.main.firstName, let lName = User.main.lastName {
            Crashlytics.sharedInstance().setUserName(fName+" "+lName)
        }
        if let email = User.main.email {
            Crashlytics.sharedInstance().setUserEmail(email)
        }
        if let idVal = User.main.id {
            Crashlytics.sharedInstance().setUserIdentifier("\(idVal)")
        }
        Crashlytics.sharedInstance().setObjectValue(base.rawValue, forKey: "Last Api Called")
    }

    
   
}



