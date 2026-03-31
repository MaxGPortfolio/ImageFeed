//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Максим on 26.12.2025.
//

import UIKit

@MainActor
protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func reloadRow(at indexPath: IndexPath)
    func showLikeError()
    func showSingleImage(url: String)
    func showLoading()
    func hideLoading()
}

@MainActor
final class ImagesListViewController: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let verticalContentInset: CGFloat = 12
        static let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
    }
    
    // MARK: - Public Properties
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    var presenter: ImagesListPresenterProtocol?
    
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
        presenter?.viewDidLoad()
    }
    
    // MARK: - Private Properties
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
}
// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let presenter else { return 0 }
        let photo = presenter.photo(at: indexPath)
        
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
        presenter?.didSelectRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.didShowCell(at: indexPath)
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photosCount ?? 0
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
        guard let presenter else { return }
        
        let photo = presenter.photo(at: indexPath)
        
        cell.delegate = self
        cell.setImage(from: photo.regularImageURL)
        cell.setDateText(presenter.formattedDate(for: indexPath))
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
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(at: indexPath)
    }
}

// MARK: - ImagesListViewControllerProtocol

extension ImagesListViewController: ImagesListViewControllerProtocol {
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        guard newCount > oldCount else { return }

        let indexPaths = (oldCount..<newCount).map {
            IndexPath(row: $0, section: 0)
        }

        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }

    func reloadRow(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func showLikeError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }

    func showSingleImage(url: String) {
        let singleImageVC = SingleImageViewController()
        singleImageVC.imageURL = url
        singleImageVC.modalPresentationStyle = .fullScreen
        singleImageVC.modalTransitionStyle = .coverVertical
        present(singleImageVC, animated: true)
    }
    
    func showLoading() {
        UIBlockingProgressHUD.show()
    }

    func hideLoading() {
        UIBlockingProgressHUD.dismiss()
    }
}

