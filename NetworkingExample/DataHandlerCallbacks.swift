//
//  DataHandlerCallbacks.swift
//  NetworkingExample
//
//  Created by Gualtiero Frigerio on 17/04/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import Foundation

class DataHandlerCallbacks {
    
    private var baseURLString:String?
    private var restClient:RESTClient?
    
    init(withBaseURL:String, restClient:RESTClient) {
        self.baseURLString = withBaseURL
        self.restClient = restClient
    }
}

extension DataHandlerCallbacks : DataSourceCallbacks {
    func getAlbums(completion: @escaping ([Album]?) -> Void) {
        getData(forEntityEndpoint: .Albums, withType:[Album].self) { (data) in
            let albumData = data as? [Album]
            completion(albumData)
        }
    }
    
    func getPictures(completion: @escaping ([Picture]?) -> Void) {
        getData(forEntityEndpoint: .Pictures, withType:[Picture].self) { (data) in
            let pictureData = data as? [Picture]
            completion(pictureData)
        }
    }
    
    func getUsers(completion: @escaping (([User]?) -> Void)) {
        getData(forEntityEndpoint: .Users, withType:[User].self) { (data) in
            let userData = data as? [User]
            completion(userData)
        }
    }
    
    func getUsersWithMergedData(completion: @escaping ([User]?) -> Void) {
        getUsers { users in
            self.getAlbums { albums in
                self.getPictures { pictures in
                    guard   let pictures = pictures,
                            let albums = albums,
                            let users = users else {
                                completion(nil)
                                return
                            }
                    let newAlbums = DataSourceCommon.mergeAlbums(albums, withPictures:pictures)
                    let newUsers = DataSourceCommon.mergeUsers(users, withAlbums: newAlbums)
                    completion(newUsers)
                }
            }
        }
    }
}

// MARK: - Private

extension DataHandlerCallbacks {
    
    private func getData<T>(forEntityEndpoint: EntityEndpoint, withType type:T.Type, completion:@escaping (Decodable?) ->Void) where T:Decodable {
        guard let url = getUrl(forEntityEndpoint: forEntityEndpoint) else {
            completion(nil)
            return
        }
        restClient?.getData(atURL: url, completion: { (data) in
            guard let data = data else {
                completion(nil)
                return
            }
            let decodedData = DataSourceCommon.decodeData(data: data, type:type)
            completion(decodedData)
        })
    }
    
    private func getUrl(forEntityEndpoint: EntityEndpoint) -> URL? {
        guard let baseURLString = baseURLString else {return nil}
        let urlString = baseURLString + forEntityEndpoint.rawValue
        return URL(string: urlString)
    }
}
