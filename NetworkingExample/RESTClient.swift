//
//  RESTClient.swift
//  NetworkingExample
//
//  Created by Gualtiero Frigerio on 12/04/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import Foundation

protocol RESTClient {
    func getData(atURL url:URL, completion: @escaping (Data?) -> Void)
    func getData(atURL url:URL) -> Promise<Data>
}

class RESTHandler : RESTClient {
    @available(iOS 15.0, *)
    func getData(atURL url: URL) async throws -> Data {
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request, delegate: nil)
        return data
    }
    
    
    func getData(atURL url: URL, completion: @escaping (Data?) -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            completion(data)
        }
        task.resume()
    }
    
    func getData(atURL url: URL) -> Promise<Data> {
        let promise = Promise<Data>()
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            if let err = error {
                promise.reject(error: err)
            }
            else {
                if let data = data {
                    promise.resolve(value: data)
                }
                else {
                    let unknowError = NSError(domain: "", code : 0, userInfo: nil)
                    promise.reject(error: unknowError)
                }
            }
        }
        task.resume()
        return promise
    }
}
