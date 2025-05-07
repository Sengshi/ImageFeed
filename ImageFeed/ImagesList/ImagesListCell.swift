//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Денис Кель on 03.02.2025.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    private var gradientLayer: CAGradientLayer?
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var gradientView: UIView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCornerRadius()
        setupGradient()
//        setupLikeButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Обновляем размеры gradientLayer при изменении размеров ячейки
        gradientLayer?.frame = gradientView.bounds
        
        // Обновляем маску с новыми размерами
        let maskPath = UIBezierPath(
            roundedRect: gradientView.bounds,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 16, height: 16)
        )
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        gradientLayer?.mask = maskLayer
    }
    
    
    private func setupCornerRadius() {
        cellImage.layer.cornerRadius = 16
        cellImage.clipsToBounds = true
    }
    
    private func setupGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor(red: 26, green: 27, blue: 34).cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = gradientView.bounds
        
        
        // Создаем маску с скругленными нижними углами
        let maskPath = UIBezierPath(
            roundedRect: gradientView.bounds,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 16, height: 16)
        )
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        gradientLayer.mask = maskLayer
        
        // Добавляем градиент на gradientView
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        gradientView.isUserInteractionEnabled = false
        gradientView.bringSubviewToFront(likeButton)
        
        // Сохраняем ссылку на gradientLayer
        self.gradientLayer = gradientLayer
    }
    
//    private func setupLikeButton() {
//        likeButton.isUserInteractionEnabled = true
//        likeButton.accessibilityIdentifier = AccessibilityIdentifiers.Feed.likeButton
//    }
    func setIsLiked(_ isLiked: Bool) {
        let imageName = isLiked ? "like_active" : "like_no_active"
        likeButton.setImage(UIImage(named: imageName), for: .normal)

        likeButton.accessibilityIdentifier = isLiked
            ? AccessibilityIdentifiers.Feed.unLikeButton // 👈 "like active"
            : AccessibilityIdentifiers.Feed.likeButton   // 👈 "like no active"
    }
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: alpha
        )
    }
}

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
