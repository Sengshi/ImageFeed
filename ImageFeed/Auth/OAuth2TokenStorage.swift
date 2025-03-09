//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Денис Кель on 07.03.2025.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let shared = OAuth2TokenStorage() // Синглтон
    
    private let tokenKey = "BearerToken"
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
}
