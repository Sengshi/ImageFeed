//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Денис Кель on 17.03.2025.
//

import Foundation


final class ProfilePresenter: ProfilePresenterProtocol {
    var view: ProfileViewProtocol?
    
    private let profileService: ProfileService = ProfileService.shared
    private let profileImageService: ProfileImageService = ProfileImageService.shared
    private let logoutService: ProfileLogoutService = ProfileLogoutService.shared
    private let tokenStorage: OAuth2TokenStorage = OAuth2TokenStorage.shared
    
    func viewDidLoad() {
        loadProfile()
    }
    
    func didTapLogout() {
        logoutService.logout()
    }
        
    private func loadProfile() {
        guard let token = tokenStorage.token else {
            view?.showError(message: "Ошибка: Токен отсутствует")
            return
        }
        
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                DispatchQueue.main.async {
                    self.view?.updateProfile(profile: profile)
                }
                self.loadAvatar(for: profile.username)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.view?.showError(message: "Ошибка при загрузке профиля: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func loadAvatar(for username: String) {
        profileImageService.fetchProfileImageURL(username: username) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let avatarURL):
                DispatchQueue.main.async {
                    self.view?.updateAvatar(with: avatarURL)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.view?.showError(message: "Ошибка при загрузке аватарки: \(error.localizedDescription)")
                }
            }
        }
    }
}

protocol ProfilePresenterProtocol {
    var view: ProfileViewProtocol? { get set }
    func viewDidLoad()
    func didTapLogout()
}

