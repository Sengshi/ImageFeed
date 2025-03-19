//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Денис Кель on 18.03.2025.
//

import Foundation

final class ImagesListPresenter: ImagesListPresenterProtocol {
    var photos: [Photo] = []
    
    weak var view: ImagesListViewProtocol?

    let imagesService = ImagesListService.shared
    func attachView(_ view: ImagesListViewProtocol) {
        self.view = view
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didUpdatePhotos),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        fetchPhotos()
    }

    func fetchPhotos() {
        imagesService.fetchPhotosNextPage { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.photos = self.imagesService.photos
                self.view?.updateTableView()
            case .failure(let error):
                self.view?.showError("Ошибка при загрузке фотографий: \(error.localizedDescription)")
            }
        }
    }

    @objc private func didUpdatePhotos() {
        let newPhotos = imagesService.photos
        let uniqueNewPhotos = newPhotos.filter { newPhoto in
            !photos.contains(where: { $0.id == newPhoto.id })
        }
        guard !uniqueNewPhotos.isEmpty else { return }
        
        photos.append(contentsOf: uniqueNewPhotos)
        view?.updateTableView()
    }

    func getPhoto(at index: Int) -> Photo {
        return photos[index]
    }

    func numberOfPhotos() -> Int {
        return photos.count
    }

    func likePhoto(at index: Int, completion: @escaping (Bool) -> Void) {
        let photo = photos[index]
        let newLikeStatus = !photo.isLiked

        UIBlockingProgressHUD.show()
        imagesService.changeLike(photoId: photo.id, isLike: newLikeStatus) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success:
                    self.photos[index].isLiked = newLikeStatus
                    self.view?.updateTableView()
                    completion(true)
                case .failure:
                    completion(false)
                }
            }
        }
    }
}

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewProtocol? { get set }
    var photos: [Photo] { get set }
    func attachView(_ view: ImagesListViewProtocol)
    func fetchPhotos()
    func likePhoto(at index: Int, completion: @escaping (Bool) -> Void)
}
