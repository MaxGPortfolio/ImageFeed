//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Максим on 26.12.2025.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let verticalContentInset: CGFloat = 12
        static let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
    }
    
    // MARK: - Private Properties
    
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    private var imagesListServiceObserver: NSObjectProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        
        return formatter
    }()
    
    // MARK: - Public Properties
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        
        tableView.contentInset = UIEdgeInsets(
            top: Constants.verticalContentInset,
            left: 0,
            bottom: Constants.verticalContentInset,
            right: 0
        )
        
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: imagesListService,
            queue: .main,
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
        }
        imagesListService.fetchPhotosNextPage()
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    deinit {
        if let observer = imagesListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        
        let imageViewWidth = (
            tableView.bounds.width
            - Constants.imageInsets.left
            - Constants.imageInsets.right
        )
        
        guard photo.size.width > 0 else { return 0 }
    
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + Constants.imageInsets.top + Constants.imageInsets.bottom
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let photo = photos[indexPath.row]
        
        let singleImageVC = SingleImageViewController()
        singleImageVC.imageURL = photo.largeImageURL
        
        singleImageVC.modalPresentationStyle = .fullScreen
        singleImageVC.modalTransitionStyle = .coverVertical
        
        present(singleImageVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard !photos.isEmpty else { return }
        
        let thresholdIndex = max(photos.count - 5, 0)

        if indexPath.row >= thresholdIndex {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configureCell(for: imageListCell, at: indexPath)
        
        return imageListCell
    }
}

private extension ImagesListViewController {
    // MARK: - Cell Configuration
    func configureCell(for cell: ImagesListCell, at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        cell.delegate = self
        
        cell.setImage(from: photo.regularImageURL)
        
        let dateText = photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        
        cell.setDateText(dateText)
        cell.setIsLiked(photo.isLiked)
    }
    
    // MARK: - Setup
    func setupViews() {
        view.backgroundColor = .ypBlack
        view.addSubview(tableView)
        tableView.backgroundColor = .ypBlack
        tableView.separatorStyle = .none
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        
        guard newCount > oldCount else { return }
        
        photos = imagesListService.photos
        
        let indexPaths = (oldCount..<newCount).map {
            IndexPath(row: $0, section: 0)
        }
        
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        let photo = photos[indexPath.row]

        UIBlockingProgressHUD.show()

        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else {
                UIBlockingProgressHUD.dismiss()
                return
            }

            switch result {
            case .success:
                self.photos = self.imagesListService.photos

                if let cell = self.tableView.cellForRow(at: indexPath) as? ImagesListCell {
                    cell.setIsLiked(self.photos[indexPath.row].isLiked)
                }

                UIBlockingProgressHUD.dismiss()

            case .failure:
                UIBlockingProgressHUD.dismiss()

                let alert = UIAlertController(                      // добавил от себя для лучшего UX
                    title: "Что-то пошло не так(",
                    message: "",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Ок", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}
