//
//  ProfileViewProtocol.swift
//  ImageFeed
//
//  Created by Денис Кель on 17.03.2025.
//

import Foundation


protocol ProfileViewProtocol: AnyObject {
    func updateProfile(profile: Profile)
    func updateAvatar(with url: String)
    func showError(message: String)
}
