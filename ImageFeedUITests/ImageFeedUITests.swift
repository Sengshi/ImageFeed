//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Денис Кель on 20.03.2025.
//

import XCTest

class ImageFeedUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        super.setUp()
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
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
        loginTextField.typeText("--логин--")
        webView.swipeUp()

        passwordTextField.tap()
        passwordTextField.typeText("--пароль--")

        webView.swipeUp()
        app.buttons["Login"].tap()

        let firstCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15), "Лента не загрузилась")
    }

    func testFeed() throws {
        let tablesQuery = app.tables
        let firstCell = tablesQuery.cells.element(boundBy: 0)
        firstCell.swipeUp()

        sleep(3)
        firstCell.buttons["ButtonLike"].tap()
        sleep(3)
        firstCell.buttons["ButtonLike"].tap()
        sleep(3)

        firstCell.swipeUp()
        sleep(2)
        
        firstCell.tap()
        sleep(4)
        let imageScrollView = app.scrollViews["ImageScrollView"]
//        XCTAssertTrue(imageScrollView.waitForExistence(timeout: 5))
        sleep(3)
        let image = imageScrollView.images.element(boundBy: 0)
        sleep(3)

        image.pinch(withScale: 1.25, velocity: 1)
        sleep(1)
        
        image.pinch(withScale: 0.1, velocity: -1)
        sleep(1)
        
        let backButton = app.buttons["navBackButton"]
        backButton.tap()

    }

    func testProfile() throws {
        let profileTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
        profileTab.tap()

        let userNameLabel = app.staticTexts["userNameLabel"]
        XCTAssertTrue(userNameLabel.waitForExistence(timeout: 5))

        let loginNameLabel = app.staticTexts["loginNameLabel"]
        XCTAssertTrue(loginNameLabel.waitForExistence(timeout: 5))

        let logoutButton = app.buttons["logoutButton"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
        logoutButton.tap()

        let alert = app.alerts["Пока, пока!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        alert.scrollViews.otherElements.buttons["Да"].tap()
    }
}
