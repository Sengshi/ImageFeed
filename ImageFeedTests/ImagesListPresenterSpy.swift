//
//  ImagesListServiceSpy.swift
//  ImageFeed
//
//  Created by Денис Кель on 19.03.2025.
//


import XCTest
@testable import ImageFeed

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?
    private(set) var attachViewCalled = false
    private(set) var fetchPhotosCalled = false
    private(set) var likePhotoCalled = false
    var photos: [Photo] = []
    
    func attachView(_ view: ImagesListViewProtocol) {
        attachViewCalled = true
        self.view = view
    }
    
    func fetchPhotos() {
        fetchPhotosCalled = true
    }
    
    func likePhoto(at index: Int, completion: @escaping (Bool) -> Void) {
        likePhotoCalled = true
        completion(true)
    }
}
