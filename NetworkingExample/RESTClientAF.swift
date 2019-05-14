//
//  RestClientAF.swift
//  NetworkingExample
//
//  Created by Gualtiero Frigerio on 13/05/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import Alamofire
import Foundation

class RESTHandlerAF : RESTClient {
    func getData(atURL url: URL, completion: @escaping (Data?) -> Void) {
        Alamofire.request(url)
            .responseData { responseData in
                completion(responseData.data)
            }
    }
    
    func getData(atURL url: URL) -> Promise<Data> {
        let promise = Promise<Data>()
        Alamofire.request(url)
            .responseData { responseData in
                if let data = responseData.data {
                    promise.resolve(value: data)
                }
                else {
                    promise.reject(error: responseData.error ?? NSError())
                }
            }
        return promise
    }
    

}
