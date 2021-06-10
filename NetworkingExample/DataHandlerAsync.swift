//
//  DataHandlerAsync.swift
//  NetworkingExample
//
//  Created by Gualtiero Frigerio on 10/06/21.
//  Copyright © 2021 Gualtiero Frigerio. All rights reserved.
//

import Foundation

enum DataHandlerAsyncError: Error {
    case connectionError
    case decodingError
    case wrongURL
}

@available (iOS 15.0, *)
class DataHandlerAsync {
    init(withBaseURL:String, restClient:RESTHandler) {
        self.baseURLString = withBaseURL
        self.restClient = restClient
    }
    
    private var baseURLString:String
    private var restClient:RESTHandler
    
    private func getData(forEntity entity: Entity) async throws -> Data {
        guard let url = getUrl(forEntity: entity) else {
            throw DataHandlerAsyncError.wrongURL
        }
        let data = try await restClient.getData(atURL: url)
        return data
    }
    
    private func getUrl(forEntity entity: Entity) -> URL? {
        let urlString = baseURLString + entity.endPoint
        return URL(string: urlString)
    }
}

@available(iOS 15.0, *)
extension DataHandlerAsync: DataSourceAsync {
    func getAlbums() async throws -> [Album] {
        let data = try await getData(forEntity: .Album)
        guard let albums = DataSourceCommon.decodeData(data: data,
                                                       type: [Album].self) as? [Album] else {
            throw DataHandlerAsyncError.decodingError
        }
        return albums
    }
    
    func getPictures() async throws -> [Picture] {
        let data = try await getData(forEntity: .Picture)
        guard let pictures = DataSourceCommon.decodeData(data: data,
                                                       type: [Picture].self) as? [Picture] else {
            throw DataHandlerAsyncError.decodingError
        }
        return pictures
    }
    
    func getUsers() async throws -> [User] {
        let data = try await getData(forEntity: .User)
        guard let users = DataSourceCommon.decodeData(data: data, type: [User].self) as? [User] else {
            throw DataHandlerAsyncError.decodingError
        }
        return users
    }
    
    func getUsersWithMergedData() async throws -> [User] {
        async let users = getUsers()
        async let pictures = getPictures()
        async let albums = getAlbums()
        
        let mergedAlbums = try await DataSourceCommon.mergeAlbums(albums, withPictures:pictures)
        let mergedUsers = try await DataSourceCommon.mergeUsers(users,
                                                                withAlbums: mergedAlbums)
        
        return mergedUsers
    }
    
    
}
