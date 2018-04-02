//
//  MediaModel.swift
//  KMC-Player
//
//  Created by Nilit Danan on 3/14/18.
//  Copyright © 2018 Nilit Danan. All rights reserved.
//

import UIKit
import KalturaClient

class BaseEntryManager: NSObject {

    static let shared = BaseEntryManager(executor: USRExecutor.shared)
    private var executor: RequestExecutor
    private var client: Client
    private var baseEntryList: BaseEntryListResponse?
    
    var allBaseEntryListObjects: Array<BaseEntry>? {
        get {
            return self.baseEntryList?.objects
        }
    }
    
    var videoMediaEntryListObjects: Array<BaseEntry>? {
        get {
            return baseEntryList?.objects?.filter({ (entry) -> Bool in
                switch entry {
                case is MediaEntry:
                    guard let mediaEntry: MediaEntry = entry as? MediaEntry else {
                        return false
                    }
                    
                    guard let mediaType = mediaEntry.mediaType else {
                        return false
                    }
                    
                    switch mediaType {
                    case .VIDEO:
                        return true
                    default:
                        return false
                    }
                default:
                    return false
                }
            })
        }
    }
    
    private init(executor: RequestExecutor) {
        self.executor = executor
        self.client = Client(ConnectionConfiguration())
    }
    
    func list(completion: @escaping (ApiException?) -> Void) {
        let listRequestBuilder = BaseEntryService.list()
        
        let mrb = MultiRequestBuilder()
            .add(request: listRequestBuilder).setParam(key: "ks", value: UserManager.shared.ksValue)
            .set { (data: [Any?]?, error: ApiException?) in
            
                if (error != nil) {
                    completion(error)
                    return
                }
                
                guard let dataArray = data else {
                    let exception = ApiException(message: "Data is not Array", code:"BaseEntryManagerExceptionDataNotArray")
                    completion(exception)
                    return
                }
                
                guard let response = dataArray.first else {
                    let exception = ApiException(message: "Data is empty", code:"BaseEntryManagerExceptionDataIsEmpty")
                    completion(exception)
                    return
                }
                
                switch response {
                case is BaseEntryListResponse:
                    guard let baseEntryList = response as? BaseEntryListResponse else {
                        let exception = ApiException(message: "BaseEntryListResponse is empty", code:"BaseEntryManagerExceptionKSIsEmpty")
                        completion(exception)
                        return
                    }
                    self.baseEntryList = baseEntryList
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
}
