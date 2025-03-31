//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Денис Кель on 17.03.2025.
//

@testable import ImageFeed
import XCTest

final class ImagesListViewControllerTests: XCTestCase {
    private var presenterSpy: ImagesListPresenterSpy!
    private var viewController: ImagesListViewController!
    
    override func setUp() {
        super.setUp()
        let window = UIWindow()
        
        presenterSpy = ImagesListPresenterSpy()
        viewController = ImagesListViewController()
        viewController.presenter = presenterSpy
        viewController.tableView = UITableView()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        
        _ = viewController.view
        
    }
    
    override func tearDown() {
        presenterSpy = nil
        viewController = nil
        super.tearDown()
    }
    
    func testViewDidLoad_CallsAttachView() {
        // Given
        
        // When
        viewController.viewDidLoad()
        
        // Then
        XCTAssertTrue(presenterSpy.attachViewCalled)
    }
    
    func testShowError_PresentsAlert() {
        // Given
        let errorMessage = "Ошибка загрузки"
        
        // When
        viewController.showError(errorMessage)
        
        // Then
        XCTAssertNotNil(viewController.presentedViewController as? UIAlertController)
        XCTAssertEqual((viewController.presentedViewController as? UIAlertController)?.message, errorMessage)
    }
    
    func testUpdateTableView_ReloadsTableView() {
        // Given
        let tableViewSpy = UITableViewSpy()
        viewController.tableView = tableViewSpy
        
        // When
        viewController.updateTableView()
        
        // Then
        XCTAssertTrue(tableViewSpy.reloadDataCalled)
    }
    
    func testFetchPhotos_CallsFetchPhotos() {
        // Given
        
        // When
        presenterSpy.fetchPhotos()
        
        // Then
        XCTAssertTrue(presenterSpy.fetchPhotosCalled)
    }
    
    func testLikePhoto_CallsLikePhoto() {
        // Given
        let index = 0
        
        // When
        presenterSpy.likePhoto(at: index) { success in
            // Then
            XCTAssertTrue(self.presenterSpy.likePhotoCalled)
            XCTAssertTrue(success)
        }
    }
    
}
