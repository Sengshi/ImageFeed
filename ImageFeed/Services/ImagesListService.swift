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
    
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    
    func fetchPhotosNextPage(_ completion: @escaping (Result<String, Error>) -> Void) {
        task?.cancel()
        
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
        
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[Photo], Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.task = nil
                
                switch result {
                case .success(let newPhotos):
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                    
                case .failure(let error):
                    print("[ImagesListService]: failed to dowload image with error - \(error.localizedDescription)")
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
        task?.cancel()
        
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
