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
    var dataSource:DataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = DataHandler(withBaseURL: baseURL, restClient: restClient)
        // Do any additional setup after loading the view, typically from a nib.
        //getUsers()
        //getUsersWithPromise()
        //getAlbums()
        getUserWithMergedData()
    }
    
    func getAlbums() {
        let promiseAlbums = dataSource.getAlbums()
        promiseAlbums.observe { (returnUsers) in
            switch returnUsers {
            case .value(let albums):
                print("----- getAlbums -----")
                for album in albums {
                    print("album title = \(album.title)")
                }
            case .error(let err):
                print("error \(err.localizedDescription)")
            }
        }
    }
    
    func getUsers() {
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
    
    func getUserWithMergedData() {
        dataSource.getUsersWithMergedData().observe { promiseReturn in
            switch promiseReturn {
            case .value(let users):
                print("---- users with merged data ----")
                for user in users {
                    self.printUser(user)
                }
            case .error(let error):
                 print("error \(error)")
            }
        }
    }
    
    func getUsersWithPromise() {
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

// MARK - Private

extension ViewController {
    func printUser(_ user:User) {
        print("user name = \(user.username)")
        if let albums = user.albums {
            for album in albums {
                print("album with title \(album.title)")
                if let pictures = album.pictures {
                    for picture in pictures {
                        print("picture url \(picture.url)")
                    }
                }
            }
        }
    }
}
