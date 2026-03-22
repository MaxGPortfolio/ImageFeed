//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Максим on 06.01.2026.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    // MARK: - Constants
    
    private enum Constants {
        static let gradientCornerRadius: CGFloat = 16
        static let gradientStartPoint = CGPoint(x: 0.5, y: 0)
        static let gradientEndPoint = CGPoint(x: 0.5, y: 1)
        
        static let cellImageVerticalInset: CGFloat = 4
        static let cellImageHorizontalInset: CGFloat = 16
        static let cellImageCornerRadius: CGFloat = 16
        static let dateBackgroundViewHeight: CGFloat = 30
        static let dateLabelTopInset: CGFloat = 4
        static let dateLabelBottomInset: CGFloat = 4
        static let dateLabelHorizontalInset: CGFloat = 8
        static let likeButtonSize: CGFloat = 44
        
        static let topColorAlpha: CGFloat = 0
        static let bottomColorAlpha: CGFloat = 0.7
        
        static let likeOnImageName = "like_button_on"
        static let likeOffImageName = "like_button_off"
        static let placeholderImage = UIImage(resource: .stubIcon)
        static let placeholderImageViewHeight: CGFloat = 75
        static let placeholderImageViewWidth: CGFloat = 83
    }
    
    // MARK: - Reuse Identifier
    
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Public Properties
    
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - Private Properties
    
    private let dateGradientLayer = CAGradientLayer()
    
    private lazy var cellImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.cellImageCornerRadius
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypWhite
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var dateBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var placeholderContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhiteAlpha50
        view.layer.cornerRadius = Constants.cellImageCornerRadius
        view.clipsToBounds = true
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
    
    // MARK: - Configuration
    
    func setImage(from urlString: String) {
        showPlaceholderState()
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        cellImage.kf.setImage(with: url) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success:
                self.hidePlaceholder()
            case .failure:
                self.showPlaceholderState()
            }
        }
    }
    
    func setDateText(_ text: String) {
        dateLabel.text = text
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let imageName = isLiked
        ? Constants.likeOnImageName
        : Constants.likeOffImageName
        likeButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    // MARK: - Lifecycle
    
    override init (style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(cellImage)
        contentView.addSubview(placeholderContainerView)
        placeholderContainerView.addSubview(placeholderImageView)
        contentView.addSubview(dateBackgroundView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(likeButton)
        
        setupConstraints()
        setupDateGradient()
        setupActions()
        
        backgroundColor = .ypBlack
        contentView.backgroundColor = .ypBlack
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        dateLabel.text = nil
        setIsLiked(false)
        showPlaceholderState()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Setup
    
    private func setupDateGradient() {
        dateGradientLayer.cornerRadius = Constants.gradientCornerRadius
        dateGradientLayer.masksToBounds = true
        
        dateGradientLayer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        
        dateGradientLayer.colors = [
            UIColor.ypBlack.withAlphaComponent(Constants.topColorAlpha).cgColor,
            UIColor.ypBlack.withAlphaComponent(Constants.bottomColorAlpha).cgColor
        ]
        
        dateGradientLayer.startPoint = Constants.gradientStartPoint
        dateGradientLayer.endPoint = Constants.gradientEndPoint
        
        dateBackgroundView.layer.insertSublayer(dateGradientLayer, at: 0)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cellImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.cellImageVerticalInset),
            cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.cellImageHorizontalInset),
            cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.cellImageHorizontalInset),
            cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.cellImageVerticalInset),
            
            placeholderContainerView.topAnchor.constraint(equalTo: cellImage.topAnchor),
            placeholderContainerView.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor),
            placeholderContainerView.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            placeholderContainerView.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: placeholderContainerView.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: placeholderContainerView.centerYAnchor),
            placeholderImageView.heightAnchor.constraint(equalToConstant: Constants.placeholderImageViewHeight),
            placeholderImageView.widthAnchor.constraint(equalToConstant: Constants.placeholderImageViewWidth),
            
            dateBackgroundView.heightAnchor.constraint(equalToConstant: Constants.dateBackgroundViewHeight),
            dateBackgroundView.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor),
            dateBackgroundView.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            dateBackgroundView.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: dateBackgroundView.topAnchor, constant: Constants.dateLabelTopInset),
            dateLabel.leadingAnchor.constraint(equalTo: dateBackgroundView.leadingAnchor, constant: Constants.dateLabelHorizontalInset),
            dateLabel.trailingAnchor.constraint(lessThanOrEqualTo: dateBackgroundView.trailingAnchor, constant: -Constants.dateLabelHorizontalInset),
            dateLabel.bottomAnchor.constraint(equalTo: dateBackgroundView.bottomAnchor, constant: -Constants.dateLabelBottomInset),
            
            likeButton.heightAnchor.constraint(equalToConstant: Constants.likeButtonSize),
            likeButton.widthAnchor.constraint(equalTo: likeButton.heightAnchor),
            likeButton.topAnchor.constraint(equalTo: cellImage.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor)
        ])
    }
    
    private func setupActions() {
        likeButton.addTarget(
            self,
            action: #selector(didTapLikeButton),
            for: .touchUpInside
        )
    }
    
    // MARK: - Private
    
    private func showPlaceholderState() {
        placeholderContainerView.isHidden = false
        cellImage.image = nil
    }
    
    private func hidePlaceholder() {
        placeholderContainerView.isHidden = true
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutIfNeeded()
        dateGradientLayer.frame = dateBackgroundView.bounds
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapLikeButton() {
        delegate?.imageListCellDidTapLike(self)
    }
}
