//
//  ImagesListViewController+Extensions.swift
//  ImageFeed
//
//  Created by Денис Кель on 18.03.2025.
//

import UIKit

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let image = photos[indexPath.row]
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: URL(string: image.thumbImageURL),
            placeholder: UIImage(named: "placeholder_tumb")
        )
        cell.delegate = self
        
        let likeImage = UIImage(named: image.isLiked ? "like_active" : "like_no_active")
        cell.likeButton.setImage(likeImage, for: .normal)
        if let createdAt = image.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            cell.dateLabel.text = image.welcomeDescription
        }
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
        let photo = photos[indexPath.row]
        let newLikeStatus = !photo.isLiked
        
        UIBlockingProgressHUD.show()
        ImagesListService.shared.changeLike(photoId: photo.id, isLike: newLikeStatus) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success:
                    self.photos[indexPath.row].isLiked = newLikeStatus
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                case .failure(let error):
                    print("Ошибка при изменении лайка: \(error.localizedDescription)")
                }
            }
        }
    }
}
