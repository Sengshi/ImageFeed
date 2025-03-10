//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Денис Кель on 27.02.2025.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    private var scrollView: UIScrollView = UIScrollView()
    private var buttonBack: UIButton = UIButton()
    private var buttonShare: UIButton = UIButton()
    
    var imageView: UIImageView = UIImageView()
    var imageURL: URL?
    
    // Методы жизненного цикла
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 26, green: 27, blue: 34, alpha: 1)
        setupScrollView()
        setupImageView()
        setupButtonBack()
        setupButtonShare()
        setupConstraints()
    }
    
    // Приватные методы
    private func setupScrollView() {
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(imageView)
        UIBlockingProgressHUD.show()
        if let url = imageURL {
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholder_full_image")
            ) { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                guard let self = self else { return }
                switch result {
                    case .success: self.updateImageScaleAndPosition()
                    case .failure: print("Error downloading image")
                }
                
            }
        }
    }
    
    private func setupButtonBack() {
        buttonBack.setImage(UIImage(named: "to_back"), for: .normal)
        buttonBack.addTarget(self, action: #selector(didTapButtonBack(_:)), for: .touchUpInside)
        buttonBack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonBack)
        
    }
    
    private func setupButtonShare() {
        buttonShare.setImage(UIImage(named: "share_button"), for: .normal)
        buttonShare.addTarget(self, action: #selector(didTapButtonShare(_:)), for: .touchUpInside)
        buttonShare.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonShare)
        
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            imageView.widthAnchor.constraint(lessThanOrEqualTo: scrollView.widthAnchor),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: scrollView.heightAnchor),
            buttonShare.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonShare.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonBack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            buttonBack.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
            buttonBack.heightAnchor.constraint(equalToConstant: 44),
            buttonBack.widthAnchor.constraint(equalToConstant: 44),
        ])
        
    }
    
    private func updateImageScaleAndPosition() {
        guard let image = imageView.image else { return }
        
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        guard !visibleRectSize.width.isZero, !visibleRectSize.height.isZero,
              !imageSize.width.isZero, !imageSize.height.isZero else {
            return
        }
        
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        let newContentSize = CGSize(
            width: imageSize.width * scale,
            height: imageSize.height * scale
        )
        scrollView.contentSize = newContentSize
        
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    @objc private func didTapButtonBack(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @objc private func didTapButtonShare(_ sender: Any) {
        guard let image = imageView.image else {
            print("Изображение недоступно.")
            return
        }
        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        activityViewController.overrideUserInterfaceStyle = .dark
        present(activityViewController, animated: true)
    }
    
}

// UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

