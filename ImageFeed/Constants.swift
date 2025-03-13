//
//  Constants.swift
//  ImageFeed
//
//  Created by Денис Кель on 03.03.2025.
//

import Foundation

enum Constants {
    static let accessKey = "dXPRI4ppYtw1NyTEOVbFaBT2uYTegY1ENKsfaHtUQss"
    static let secretKey = "HcjpD7T9tryJOcnjDOkgfVtjZ0YzWv5DArPiO0TAU6Y"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}
