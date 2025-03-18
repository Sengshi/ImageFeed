//
//  ViewController.swift
//  ImageFeed
//
//  Created by Денис Кель on 03.02.2025.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    static let shared: ImagesListViewController = .init()
    
    @IBOutlet var tableView: UITableView!
    
    let showSingleImageSegueIdentifier = "ShowSingleImage"
    var photos: [Photo] = []
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    lazy var iso8601DateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
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
        let uniqueNewPhotos = newPhotos.filter { newPhoto in
            !photos.contains(where: { $0.id == newPhoto.id })
        }
        
        guard !uniqueNewPhotos.isEmpty else { return }

        let newCount = photos.count + uniqueNewPhotos.count
        photos.append(contentsOf: uniqueNewPhotos)

        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        tableView.performBatchUpdates({
            tableView.insertRows(at: indexPaths, with: .automatic)
        }, completion: nil)
    }
}

