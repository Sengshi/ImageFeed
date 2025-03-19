//
//  ViewController.swift
//  ImageFeed
//
//  Created by Денис Кель on 03.02.2025.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController & ImagesListViewProtocol {
    @IBOutlet var tableView: UITableView!

    var presenter: ImagesListPresenterProtocol = ImagesListPresenter()
    let showSingleImageSegueIdentifier = "ShowSingleImage"
    
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

        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        presenter.attachView(self)

    }

    func updateTableView() {
        tableView.reloadData()
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
}
