//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Денис Кель on 10.02.2025.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private var avatarImage: UIImageView = UIImageView()
    private var logoutButton: UIButton = UIButton(type: .custom)
    private var userNameLabel: UILabel = UILabel()
    private var loginNameLabel: UILabel = UILabel()
    private var descriptionLabel: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 26, green: 27, blue: 34, alpha: 1)
        setupAvatarImage()
        setupUserNameLabel()
        setupLoginNameLabel()
        setupDescriptionLabel()
        setupLogoutButton()
        setupConstraints()
        loadProfile()
    }
    
    // Setup Avatar Image
    private func setupAvatarImage() {
        avatarImage.image = UIImage(named: "placeholder")
        avatarImage.contentMode = .scaleAspectFit
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImage)
    }
    
    // Setup User Name Label
    private func setupUserNameLabel() {
        userNameLabel.text = "Екатерина Новикова"
        userNameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        userNameLabel.textColor = .white
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userNameLabel)
    }
    
    // Setup Login Name Label
    private func setupLoginNameLabel() {
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        loginNameLabel.textColor = UIColor.init(red: 174, green: 175, blue: 180, alpha: 1)
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
    }
    
    // Setup Description Label
    private func setupDescriptionLabel() {
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = .white
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        view.addSubview(descriptionLabel)
    }
    
    // Setup Logout Button
    private func setupLogoutButton() {
        logoutButton.setImage(UIImage(named: "logout_button"), for: .normal)
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton(_:)), for: .touchUpInside)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
    }
    
    // Setup Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Констрейнты для avatarImage
            avatarImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImage.widthAnchor.constraint(equalToConstant: 70),
            avatarImage.heightAnchor.constraint(equalToConstant: 70),
            
            // Констрейнты для userNameLabel
            userNameLabel.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 8),
            userNameLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor, constant: 0),
            userNameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16),
            
            // Констрейнты для loginNameLabel
            loginNameLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor, constant: 0),
            loginNameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16),
            
            // Констрейнты для descriptionLabel
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor, constant: 0),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16),
            
            // Констрейнты для logoutButton
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImage.centerYAnchor),
            avatarImage.widthAnchor.constraint(equalToConstant: 44),
            avatarImage.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    // Actions
    @objc private func didTapLogoutButton(_ sender: Any) {
        // Обработка нажатия на кнопку выхода
        print("Logout button tapped")
    }
    
    private func loadProfile() {
        guard let token = OAuth2TokenStorage.shared.token else {
            print("Ошибка: Токен отсутствует")
            return
        }
        
        profileService.fetchProfile(token) { result in
            switch result {
            case .success(let profile):
                self.updateUI(with: profile)
                self.fetchProfileImageURL(username: profile.username)
            case .failure(let error):
                print("Ошибка при загрузке профиля: \(error.localizedDescription)")
            }
        }
        
    }
    
    private func fetchProfileImageURL(username: String) {
        profileImageService.fetchProfileImageURL(username: username) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let avatarURL):
                // Загружаем аватарку по URL
                self.loadAvatarImage(from: avatarURL)
                
            case .failure(let error):
                self.showErrorAlert(message: "Ошибка при загрузке аватарки: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadAvatarImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Ошибка: Не удалось создать URL для аватарки")
            return
        }
        // Используем Kingfisher для загрузки изображения
        let processor = RoundCornerImageProcessor(cornerRadius: 100)
        avatarImage.kf.indicatorType = .activity
        avatarImage.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder"), // Заглушка, пока изображение загружается
            options: [
                .transition(.fade(0.5)),
                .processor(processor)
            ]
        )
    }
    
    private func updateUI(with profile: Profile) {
        userNameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}
