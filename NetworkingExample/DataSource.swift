//
//  DataSource.swift
//  NetworkingExample
//
//  Created by Gualtiero Frigerio on 12/04/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import Foundation

struct Album:Codable {
    var id:Int
    var title:String
    var userId:Int
    
    var pictures:[Picture]?
    
    mutating func addPicture(_ picture:Picture) {
        if pictures == nil {
            pictures = [Picture]()
        }
        pictures?.append(picture)
    }
}

struct Picture:Codable {
    var id:Int
    var albumId:Int
    var title:String
    var url:String
    var thumbnailUrl:String
}

struct User:Codable {
    var id:Int
    var email:String
    var name:String
    var username:String
    
    var albums:[Album]?
    
    mutating func addAlbum(_ album:Album) {
        if albums == nil {
            albums = [Album]()
        }
        albums?.append(album)
    }
}

enum Entity {
    case Album
    case Picture
    case User
    
    var endPoint: String {
        switch self {
        case .Album:
            return "/albums"
        case .Picture:
            return "/photos"
        case .User:
            return "/users"
        }
    }
}

protocol DataSource {
    func getAlbums() -> Promise<[Album]>
    func getPictures() -> Promise<[Picture]>
    func getUsers() -> Promise<[User]>
    func getUsersWithMergedData() -> Promise<[User]>
}

protocol DataSourceCallbacks {
    func getAlbums(completion: @escaping ([Album]?) -> Void)
    func getPictures(completion: @escaping ([Picture]?) -> Void)
    func getUsers(completion: @escaping ([User]?) -> Void)
    func getUsersWithMergedData(completion: @escaping ([User]?) -> Void)
}

class DataSourceCommon {
    
    class func decodeData<T>(data:Data, type:T.Type) -> Decodable? where T:Decodable {
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
    
    class func mergeAlbums(_ albums:[Album], withPictures pictures:[Picture]) -> [Album] {
        var albumsWithPictures = [Album]()
        for var album in albums {
            for picture in pictures {
                if picture.albumId == album.id {
                    album.addPicture(picture)
                }
            }
            albumsWithPictures.append(album)
        }
        return albumsWithPictures
    }
    
    class func mergeUsers(_ users:[User], withAlbums albums:[Album]) -> [User] {
        var usersWithAlbums = [User]()
        for var user in users {
            for album in albums {
                if album.userId == user.id {
                    user.addAlbum(album)
                }
            }
            usersWithAlbums.append(user)
        }
        return usersWithAlbums
    }
}
