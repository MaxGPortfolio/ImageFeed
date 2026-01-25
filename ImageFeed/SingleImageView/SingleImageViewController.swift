//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Максим on 17.01.2026.
//

import UIKit

final class SingleImageViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let minimumZoomScale: CGFloat = 0.1
        static let maximumZoomScale: CGFloat = 1.25
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    // MARK: - Public Properties
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else {
                return
            }
            configure(with: image)
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        configureIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureIfNeeded()
    }
    
    // MARK: - Actions
    
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
        present(
            UIActivityViewController(activityItems: [image], applicationActivities: nil),
            animated: true,
            completion: nil
        )
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true)
    }
    
    // MARK: - Private
    
    private func setupScrollView() {
        scrollView.minimumZoomScale = Constants.minimumZoomScale
        scrollView.maximumZoomScale = Constants.maximumZoomScale
        scrollView.delegate = self
    }
    
    private func configureIfNeeded() {
        guard let image else {
            return
        }
        configure(with: image)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        updateInsetsForCentering()
        centerContentOffsetIfNeeded()
    }
    
    private func updateInsetsForCentering() {
        let boundsSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize
        
        let horizontalInset = max(0, (boundsSize.width - contentSize.width) / 2)
        let verticalInset = max(0, (boundsSize.height - contentSize.height) / 2)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
    
    private func centerContentOffsetIfNeeded() {
        let boundsSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize

        let x = max(0, (contentSize.width - boundsSize.width) / 2)
        let y = max(0, (contentSize.height - boundsSize.height) / 2)

        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func configure(with image: UIImage) {
        imageView.image = image
        imageView.frame = CGRect(origin: .zero, size: image.size)
        scrollView.contentSize = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateInsetsForCentering()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        updateInsetsForCentering()
    }
}
