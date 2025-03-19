//
//  ImagesListViewProtocol.swift
//  ImageFeed
//
//  Created by Денис Кель on 18.03.2025.
//

import Foundation


protocol ImagesListViewProtocol: AnyObject {
    func updateTableView()
    func showError(_ message: String)
}
