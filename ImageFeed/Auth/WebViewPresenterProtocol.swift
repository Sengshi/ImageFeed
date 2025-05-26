//
//  WebViewPresenterProtocol.swift
//  ImageFeed
//
//  Created by Денис Кель on 17.03.2025.
//

import Foundation


protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
    
    
}
