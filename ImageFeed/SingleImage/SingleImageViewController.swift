//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Денис Кель on 27.02.2025.
//

import UIKit

final class SingleImageViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBAction private func didTapShareButton(_ sender: Any) {
        // Проверяем, что изображение доступно
        guard let image = image else {
            print("Изображение недоступно.")
            return
        }
        // Создаем UIActivityViewController
        let activityViewController = UIActivityViewController(
            activityItems: [image], // Передаем изображение
            applicationActivities: nil // Дополнительные активности
        )
        // Показываем UIActivityViewController
        present(activityViewController, animated: true, completion: nil)

    }
    
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        rescaleAndCenterImageInScrollView(image: UIImage())
        scrollView.delegate = self
        
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        guard scrollView != nil, imageView != nil else { return }
        
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        // Проверка на нулевые размеры
        guard !visibleRectSize.width.isZero, !visibleRectSize.height.isZero,
              !imageSize.width.isZero, !imageSize.height.isZero else {
            return
        }
        
        // Рассчитываем масштаб
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        
        // Устанавливаем масштаб
        scrollView.setZoomScale(scale, animated: false)
        
        // Обновляем layout
        scrollView.layoutIfNeeded()
        
        // Обновляем contentSize
        let newContentSize = CGSize(
            width: imageSize.width * scale,
            height: imageSize.height * scale
        )
        scrollView.contentSize = newContentSize
        
        // Рассчитываем смещение для центрирования
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        
        // Устанавливаем смещение
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
