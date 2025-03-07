//
//  Constants.swift
//  ImageFeed
//
//  Created by Денис Кель on 03.03.2025.
//

import Foundation

enum Constants {
    static let accessKey = "yH1wQXwwUb1gTTnCEC5inruIIJj5Rxfc6uqAuYmfzyk"
    static let secretKey = "0fNc1lrqqq1QVq14KtqWJiG0hTM1--eZm9st_NA_kL0"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Не удалось создать URL для baseURL")
        }
        return url
    }()
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}
