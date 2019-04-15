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
    var title:String?
    var userId:Int?
}

struct User:Codable {
    var id:Int
    var email:String
    var name:String
    var username:String
}

protocol DataSource {
    func getUsers(completion: @escaping ([User]?) -> Void)
    func getUsers() -> Promise<[User]>
    func getAlbums() -> Promise<[Album]>
}
