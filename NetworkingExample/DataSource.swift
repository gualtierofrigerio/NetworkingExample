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

protocol DataSource {
    func getAlbums() -> Promise<[Album]>
    func getUsers(completion: @escaping ([User]?) -> Void)
    func getPictures() -> Promise<[Picture]>
    func getUsers() -> Promise<[User]>
    
    func getUsersWithMergedData() -> Promise<[User]>
}
