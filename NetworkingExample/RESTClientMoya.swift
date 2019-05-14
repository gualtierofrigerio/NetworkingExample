//
//  RESTClientMoya.swift
//  NetworkingExample
//
//  Created by Gualtiero Frigerio on 13/05/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import Foundation
import Moya

extension Entity : TargetType {
    
    var baseURL: URL {
        return URL(string: "https://jsonplaceholder.typicode.com")!
    }
    
    var path: String {
        switch self {
        case .Album:
            return "/albums"
        case .Picture:
            return "/photos"
        case .User:
            return "/users"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        return .requestParameters(parameters: [:], encoding: URLEncoding.default)
    }
    
    var headers: [String : String]? {
        return ["Content-Type" : "application/json"]
    }
}

class RESTHandlerMoya {
    
    let provider = MoyaProvider<Entity>()
    
    func getData(forEntity entity:Entity, completion: @escaping (Data?) -> Void) {
        provider.request(entity) { result in
            switch result {
            case let .success(response):
                completion(response.data)
            case .failure:
                completion(nil)
            }
        }
    }
    
    func getData(forEntity entity: Entity) -> Promise<Data> {
        let promise = Promise<Data>()
        
        provider.request(entity) { result in
            switch result {
            case let .success(response):
                promise.resolve(value: response.data)
            case let.failure(error):
                promise.reject(error: error)
            }
        }
        return promise
    }
}

// MARK: - RESTClient
// I included that only to test Moya as a RESTClient but the protocol
// should be changed to ask for data for a particular entity
// and not for a URL

extension RESTHandlerMoya : RESTClient {
    func getData(atURL url: URL, completion: @escaping (Data?) -> Void) {
        if url.absoluteString.hasSuffix("/albums") {
            getData(forEntity: .Album, completion: completion)
        }
        else if url.absoluteString.hasSuffix("/photos") {
            getData(forEntity: .Picture, completion: completion)
        }
        else if url.absoluteString.hasSuffix("/users") {
            getData(forEntity: .User, completion: completion)
        }
    }
    
    func getData(atURL url: URL) -> Promise<Data> {
        if url.absoluteString.hasSuffix("/albums") {
            return getData(forEntity: .Album)
        }
        else if url.absoluteString.hasSuffix("/photos") {
            return getData(forEntity: .Picture)
        }
        else if url.absoluteString.hasSuffix("/users") {
            return getData(forEntity: .User)
        }
        return Promise()
    }
}
