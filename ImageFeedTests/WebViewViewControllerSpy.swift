//
//  WebViewViewControllerSpy.swift
//  ImageFeed
//
//  Created by Денис Кель on 17.03.2025.
//

import Foundation
import ImageFeed


final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: ImageFeed.WebViewPresenterProtocol?

    var loadRequestCalled: Bool = false

    func load(request: URLRequest) {
        loadRequestCalled = true
    }

    func setProgressValue(_ newValue: Float) {

    }

    func setProgressHidden(_ isHidden: Bool) {

    }
}
