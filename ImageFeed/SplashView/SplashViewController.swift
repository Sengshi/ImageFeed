//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Денис Кель on 03.03.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    private let storage = OAuth2TokenStorage.shared
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = storage.token {
            switchToTabBarController()
        } else {
            switchToAuthViewController()
        }
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }

        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")

        window.rootViewController = tabBarController
    }
    
    private func switchToAuthViewController() {
        let authViewController = AuthViewController()
        authViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: authViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
}



extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        switchToTabBarController()
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }

            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
