//
//  AuthView+Extensions.swift
//  ImageFeed
//
//  Created by Денис Кель on 07.03.2025.
//

import UIKit

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        UIBlockingProgressHUD.show()
        OAuth2Service.shared.fetchOAuthToken(code: code) { result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let accessToken):
                print("Токен получен: \(accessToken)")
                OAuth2TokenStorage.shared.token = accessToken
                ProfileService.shared.fetchProfile(accessToken) { profileResult in
                    switch profileResult {
                    case .success(let profile):
                        print("Профиль загружен: \(profile)")
                        self.delegate?.didAuthenticate(self)
                    case .failure(let error):
                        print("[AuthViewController]: Ошибка загрузки профиля - \(error.localizedDescription)")
                        self.showErrorAlert()
                    }
                }
            case .failure:
                print("[AuthViewController]: Ошибка при получении токена")
                self.showErrorAlert()
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Что-то пошло не так",
                                      message: "Не удалось войти в систему",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
