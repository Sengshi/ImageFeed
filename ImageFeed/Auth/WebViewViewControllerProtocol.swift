//
//  WebViewViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Денис Кель on 07.03.2025.
//

import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
