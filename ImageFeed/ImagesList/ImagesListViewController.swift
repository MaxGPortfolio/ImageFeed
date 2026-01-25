//
//  ViewController.swift
//  ImageFeed
//
//  Created by Максим on 26.12.2025.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Private Properties
    private let photoNames: [String] = Array(0..<20).map{ "\($0)" }
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let verticalInset: CGFloat = 12
        tableView.contentInset = UIEdgeInsets(top: verticalInset, left: 0, bottom: verticalInset, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let image = UIImage(named: photoNames[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photoNames[indexPath.row]) else {
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoNames.count
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
    func configureCell(for cell: ImagesListCell, at indexPath: IndexPath) {
        guard let image = UIImage(named: photoNames[indexPath.row]) else {
            return
        }
        
        cell.setImage(image)
        cell.setDateText(dateFormatter.string(from: Date()))
        
        let isLiked = indexPath.row % 2 == 0
        cell.setIsLiked(isLiked)
    }
}
