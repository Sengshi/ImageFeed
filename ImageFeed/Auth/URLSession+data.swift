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
}

final class OAuth2Service {
    static let shared = OAuth2Service() // Синглтон для удобства использования
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private init() {}
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com/oauth/token") else {
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
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread) // Убедимся, что метод вызывается на главном потоке
        
        guard lastCode != code else {
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let oauthTokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(oauthTokenResponse.accessToken))
                } catch {
                    print("Ошибка декодирования: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Сетевая ошибка: \(error.localizedDescription)")
                completion(.failure(error))
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
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        
        return task
    }
}
