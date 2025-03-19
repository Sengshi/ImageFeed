//
//  UITableViewSpy.swift
//  ImageFeed
//
//  Created by Денис Кель on 19.03.2025.
//

import UIKit

final class UITableViewSpy: UITableView {
    private(set) var reloadDataCalled = false
    
    override func reloadData() {
        reloadDataCalled = true
    }
}
