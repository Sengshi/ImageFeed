//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Денис Кель on 03.03.2025.
//

import UIKit

final class AuthViewController: UIViewController {
    
    weak var delegate: AuthViewControllerDelegate?

    private var logoImage: UIImageView!
    private var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 26, green: 27, blue: 34, alpha: 1)
        setupLogoImage()
        setupLoginButton()
        setupBackButton()
        setupConstraints()
    }
    
    // Setup Logo Image
    private func setupLogoImage() {
        logoImage = UIImageView()
        logoImage.image = UIImage(named: "auth_logo")
        logoImage.contentMode = .scaleAspectFit
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoImage)
    }
    
    // Setup Login Button
    private func setupLoginButton() {
        loginButton = UIButton(type: .custom)
        loginButton.setTitle("Войти", for: .normal)
        loginButton.setTitleColor(UIColor(red: 26, green: 27, blue: 34, alpha: 1), for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        loginButton.backgroundColor = .white
        loginButton.layer.cornerRadius = 16
        loginButton.layer.masksToBounds = true
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        view.addSubview(loginButton)
    }
    
    // Setup Constraints
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            // Констрейнты для logoImage
            logoImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            logoImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            logoImage.widthAnchor.constraint(equalToConstant: 60),
            logoImage.heightAnchor.constraint(equalToConstant: 60),
            
            // Констрейнты для loginButton
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),

        ])
    }
    
    @objc private func loginButtonTapped() {
        let webViewViewController = WebViewViewController()
        webViewViewController.delegate = self
        navigationController?.pushViewController(webViewViewController, animated: true)
    }
    
    private func setupBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button") // 1
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button") // 2
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil) // 3
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack") // 4
    }

    
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        OAuth2Service.shared.fetchOAuthToken(code: code) { result in
            switch result {
            case .success(let accessToken):
                print("Токен получен: \(accessToken)")
                OAuth2TokenStorage.shared.token = accessToken
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                print("Ошибка при получении токена: \(error.localizedDescription)")
                self.showErrorAlert(message: error.localizedDescription)
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        navigationController?.popViewController(animated: true)
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}
