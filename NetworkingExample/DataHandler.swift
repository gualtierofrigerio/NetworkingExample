//
//  DataHandler.swift
//  NetworkingExample
//
//  Created by Gualtiero Frigerio on 12/04/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import Foundation

class DataHandler {
    
    private var baseURLString:String?
    private var restClient:RESTClient?
    
    init(withBaseURL:String, restClient:RESTClient) {
        self.baseURLString = withBaseURL
        self.restClient = restClient
    }
}

// MARK: - DataSource

extension DataHandler : DataSource {
    
    func getAlbums() -> Promise<[Album]> {
        return getDataWithPromise(forEntity: .Album, withType: [Album].self)
    }
    
    func getPictures() -> Promise<[Picture]> {
        return getDataWithPromise(forEntity: .Picture, withType: [Picture].self)
    }
    
    func getUsers() -> Promise<[User]> {
        return getDataWithPromise(forEntity: .User, withType: [User].self)
    }
    
    func getUsersWithMergedData() -> Promise<[User]> {
        return getPictures().then({self.addPicturesToAlbums($0)})
                            .then({self.addAlbumsToUsers($0)})
    }
}

// MARK: - Private

extension DataHandler {
    
    private func addAlbumsToUsers(_ albums:[Album]) -> Promise<[User]> {
        let usersPromise = Promise<[User]>()
        getUsers().observe { promiseReturn in
            switch promiseReturn {
            case .value(let users):
                let usersWithAlbums = DataSourceCommon.mergeUsers(users, withAlbums: albums)
                usersPromise.resolve(value: usersWithAlbums)
            case .error(let error):
                usersPromise.reject(error: error)
            }
        }
        return usersPromise
    }
    
    private func addPicturesToAlbums(_ pictures:[Picture]) -> Promise<[Album]> {
        let albumsPromise = Promise<[Album]>()
        getAlbums().observe { promiseReturn in
            switch promiseReturn {
            case .value(let albums):
                let albumsWithPictures = DataSourceCommon.mergeAlbums(albums, withPictures: pictures)
                albumsPromise.resolve(value: albumsWithPictures)
            case .error(let error):
                albumsPromise.reject(error: error)
            }
        }
        return albumsPromise
    }
    
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
            newPromise.reject(error: DatasourceErrors.decodingError)
        }
        return newPromise
    }
    
    private func getDataWithPromise<T>(forEntity entity: Entity, withType type:T.Type) -> Promise<T> where T:Decodable {
        var promise:Promise<T>
        guard let url = getUrl(forEntity: entity),
              let restClient = restClient else {
            promise = Promise<T>()
            promise.reject(error: DatasourceErrors.wrongURL)
            return promise
        }
        
        promise = restClient.getData(atURL: url)
                            .then({self.decodeDataPromise($0, type: type)})
        return promise
    }
    
    private func getUrl(forEntity entity: Entity) -> URL? {
        guard let baseURLString = baseURLString else {return nil}
        let urlString = baseURLString + entity.endPoint
        return URL(string: urlString)
    }
}
