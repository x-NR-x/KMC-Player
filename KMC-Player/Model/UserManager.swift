//
//  UserManager.swift
//  KMC-Player
//
//  Created by Nilit Danan on 3/15/18.
//  Copyright © 2018 Nilit Danan. All rights reserved.
//

import UIKit
import KalturaClient

class UserManager: NSObject {

    static let shared = UserManager(executor: USRExecutor.shared)
    private var executor: RequestExecutor
    private var client:Client
    private var ks: String? = nil
    private var partnerId: Int? = nil
    
    var ksValue: String {
        get {
            return self.ks ?? ""
        }
    }
    var partnerIdValue: Int {
        get {
            return self.partnerId ?? 0
        }
    }
    
    private init(executor: RequestExecutor) {
        self.executor = executor
        self.client = Client(ConnectionConfiguration())
    }
    
    func login(partnerId: Int, userId: String, password: String, completion: @escaping (ApiException?) -> Void) {
        
        let loginRequestBuilder = UserService.login(partnerId: partnerId, userId: userId, password: password)
        
        let mrb = MultiRequestBuilder()
            .add(request: loginRequestBuilder)
            .set { (data: [Any?]?, error: ApiException?) in
                
                if (error != nil) {
                    completion(error)
                    return
                }
                
                guard let dataArray = data else {
                    let exception = ApiException(message: "Data is not Array", code:"UserManagerExceptionDataNotArray")
                    completion(exception)
                    return
                }
                
                guard let response = dataArray.first else {
                    let exception = ApiException(message: "Data is empty", code:"UserManagerExceptionDataIsEmpty")
                    completion(exception)
                    return
                }
                
                switch response {
                case is String:
                    guard let ksString = response as? String else {
                        let exception = ApiException(message: "KS is empty", code:"UserManagerExceptionKSIsEmpty")
                        completion(exception)
                        return
                    }
                    self.ks = ksString
                    self.partnerId = partnerId
                case is ApiException:
                    let exception = response as? ApiException
                    completion(exception)
                    return
                default:
                    print("None")
                }
                
                completion(nil)
        }
        
        let request = mrb.build(self.client)
        self.executor.send(request: request)
    }
    
    func isUserLoggedIn() -> Bool {
        guard let ks = self.ks else {
            return false
        }
        return ks.isEmpty ? false : true
    }
}
