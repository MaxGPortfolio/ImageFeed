//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Максим on 17.01.2026.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    // MARK: - Constants
    
    private enum Constants {
        static let minimumZoomScale: CGFloat = 0.1  // was 0.2
        static let maximumZoomScale: CGFloat = 1.25
        
        static let backButtonSize: CGFloat = 24
        static let backButtonTopInset: CGFloat = 11
        static let backButtonLeadingInset: CGFloat = 8
        static let backButtonImage = UIImage(resource: .backArrowWhite)
        static let backButtonImageIdentifier = "backArrowWhite"
        
        static let shareButtonSize: CGFloat = 50
        static let shareButtonBottomConstraintHasHomeIndicator: CGFloat = 17
        static let shareButtonBottomConstraintDoesNotHaveHomeIndicator: CGFloat = 30
        static let shareButtonImage = UIImage(resource: .sharing)
        
        static let placeholderImage = UIImage(resource: .stubIcon)
        static let placeholderImageViewHeight: CGFloat = 75
        static let placeholderImageViewWidth: CGFloat = 83
    }
    
    private var shareButtonBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Public Properties
    
    var imageURL: String?
    private var image: UIImage?
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    // MARK: - Private Properties
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Constants.backButtonImage, for: .normal)
        button.accessibilityIdentifier = Constants.backButtonImageIdentifier
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Constants.shareButtonImage, for: .normal)
        return button
    }()
    
    private lazy var placeholderContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBlack
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Constants.placeholderImage
        imageView.backgroundColor = .clear
        imageView.tintColor = .ypWhiteAlpha50
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var hasConfiguredImage = false
    private var lastScrollViewBounds: CGRect = .zero
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupActions()
        setupConstraints()
        setupScrollView()
        
        loadImage()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        let hasHomeIndicator = view.safeAreaInsets.bottom > 0
        shareButtonBottomConstraint?.constant = hasHomeIndicator
        ? -Constants.shareButtonBottomConstraintHasHomeIndicator
        : -Constants.shareButtonBottomConstraintDoesNotHaveHomeIndicator
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let image else { return }
        
        if !hasConfiguredImage {
            configure(with: image)
            hasConfiguredImage = true
            lastScrollViewBounds = scrollView.bounds
            return
        }
        
        if scrollView.bounds != lastScrollViewBounds {
            relayoutForCurrentBounds(image: image)
            lastScrollViewBounds = scrollView.bounds
        }
    }
    
    private func relayoutForCurrentBounds(image: UIImage) {
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    // MARK: - Private Helpers
    
    private func loadImage() {
        guard
            let imageURL,
            let url = URL(string: imageURL) else  {
            showPlaceholder()
            showImageLoadErrorAlert()
            return
        }
        
        placeholderContainerView.isHidden = true
        scrollView.isHidden = false
        shareButton.isEnabled = false
        shareButton.alpha = 0.5
        
        UIBlockingProgressHUD.show()
        
        imageView.kf.setImage(with: url) { [weak self] result in
            guard let self else {
                UIBlockingProgressHUD.dismiss()
                return
            }
            
            UIBlockingProgressHUD.dismiss()
            
            switch result {
                
            case .success(let value):
                self.image = value.image
                self.hidePlaceholder()
                self.configure(with: value.image)
                self.hasConfiguredImage = true
                self.lastScrollViewBounds = self.scrollView.bounds
            case .failure(let error):
                print("Ошибка загрузки изображения: \(error)")
                self.showPlaceholder()
                self.showImageLoadErrorAlert()
            }
        }
    }
    
    private func setupScrollView() {
        scrollView.minimumZoomScale = Constants.minimumZoomScale
        scrollView.maximumZoomScale = Constants.maximumZoomScale
        scrollView.delegate = self
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
        scrollView.minimumZoomScale = scale
        scrollView.zoomScale = scale
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
    
    private func showPlaceholder() {
        placeholderContainerView.isHidden = false
        scrollView.isHidden = true
        shareButton.isEnabled = false
        shareButton.alpha = 0.5
    }
    
    private func hidePlaceholder() {
        placeholderContainerView.isHidden = true
        scrollView.isHidden = false
        shareButton.isEnabled = true
        shareButton.alpha = 1
    }
    
    private func showImageLoadErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось загрузить изображение",
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: "ОК",
            style: .default,
        ) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        alert.addAction(action)
        present(alert, animated: true)
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

private extension SingleImageViewController {
    
    // MARK: - Setup
    
    func setupViews() {
        view.backgroundColor = .ypBlack
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(placeholderContainerView)
        placeholderContainerView.addSubview(placeholderImageView)
        view.addSubview(backButton)
        view.addSubview(shareButton)
        
        placeholderContainerView.isHidden = true
    }
    
    func setupConstraints() {
        let bottomConstraint = shareButton.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -Constants.shareButtonBottomConstraintHasHomeIndicator
        )
        shareButtonBottomConstraint = bottomConstraint
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            placeholderContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            placeholderContainerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            placeholderContainerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            placeholderContainerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: placeholderContainerView.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: placeholderContainerView.centerYAnchor),
            placeholderImageView.heightAnchor.constraint(equalToConstant: Constants.placeholderImageViewHeight),
            placeholderImageView.widthAnchor.constraint(equalToConstant: Constants.placeholderImageViewWidth),
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.backButtonTopInset),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.backButtonLeadingInset),
            backButton.heightAnchor.constraint(equalToConstant: Constants.backButtonSize),
            backButton.widthAnchor.constraint(equalToConstant: Constants.backButtonSize),
            
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.heightAnchor.constraint(equalToConstant: Constants.shareButtonSize),
            shareButton.widthAnchor.constraint(equalToConstant: Constants.shareButtonSize),
            bottomConstraint
        ])
    }
    
    func setupActions() {
        backButton.addTarget(
            self,
            action: #selector(didTapBackButton),
            for: .touchUpInside
        )
        
        shareButton.addTarget(
            self,
            action: #selector(didTapShareButton),
            for: .touchUpInside
        )
    }
    
    // MARK: - Actions
    @objc
    private func didTapBackButton() {
        dismiss(animated: true)
    }
    
    @objc
    private func didTapShareButton() {
        guard let image else { return }
        present(
            UIActivityViewController(activityItems: [image], applicationActivities: nil),
            animated: true
        )
    }
}
