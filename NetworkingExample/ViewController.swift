//
//  ViewController.swift
//  NetworkingExample
//
//  Created by Gualtiero Frigerio on 12/04/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let baseURL = "https://jsonplaceholder.typicode.com"
    let restClient = RESTHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getUsers()
        getUsersWithPromise()
        getAlbums()
    }
    
    func getAlbums() {
        let dataSource = DataHandler(withBaseURL: baseURL, restClient: restClient)
        let promiseAlbums = dataSource.getAlbums()
        promiseAlbums.observe { (returnUsers) in
            switch returnUsers {
            case .value(let albums):
                print("----- getAlbums -----")
                for album in albums {
                    if let title = album.title {
                        print("album title = \(title)")
                    }
                    else {
                        print("album with id \(album.id) has no title")
                    }
                }
            case .error(let err):
                print("error \(err)")
            }
        }
    }
    
    func getUsers() {
        let dataSource = DataHandler(withBaseURL: baseURL, restClient: restClient)
        dataSource.getUsers { (users) in
            guard let users = users else {
                return
            }
            print("----- getUsers -----")
            for user in users {
                print("user name = \(user.username)")
            }
        }
    }
    
    func getUsersWithPromise() {
        let dataSource = DataHandler(withBaseURL: baseURL, restClient: restClient)
        let promiseUsers = dataSource.getUsers()
        promiseUsers.observe { (returnUsers) in
            switch returnUsers {
            case .value(let users):
                print("----- getUsersWithPromise -----")
                for user in users {
                    print("user name = \(user.username)")
                }
            case .error(let err):
                print("error \(err)")
            }
        }
    }
}

