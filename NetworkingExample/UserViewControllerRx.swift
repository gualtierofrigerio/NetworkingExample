//
//  UserViewControllerRx.swift
//  NetworkingExample
//
//  Created by Gualtiero Frigerio on 08/05/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

struct UserViewModel {
    let username = BehaviorRelay<String>(value:"")
    let email = BehaviorRelay<String>(value:"")
    
    func update(withUser user:User) {
        self.username.accept(user.username)
        self.email.accept(user.email)
    }
}

class UserViewControllerRx: UIViewController {

    let disposeBag = DisposeBag()
    let viewModel = UserViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func setUser(_ user:User) {
        viewModel.update(withUser: user)
    }

}

extension UserViewControllerRx {
    private func configureView() {
        view.backgroundColor = UIColor.white
        
        let stackView = UIStackView()
        view.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 10
        
        let width = self.view.frame.size.width
        let height:CGFloat = 40.0
        
        let usernameLabel = UILabel()
        usernameLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
        usernameLabel.heightAnchor.constraint(equalToConstant: height).isActive = true
        usernameLabel.text = "Username"
        stackView.addArrangedSubview(usernameLabel)
        
        let usernameValue = UILabel()
        usernameValue.widthAnchor.constraint(equalToConstant: width).isActive = true
        usernameValue.heightAnchor.constraint(equalToConstant: height).isActive = true
        stackView.addArrangedSubview(usernameValue)
        
        let mailLabel = UILabel()
        mailLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
        mailLabel.heightAnchor.constraint(equalToConstant: height).isActive = true
        mailLabel.text = "Mail"
        stackView.addArrangedSubview(mailLabel)
        
        let mailValue = UILabel()
        mailValue.widthAnchor.constraint(equalToConstant: width).isActive = true
        mailValue.heightAnchor.constraint(equalToConstant: height).isActive = true
        stackView.addArrangedSubview(mailValue)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        viewModel.username
            .asObservable()
            .map{$0.uppercased()}
            .bind(to:usernameValue.rx.text)
            .disposed(by:disposeBag)
        
        viewModel.email
            .asObservable()
            .bind(to:mailValue.rx.text)
            .disposed(by: disposeBag)
    }
}
