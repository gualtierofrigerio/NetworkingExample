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
    let restClient = RESTHandlerMoya()
    var dataSource:DataSource!
    var dataSourceCallbacks:DataSourceCallbacks!
    @available (iOS 15.0, *)
    var dataSourceAsync:DataSourceAsync {
        DataHandlerAsync(withBaseURL: baseURL, restClient: RESTHandler())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = DataHandler(withBaseURL: baseURL, restClient: restClient)
        dataSourceCallbacks = DataHandlerCallbacks(withBaseURL: baseURL, restClient: restClient)
        // Do any additional setup after loading the view, typically from a nib.
        //getUsers()
        //getUsersWithPromise()
        //getAlbums()
        //getUserWithMergedData()
        //getUserWithMergedDataCallbacks()
    }
    @IBAction func exampleButtonTap(_ sender: Any) {
        dataSource.getUsersWithMergedData().observe { promiseReturn in
            switch promiseReturn {
            case .value(let users):
                self.showUsers(users)
            case .error(let error):
                print("error \(error)")
            }
        }
    }
    
    @IBAction func rxExampleButtonTap(_ sender: Any) {
        dataSource.getUsersWithMergedData().observe { promiseReturn in
            switch promiseReturn {
            case .value(let users):
                self.showUsersRx(users)
            case .error(let error):
                print("error \(error)")
            }
        }
    }
    
    @IBAction func asyncExampleButtonTap(_ sender: Any) {
        if #available(iOS 15.0, *) {
            async {
                do {
                    let users = try await dataSourceAsync.getUsersWithMergedData()
                    self.showUsers(users)
                } catch {
                    print("error while getting users async")
                }
            }
        } else {
            print("sorry, iOS 15 only")
        }
    }
    
    func showUsers(_ users:[User]) {
        DispatchQueue.main.async {
            let usersVC = UsersTableViewController()
            usersVC.setUsers(users)
            self.navigationController?.pushViewController(usersVC, animated: true)
        }
    }
    
    func showUsersRx(_ users:[User]) {
        DispatchQueue.main.async {
            let usersVC = UsersTableViewControllerRx()
            usersVC.setUsers(users)
            self.navigationController?.pushViewController(usersVC, animated: true)
        }
    }
    
}

// MARK: - Promise

extension ViewController {
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

// MARK: - Callbacks

extension ViewController {
    
    func getUsers() {
        dataSourceCallbacks.getUsers { users in
            guard let users = users else {
                return
            }
            print("----- getUsers -----")
            for user in users {
                print("user name = \(user.username)")
            }
        }
    }
    
    func getUserWithMergedDataCallbacks() {
        dataSourceCallbacks.getUsersWithMergedData { users in
            guard let users = users else {return}
            for user in users {
                self.printUser(user)
            }
        }
    }
}

// MARK: - async await

@available (iOS 15.0, *)
extension ViewController {
    func getUsers() async throws -> [User] {
        let users = try await dataSourceAsync.getUsers()
        return users
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
