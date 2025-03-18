//
//  WebViewPresenterProtocol.swift
//  ImageFeed
//
//  Created by Денис Кель on 17.03.2025.
//

import Foundation


public protocol WebViewPresenterProtocol {
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?

    var view: WebViewViewControllerProtocol? { get set }

}
