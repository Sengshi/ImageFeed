//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Денис Кель on 10.03.2025.
//

import Foundation

final class ImagesListService {
    
    static let shared = ImagesListService()
    private(set) var photos: [Photo] = []
    private let decoder = JSONDecoder()
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private init() {}
    
    func fetchPhotosNextPage(_ completion: @escaping (Result<String, Error>) -> Void) {
        guard task == nil else { return }
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("Ошибка: Токен отсутствует")
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let request = makePhotosNextPage(token: token, nextPage: nextPage) else {
            print("[ImagesListService]: Failed to create request for token")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.task = nil

                if let error = error {
                    print("[ImagesListService]: Ошибка при изменении лайка - \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    print("[ImagesListService]: Нет данных для обработки")
                    completion(.failure(NetworkError.invalidResponse))
                    return
                }

                do {
                    let newPhotosResult = try self.decoder.decode([PhotoResult].self, from: data)
                    let newPhotos = newPhotosResult.map { Photo(from: $0) }
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                } catch {
                    print("[ImagesListService]: Ошибка при декодировании данных - \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        
        self.task = task
        task.resume()
        
    }
    
    private func makePhotosNextPage(token: String, nextPage: Int) -> URLRequest? {
        guard let url = URL(string: "\(Constants.defaultBaseURL)/photos?page=\(nextPage)") else {
            print("Ошибка: Не удалось создать URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard task == nil else { return }
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("Ошибка: Токен отсутствует")
            return
        }
        
        guard let request = makeLikeRequest(photoId: photoId, isLike: isLike, token: token) else {
            print("[ImagesListService]: Ошибка при создании запроса")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.task = nil
                
                if let error = error {
                    print("[ImagesListService]: Ошибка при изменении лайка - \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("[ImagesListService]: Некорректный ответ сервера")
                    completion(.failure(NetworkError.invalidResponse))
                    return
                }
                
                switch httpResponse.statusCode {
                case 200..<300:
                    completion(.success(()))
                default:
                    print("[ImagesListService]: Ошибка сервера - код \(httpResponse.statusCode)")
                    completion(.failure(NetworkError.invalidResponse))
                }
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeLikeRequest(photoId: String, isLike: Bool, token: String) -> URLRequest? {
        let urlString = "\(Constants.defaultBaseURL)/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            print("Ошибка: Неверный URL для лайка")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func cleanImagesData() {
        photos = []
        lastLoadedPage = nil
        OAuth2TokenStorage.shared.token = nil
        task?.cancel()
        task = nil
    }
}
