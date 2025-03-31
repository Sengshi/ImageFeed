//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Денис Кель on 17.03.2025.
//

@testable import ImageFeed
import XCTest


final class ProfileViewTests: XCTestCase {
    private var presenterSpy: ProfilePresenterSpy!
    private var viewSpy: ProfileViewControllerSpy!
    private var profileViewController: ProfileViewController!
    
    override func setUp() {
        super.setUp()
        
        presenterSpy = ProfilePresenterSpy()
        viewSpy = ProfileViewControllerSpy()
        profileViewController = ProfileViewController()
        profileViewController.presenter = presenterSpy
        presenterSpy.view = viewSpy
        
    }
    
    override func tearDown() {
        presenterSpy = nil
        viewSpy = nil
        profileViewController = nil
        super.tearDown()
    }
    
    func testPresenterViewDidLoad() {
        // Given
        
        // When
        profileViewController.viewDidLoad()
        
        // Then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testPresenterDidTapLogout() {
        // Given
        
        // When
        presenterSpy.didTapLogout()
        
        // Then
        XCTAssertTrue(presenterSpy.showLogoutConfirmationCalled)
    }
    
    func testProfileUpdatesViewCorrectly() {
        // Given
        let profileResult = ProfileResult(username: "johndoe", firstName: "John", lastName: "Doe", bio: "Test bio")
        let profile = Profile(profileResult: profileResult)
        
        // When
        viewSpy.updateProfile(profile: profile)
        
        // Then
        XCTAssertTrue(viewSpy.updateProfileCalled)
        XCTAssertEqual(viewSpy.receivedProfile?.name, "John Doe")
        XCTAssertEqual(viewSpy.receivedProfile?.loginName, "@johndoe")
        XCTAssertEqual(viewSpy.receivedProfile?.bio, "Test bio")
    }
    
    func testUpdateAvatar() {
        // Given
        let avatarURL = "https://example.com/avatar.jpg"
        
        // When
        viewSpy.updateAvatar(with: avatarURL)
        
        // Then
        XCTAssertTrue(viewSpy.updateAvatarCalled)
        XCTAssertEqual(viewSpy.receivedAvatarURL, avatarURL)
    }
    
    func testShowError_ShowsErrorCorrectly() {
        // Given
        let errorMessage = "Test error message"
        
        // When
        viewSpy.showError(message: errorMessage)
        
        // Then
        XCTAssertTrue(viewSpy.showErrorCalled)
        XCTAssertEqual(viewSpy.receivedErrorMessage, errorMessage)
    }
}
