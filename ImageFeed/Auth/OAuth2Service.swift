//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Денис Кель on 07.03.2025.
//

import UIKit


final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com/oauth/token") else {
            print("Ошибка: Не удалось создать baseURL")
            return nil
        }
        
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents?.url else {
            print("Ошибка: Не удалось создать URL из URLComponents")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if let lastCode = lastCode, lastCode == code {
            print("[OAuth2Service]: Attempted to reuse the same code \(code)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service]: Failed to create request for code \(code)")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self = self else { return }
                self.task = nil
                self.lastCode = nil
                
                switch result {
                case .success(let response):
                    completion(.success(response.accessToken))
                case .failure(let error):
                    print("[OAuth2Service]: OAuth token fetch failed - \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        
        self.task = task
        task.resume()
    }
}
