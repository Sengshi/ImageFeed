
//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Денис Кель on 17.03.2025.
//

import Foundation


final class WebViewPresenter: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    
    private var authHelper: AuthHelperProtocol
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    func viewDidLoad() {
        guard let request = authHelper.authURLRequest else { return }
        
        didUpdateProgressValue(0)
        view?.load(request: request)
        
    }
    
    func code(from url: URL) -> String? {
        authHelper.getCode(from: url)
    }
    
}
