//
//  WebViewPresenterSpy.swift
//  ImageFeed
//
//  Created by Денис Кель on 17.03.2025.
//

@testable import ImageFeed
import Foundation

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    weak var view: WebViewViewControllerProtocol?
    
    var viewDidLoadCalled = false
    var didUpdateProgressValueCalled = false
    var receivedProgressValue: Double?
    
    
    func viewDidLoad() {
        viewDidLoadCalled = true
        let request = URLRequest(url: URL(string: "https://unsplash.com")!)
        
        view?.load(request: request)
        
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        didUpdateProgressValueCalled = true
        receivedProgressValue = newValue
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
}
