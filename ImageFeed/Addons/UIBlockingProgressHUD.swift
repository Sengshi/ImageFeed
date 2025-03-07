//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by Денис Кель on 05.03.2025.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        UIApplication.shared.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
    
    static func isShowing() -> Bool {
        ProgressHUD.isSubclass(of: UIWindow.self)
    }
}
