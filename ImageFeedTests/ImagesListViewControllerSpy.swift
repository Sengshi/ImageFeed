//
//  ImagesListViewSpy.swift
//  ImageFeed
//
//  Created by Денис Кель on 19.03.2025.
//

import Foundation
@testable import ImageFeed


final class ImagesListViewControllerSpy: ImagesListViewProtocol {
    private(set) var updateTableViewCalled = false
    private(set) var showErrorCalled = false
    private(set) var receivedErrorMessage: String?
    
    func updateTableView() {
        updateTableViewCalled = true
    }
    
    func showError(_ message: String) {
        showErrorCalled = true
        receivedErrorMessage = message
    }
}
