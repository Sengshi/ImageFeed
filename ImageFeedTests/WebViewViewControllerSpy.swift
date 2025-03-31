//
//  WebViewViewControllerSpy.swift
//  ImageFeed
//
//  Created by Денис Кель on 17.03.2025.
//

import Foundation
@testable import ImageFeed


final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    
    var loadRequestCalled: Bool = false
    var setProgressValueCalled: Bool = false
    var setProgressHiddenCalled: Bool = false
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
        setProgressValueCalled = true
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        setProgressHiddenCalled = true
    }
}
