//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Денис Кель on 17.03.2025.
//

@testable import ImageFeed
import XCTest

final class WebViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        _ = viewController.view
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
        // Given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        // Given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        // When
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        // Then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        // Given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        
        // When
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        // Then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        // Given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        // When
        let url = authHelper.authURL()
        
        guard let urlString = url?.absoluteString else {
            XCTFail("Auth URL is nil")
            return
        }
        
        // Then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
        // Given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        guard let url = urlComponents.url else {
            XCTFail("Invalid URL")
            return
        }
        let authHelper = AuthHelper()
        
        // When
        let code = authHelper.code(from: url)
        
        // Then
        XCTAssertEqual(code, "test code")
    }
}

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
    
    func testViewDidLoad_CallsPresenterViewDidLoad() {
        // When
        profileViewController.viewDidLoad()
        
        // Then
        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }
    
    func testDidTapLogout_CallsPresenterDidTapLogout() {
        // When
        presenterSpy.didTapLogout()

        // Then
        XCTAssertTrue(presenterSpy.showLogoutConfirmationCalled)
    }
    
    func testUpdateProfile_UpdatesViewCorrectly() {
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
    
    func testUpdateAvatar_UpdatesViewCorrectly() {
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

