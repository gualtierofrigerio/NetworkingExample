//
//  UserTableViewControllerRx.swift
//  NetworkingExample
//
//  Created by Gualtiero Frigerio on 08/05/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class UsersTableViewControllerRx: UIViewController {

    private let cellIdentifier = "CellIdentifier"
    private let disposeBag = DisposeBag()
    private let tableView = UITableView()
    
    private var users = [User]()
    private let filteredUsers:BehaviorRelay<[User]> = BehaviorRelay(value: [])
    private let filterText:BehaviorRelay<String> = BehaviorRelay<String>(value:"")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterText.subscribe(onNext: { [weak self] text in
            self?.filterUsers(withString: text)
        }).disposed(by: disposeBag)
        
        configureTableView()
        configureSearchViewController()
        //configureTableViewNoSearch()
    }
    
    func setUsers(_ users:[User]) {
        self.users = users
        self.filteredUsers.accept(users)
    }
}

// MARK: - Private

extension UsersTableViewControllerRx {
    
    private func configureCell(_ cell:UITableViewCell, withUser user:User) {
        cell.textLabel?.text = user.username
    }
    
    private func configureSearchViewController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        
        searchController.searchBar.rx.text
            .bind(onNext: { [weak self] text in
                self?.filterText.accept(text?.lowercased() ?? "")
            })
            .disposed(by: disposeBag)
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.frame = view.frame
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        filteredUsers.asObservable()
            .bind(to: tableView.rx
            .items(cellIdentifier: cellIdentifier,
                   cellType: UITableViewCell.self)) {
                    row, user, cell in
                    self.configureCell(cell, withUser: user)
            }
            .disposed(by:disposeBag)
        
        tableView.rx
            .modelSelected(User.self)
            .subscribe(onNext: { [weak self] user in
                self?.showUser(user)
            })
            .disposed(by: disposeBag)
    }
    
    private func configureTableViewNoSearch() {
        view.addSubview(tableView)
        tableView.frame = view.frame
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        filteredUsers.asObservable()
            .bind(to: tableView.rx
            .items(cellIdentifier: cellIdentifier,
               cellType: UITableViewCell.self)) {
                row, user, cell in
                self.configureCell(cell, withUser: user)
            }
            .disposed(by:disposeBag)
    }
    
    @discardableResult private func filterUsers(withString filter:String) -> [User] {
        var filteredUsers = users
        if filter.count > 0 {
            filteredUsers = users.filter({
                return $0.username.lowercased().contains(filter.lowercased())
            })
        }
        self.filteredUsers.accept(filteredUsers)
        return filteredUsers
    }
    
    private func showUser(_ user:User) {
        let userVC = UserViewControllerRx()
        userVC.setUser(user)
        self.navigationController?.pushViewController(userVC, animated: true)
    }
}
