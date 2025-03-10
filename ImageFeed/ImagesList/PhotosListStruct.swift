//
//  PhotoListStruct.swift
//  ImageFeed
//
//  Created by Денис Кель on 10.03.2025.
//

import Foundation


struct Photo: Codable{
    let id: String
    let width: Int
    let height: Int
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case createdAt = "created_at"
        case welcomeDescription = "alt_description"
        case urls
        case isLiked = "liked_by_user"
    }
    private enum URLKeys: String, CodingKey {
        case small
        case full
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        welcomeDescription = try container.decodeIfPresent(String.self, forKey: .welcomeDescription)
        isLiked = try container.decode(Bool.self, forKey: .isLiked)
        
        if let dateString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            let formatter = ISO8601DateFormatter()
            createdAt = formatter.date(from: dateString)
        } else {
            createdAt = nil
        }
        
        let urlsContainer = try container.nestedContainer(keyedBy: URLKeys.self, forKey: .urls)
        thumbImageURL = try urlsContainer.decode(String.self, forKey: .small)
        largeImageURL = try urlsContainer.decode(String.self, forKey: .full)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encodeIfPresent(welcomeDescription, forKey: .welcomeDescription)
        try container.encode(isLiked, forKey: .isLiked)
        
        if let createdAt = createdAt {
            let formatter = ISO8601DateFormatter()
            try container.encode(formatter.string(from: createdAt), forKey: .createdAt)
        }
        
        var urlsContainer = container.nestedContainer(keyedBy: URLKeys.self, forKey: .urls)
        try urlsContainer.encode(thumbImageURL, forKey: .small)
        try urlsContainer.encode(largeImageURL, forKey: .full)
    }
    
}
