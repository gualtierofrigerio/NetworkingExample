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
    
    private let users:BehaviorRelay<[User]> = BehaviorRelay(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureSearchViewController()
        //configureTableViewNoSearch()
    }
    
    func setUsers(_ users:[User]) {
        self.users.accept(users)
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
            .asObservable()
            .map{ $0?.lowercased() ?? ""}
            .map{ self.filterUsers(withString: $0) }
            .bind(to: tableView.rx
            .items(cellIdentifier: cellIdentifier,
                      cellType: UITableViewCell.self)) {
                        row, user, cell in
                        self.configureCell(cell, withUser: user)
            }
            .disposed(by:disposeBag)
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.frame = view.frame
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
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
        
        users.asObservable()
            .bind(to: tableView.rx
            .items(cellIdentifier: cellIdentifier,
               cellType: UITableViewCell.self)) {
                row, user, cell in
                self.configureCell(cell, withUser: user)
            }
            .disposed(by:disposeBag)
    }
    
    private func filterUsers(withString filter:String) -> [User] {
        var filteredUsers = users.value
        if filter.count > 0 {
            filteredUsers = users.value.filter({
                return $0.username.lowercased().contains(filter.lowercased())
            })
        }
        return filteredUsers
    }
    
    private func showUser(_ user:User) {
        let userVC = UserViewControllerRx()
        userVC.setUser(user)
        self.navigationController?.pushViewController(userVC, animated: true)
    }
}
