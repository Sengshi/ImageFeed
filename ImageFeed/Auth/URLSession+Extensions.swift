import Foundation

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

