//
//  Photo.swift
//  ImageFeed
//
//  Created by Денис Кель on 14.03.2025.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let welcomeDescription: String?
    let urls: UrlsResult
    let isLiked: Bool
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case welcomeDescription = "alt_description"
        case urls
        case isLiked = "liked_by_user"
    }
    
    struct UrlsResult: Decodable {
        let small: String
        let full: String
    }
}

struct Photo: Decodable {
    let id: String
    let createdAt: Date?
    let width: Int
    let height: Int
    var isLiked: Bool
    let thumbImageURL: String
    let largeImageURL: String
    let welcomeDescription: String?
    
    init(from result: PhotoResult) {
        self.id = result.id
        self.width = result.width
        self.height = result.height
        self.isLiked = result.isLiked
        self.thumbImageURL = result.urls.small
        self.largeImageURL = result.urls.full
        if let createdAtString = result.createdAt {
            self.createdAt = ImagesListViewController.shared.iso8601DateFormatter.date(from: createdAtString)
        } else {
            self.createdAt = nil
        }
        self.welcomeDescription = result.welcomeDescription
    }
    
    
}


