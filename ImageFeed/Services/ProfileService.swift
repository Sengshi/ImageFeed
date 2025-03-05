//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Денис Кель on 05.03.2025.
//

import UIKit
import Foundation

struct ProfileResult: Codable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?

    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?

    init(profileResult: ProfileResult) {
        self.username = profileResult.username
        self.name = "\(profileResult.firstName ?? "") \(profileResult.lastName ?? "")".trimmingCharacters(in: .whitespaces)
        self.loginName = "@\(profileResult.username)"
        self.bio = profileResult.bio
    }
}

final class ProfileService {
    static let shared = ProfileService()

    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var profile: Profile?

    private init() {}
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            print("Ошибка: Не удалось создать URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
            assert(Thread.isMainThread)

            task?.cancel()

            guard let request = makeProfileRequest(token: token) else {
                print("[ProfileService]: Failed to create request for token")
                completion(.failure(NetworkError.invalidRequest))
                return
            }

            let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.task = nil

                    switch result {
                    case .success(let profileResult):
                        let profile = Profile(profileResult: profileResult)
                        self.profile = profile
                        completion(.success(profile))
                    case .failure(let error):
                        print("[ProfileService]: Profile fetch failed - \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            }

            self.task = task
            task.resume()
    }
}


