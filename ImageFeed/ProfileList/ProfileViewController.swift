//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Денис Кель on 10.02.2025.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController & ProfileViewProtocol {
    
    
    var presenter: ProfilePresenter?
    
    private let avatarImage = UIImageView()
    private let logoutButton = UIButton(type: .custom)
    private let userNameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ProfilePresenter()
        presenter?.view = self
        presenter?.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 26, green: 27, blue: 34, alpha: 1)
        
        setupAvatarImage()
        setupUserNameLabel()
        setupLoginNameLabel()
        setupDescriptionLabel()
        setupLogoutButton()
        setupConstraints()
    }
    
    private func setupAvatarImage() {
        avatarImage.image = UIImage(named: "placeholder")
        avatarImage.layer.cornerRadius = 35
        avatarImage.layer.masksToBounds = true
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImage)
    }
    
    private func setupUserNameLabel() {
        setupLabel(userNameLabel, font: .systemFont(ofSize: 23, weight: .bold), textColor: .white)
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userNameLabel)
    }
    
    private func setupLoginNameLabel() {
        setupLabel(loginNameLabel, font: .systemFont(ofSize: 13, weight: .regular), textColor: UIColor(red: 174, green: 175, blue: 180, alpha: 1))
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
    }
    
    private func setupDescriptionLabel() {
        setupLabel(descriptionLabel, font: .systemFont(ofSize: 13, weight: .regular), textColor: .white)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        view.addSubview(descriptionLabel)
    }
    
    private func setupLogoutButton() {
        logoutButton.setImage(UIImage(named: "logout_button"), for: .normal)
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton(_:)), for: .touchUpInside)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImage.widthAnchor.constraint(equalToConstant: 70),
            avatarImage.heightAnchor.constraint(equalToConstant: 70),
            
            userNameLabel.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 8),
            userNameLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            
            loginNameLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImage.centerYAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    @objc private func didTapLogoutButton(_ sender: Any) {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        let confirmAction = UIAlertAction(title: "Да", style: .default) { _ in
            self.presenter?.didTapLogout()
        }
        let cancelAction = UIAlertAction(title: "Нет", style: .default, handler: nil)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func updateProfile(profile: Profile) {
        userNameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    func updateAvatar(with url: String) {
        guard let url = URL(string: url) else { return }
        let processor = RoundCornerImageProcessor(cornerRadius: avatarImage.frame.size.width / 2)
        avatarImage.kf.indicatorType = .activity
        avatarImage.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder"),
            options: [
                .transition(.fade(0.5)),
                .processor(processor)
            ]
        )
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupLabel(_ label: UILabel, font: UIFont, textColor: UIColor, numberOfLines: Int = 1) {
        label.font = font
        label.textColor = textColor
        label.numberOfLines = numberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
    }
}

protocol ProfileViewControllerProtocol {
    var view: ProfileViewProtocol? { get set }
    func viewDidLoad()
    func didTapLogout()
}
