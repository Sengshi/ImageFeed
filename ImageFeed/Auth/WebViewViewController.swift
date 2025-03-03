//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Денис Кель on 03.03.2025.
//

import UIKit
@preconcurrency import WebKit

private enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}


final class WebViewViewController: UIViewController {
    
    weak var delegate: WebViewViewControllerDelegate?
    private var webView: WKWebView!
    private var backButton: UIButton!
    private var progressView: UIProgressView!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupProgressView()
        webView.navigationDelegate = self
        setupConstraints()
        loadAuthView()
    }

    private func setupWebView() {
        webView = WKWebView(frame: view.bounds)
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
    }
    
    private func setupProgressView() {
        progressView = UIProgressView()
        progressView.progress = 0.5
        progressView.progressTintColor = UIColor(red: 26, green: 27, blue: 34, alpha: 1)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
    }

    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("Строка подключения не связана с URLComponents")
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]

        guard let url = urlComponents.url else {
            return
        }

        let request = URLRequest(url: url)
        webView.load(request)
        
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            // Констрейнты для webView
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            // Констрейнты для progressView
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
        ])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.webViewViewControllerDidCancel(self)
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
         if let code = code(from: navigationAction) {
                delegate?.webViewViewController(self, didAuthenticateWithCode: code)
                decisionHandler(.cancel)
          } else {
                decisionHandler(.allow)
            }
    }
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
