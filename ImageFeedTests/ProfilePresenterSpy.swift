//
//  ProfilePresenterSpy.swift
//  ImageFeed
//
//  Created by Денис Кель on 17.03.2025.
//

@testable import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    
    weak var view: ProfileViewProtocol?

    private(set) var viewDidLoadCalled = false
    private(set) var showLogoutConfirmationCalled = false
    var presenter: ProfilePresenterProtocol?

    func didTapLogout() {
        showLogoutConfirmationCalled = true
    }

    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
}
