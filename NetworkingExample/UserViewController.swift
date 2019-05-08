//
//  UserViewController.swift
//  NetworkingExample
//
//  Created by Gualtiero Frigerio on 08/05/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {

    private var usernameValue:UILabel?
    private var mailValue:UILabel?
    private var user:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    func setUser(_ user:User) {
        self.user = user
        usernameValue?.text = user.username
    }
}

extension UserViewController {
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
        usernameValue.text = user?.username
        self.usernameValue = usernameValue
        stackView.addArrangedSubview(usernameValue)
        
        let mailLabel = UILabel()
        mailLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
        mailLabel.heightAnchor.constraint(equalToConstant: height).isActive = true
        mailLabel.text = "Mail"
        stackView.addArrangedSubview(mailLabel)
        
        let mailValue = UILabel()
        mailValue.widthAnchor.constraint(equalToConstant: width).isActive = true
        mailValue.heightAnchor.constraint(equalToConstant: height).isActive = true
        mailValue.text = user?.email
        self.mailValue = mailValue
        stackView.addArrangedSubview(mailValue)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
}
