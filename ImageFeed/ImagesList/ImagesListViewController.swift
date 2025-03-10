//
//  ViewController.swift
//  ImageFeed
//
//  Created by Денис Кель on 03.02.2025.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var photos: [Photo] = []
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    static let shared = ImagesListService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 200 // Устанавливаем высоту ячейки
        tableView.contentInset = UIEdgeInsets(
            top: 12,
            left: 0,
            bottom: 12,
            right: 0
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        ImagesListService.shared.fetchPhotosNextPage(){ [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case .success:
                break
            case .failure(let error):
                print("Ошибка при загрузке фотографий: \(error.localizedDescription)")
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == showSingleImageSegueIdentifier,
            let viewController = segue.destination as? SingleImageViewController,
            let photo = sender as? Photo
        else {
            assertionFailure("Invalid segue destination")
            return
        }
        
        viewController.imageURL = URL(string: photo.largeImageURL)
    }
    
    @objc private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newPhotos = ImagesListService.shared.photos
        let newCount = newPhotos.count
        
        guard oldCount != newCount else { return }
        
        photos = newPhotos
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        tableView.performBatchUpdates({
            tableView.insertRows(at: indexPaths, with: .automatic)
        }, completion: nil)
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let image = photos[indexPath.row]
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: URL(string: image.thumbImageURL),
            placeholder: UIImage(named: "placeholder_tumb")
        )
        cell.delegate = self
        
        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(named: "like_active") : UIImage(
            named: "like_no_active"
        )
        cell.likeButton.setImage(likeImage, for: .normal)
        cell.dateLabel.text = dateFormatter.string(from: image.createdAt!)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
    
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        performSegue(
            withIdentifier: showSingleImageSegueIdentifier,
            sender: photo
        )
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let image = photos[indexPath.row]
        guard URL(string: image.largeImageURL) != nil else {
            return 0
        }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.width
        let scale = imageViewWidth / CGFloat(imageWidth)
        let cellHeight = CGFloat(image.height) * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            ImagesListService.shared.fetchPhotosNextPage { _ in }
        }
    }
    
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        var photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        ImagesListService.shared.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard self != nil else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success():
                photo.isLiked.toggle()
                self?.photos[indexPath.row] = photo
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(let error):
                print("Ошибка при изменении лайка: \(error.localizedDescription)")
            }
            }
        }
    }
