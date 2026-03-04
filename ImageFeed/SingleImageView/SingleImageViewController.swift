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
        static let minimumZoomScale: CGFloat = 0.2
        static let maximumZoomScale: CGFloat = 1.25
        
        static let backButtonSize: CGFloat = 24
        static let backButtonTopInset: CGFloat = 11
        static let backButtonLeadingInset: CGFloat = 8
        static let shareButtonSize: CGFloat = 50
        static let shareButtonBottomConstraintHasHomeIndicator: CGFloat = 17
        static let shareButtonBottomConstraintDoesNotHaveHomeIndicator: CGFloat = 30
        
        static let backButtonImageName = UIImage(resource: .backArrowWhite)
        static let shareButtonImageName = UIImage(resource: .sharing)
    }
    
    private var shareButtonBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Public Properties
    
    var image: UIImage? {
        didSet {
            hasConfiguredImage = false
            lastScrollViewBounds = .zero
            
            if isViewLoaded {
                view.setNeedsLayout()
            }
        }
    }
    
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
        button.setImage(Constants.backButtonImageName, for: .normal)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(Constants.shareButtonImageName, for: .normal)
        return button
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
            // Первый раз: полноценная конфигурация
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
    
    // MARK: - Private
    
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

private extension SingleImageViewController {
    
    // MARK: - Setup
    func setupViews() {
        view.backgroundColor = .ypBlack
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(backButton)
        view.addSubview(shareButton)
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
