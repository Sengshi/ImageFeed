//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Денис Кель on 27.02.2025.
//

import UIKit

final class SingleImageViewController: UIViewController {
    // Публичные свойства
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }

    // IBOutlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!

    // IBActions
    @IBAction private func didTapShareButton(_ sender: Any) {
        guard let image = image else {
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

    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true)
    }

    // Методы жизненного цикла
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        updateImageScaleAndPosition()
        scrollView.delegate = self
    }

    // Приватные методы
    private func updateImageScaleAndPosition() {
        guard let image = image else { return }

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
}

// UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
