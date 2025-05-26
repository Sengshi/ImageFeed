//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Денис Кель on 20.03.2025.
//

import XCTest
@testable import ImageFeed
import ProgressHUD

final class ImageFeedUITests: XCTestCase {
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app.terminate()
        app = nil
        try super.tearDownWithError()
    }
    
    func testAuth() throws {
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5), "Кнопка авторизации не найдена")
        authButton.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10), "WebView не загрузился")
        
        let loginTextField = webView.textFields.element
        let passwordTextField = webView.secureTextFields.element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10), "Поле логина не найдено")
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10), "Поле пароля не найдено")
        
        loginTextField.tap()
        loginTextField.typeText("asket2013@ya.ru")
        webView.swipeUp()
        
        passwordTextField.tap()
        passwordTextField.typeText("Def53917468")
        
        webView.swipeUp()
        app.buttons["Login"].tap()
        
        let firstCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15), "Лента не загрузилась")
    }
    
    
    func testFeed() throws {
        let tablesQuery = app.tables
        sleep(3)

        let firstCell = tablesQuery.cells.element(boundBy: 0)
        firstCell.swipeUp()
        sleep(3)

        let cellToLike = tablesQuery.cells.element(boundBy: 1)
        let likeButton = cellToLike.buttons[AccessibilityIdentifiers.Feed.likeButton]
        sleep(2)
        likeButton.tap()
        sleep(5)

        let unLikeButton = cellToLike.buttons[AccessibilityIdentifiers.Feed.unLikeButton]
        sleep(2)
        unLikeButton.tap()
        sleep(5)

        cellToLike.tap()
        sleep(5)

        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        sleep(10)
        image.pinch(withScale: 0.5, velocity: -1)
        sleep(10)

        let backButton = app.buttons[AccessibilityIdentifiers.Feed.backButton]
        backButton.tap()
    }

    
    func testProfile() throws {
        let profileTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
        profileTab.tap()

        let userNameLabel = app.staticTexts[AccessibilityIdentifiers.Profile.userNameLabel]
        XCTAssertTrue(userNameLabel.waitForExistence(timeout: 5))

        let loginNameLabel = app.staticTexts[AccessibilityIdentifiers.Profile.loginNameLabel]
        XCTAssertTrue(loginNameLabel.waitForExistence(timeout: 5))

        let logoutButton = app.buttons[AccessibilityIdentifiers.Profile.logoutButton]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
        logoutButton.tap()

        let alert = app.alerts["Пока, пока!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.scrollViews.otherElements.buttons["Да"].tap()
        
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 10))
    }

    
}
