//
//  DataHandler.swift
//  NetworkingExample
//
//  Created by Gualtiero Frigerio on 12/04/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import Foundation

enum EntityEndpoint:String {
    case Albums = "/albums"
    case Pictures = "/pictures"
    case Users = "/users"
}

class DataHandler {
    
    private var baseURLString:String?
    private var restClient:RESTClient?
    
    init(withBaseURL:String, restClient:RESTClient) {
        self.baseURLString = withBaseURL
        self.restClient = restClient
    }
}

extension DataHandler : DataSource {
    
    func getAlbums() -> Promise<[Album]> {
        return getDataWithPromise(forEntityEndpoint: .Albums, withType: [Album].self)
    }
    
    func getUsers(completion: @escaping (([User]?) -> Void)) {
        getData(forEntityEndpoint: .Users, withType:[User].self) { (data) in
            let userData = data as? [User]
            completion(userData)
        }
    }
    
    func getUsers() -> Promise<[User]> {
        return getDataWithPromise(forEntityEndpoint: .Users, withType: [User].self)
    }
}

// MARK: - Private

extension DataHandler {
    
    private func decodeData<T>(data:Data, type:T.Type) -> Decodable? where T:Decodable {
        let decoder = JSONDecoder()
        var decodedData:Decodable?
        do {
            decodedData = try decoder.decode(type, from: data)
        }
        catch {
            print("decodeData: cannot decode object err \(error)")
        }
        return decodedData
    }
    
    private func decodeDataPromise<T>(_ data:Data, type:T.Type) -> Promise<T> where T:Decodable {
        let newPromise = Promise<T>()
        if let decodedData = self.decodeData(data: data, type:type) {
            newPromise.resolve(value: decodedData as! T)
        }
        else {
            newPromise.reject(error: self.makeError())
        }
        return newPromise
    }
    
    private func getData<T>(forEntityEndpoint: EntityEndpoint, withType type:T.Type, completion:@escaping (Decodable?) ->Void) where T:Decodable {
        guard let url = getUrl(forEntityEndpoint: .Users) else {
            completion(nil)
            return
        }
        restClient?.getData(atURL: url, completion: { (data) in
            guard let data = data else {
                completion(nil)
                return
            }
            let decodedData = self.decodeData(data: data, type:type)
            completion(decodedData)
        })
    }
    
    private func getDataWithPromise<T>(forEntityEndpoint: EntityEndpoint, withType type:T.Type) -> Promise<T> where T:Decodable {
        var promise:Promise<T>
        guard let url = getUrl(forEntityEndpoint: .Users),
              let restClient = restClient else {
            promise = Promise<T>()
            promise.reject(error: makeError())
            return promise
        }
        
        promise = restClient.getData(atURL: url)
                            .then({self.decodeDataPromise($0, type: type)})
        return promise
    }
    
    private func getUrl(forEntityEndpoint: EntityEndpoint) -> URL? {
        guard let baseURLString = baseURLString else {return nil}
        let urlString = baseURLString + forEntityEndpoint.rawValue
        return URL(string: urlString)
    }
    
    private func makeError() -> Error {
        return NSError(domain: "", code: 0, userInfo: nil)
    }
}
