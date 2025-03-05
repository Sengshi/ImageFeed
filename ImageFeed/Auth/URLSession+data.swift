import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case noData
    case unauthorized
}

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
        request.httpMethod = "POST"
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


final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage() // Синглтон
    
    private let tokenKey = "BearerToken"
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = dataTask(with: request) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                let statusCode = response.statusCode
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnMainThread(.success(data))
                } else {
                    print("[dataTask]: NetworkError - HTTP status code \(statusCode), URL: \(request.url?.absoluteString ?? "unknown")")
                    fulfillCompletionOnMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                print("[dataTask]: NetworkError - URL request error \(error.localizedDescription), URL: \(request.url?.absoluteString ?? "unknown")")
                fulfillCompletionOnMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("[dataTask]: NetworkError - Unknown URL session error, URL: \(request.url?.absoluteString ?? "unknown")")
                fulfillCompletionOnMainThread(.failure(NetworkError.urlSessionError))
            }
        }

        return task
    }

    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        
        let task = data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    print("[objectTask]: Decoding error - \(error.localizedDescription), Data: \(String(data: data, encoding: .utf8) ?? "nil")")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("[objectTask]: Network request failed - \(error.localizedDescription), URL: \(request.url?.absoluteString ?? "unknown")")
                completion(.failure(error))
            }
        }
        return task
    }
}

