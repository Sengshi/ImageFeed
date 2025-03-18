//
//  ProfileViewControllerSpy.swift
//  ImageFeed
//
//  Created by Денис Кель on 17.03.2025.
//

@testable import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewProtocol {
    private(set) var updateProfileCalled = false
    private(set) var updateAvatarCalled = false
    private(set) var showErrorCalled = false

    private(set) var receivedProfile: Profile?
    private(set) var receivedAvatarURL: String?
    private(set) var receivedErrorMessage: String?

    func updateProfile(profile: Profile) {
        updateProfileCalled = true
        receivedProfile = profile
    }

    func updateAvatar(with url: String) {
        updateAvatarCalled = true
        receivedAvatarURL = url
    }

    func showError(message: String) {
        showErrorCalled = true
        receivedErrorMessage = message
    }
}
