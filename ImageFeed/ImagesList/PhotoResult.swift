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

struct Photo {
    let id: String
    let createdAt: Date?
    let width: Int
    let height: Int
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
    
    private static let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
    init(from photoResult: PhotoResult) {
        self.id = photoResult.id
        self.createdAt = Photo.dateFormatter.date(from: photoResult.createdAt ?? "")
        self.width = photoResult.width
        self.height = photoResult.height
        self.welcomeDescription = photoResult.welcomeDescription
        self.thumbImageURL = photoResult.urls.small
        self.largeImageURL = photoResult.urls.full
        self.isLiked = photoResult.isLiked
    }
}
