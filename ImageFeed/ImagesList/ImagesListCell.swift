//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Максим on 06.01.2026.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    // MARK: - Constants

    private enum Constants {
        static let reuseIdentifier = "ImagesListCell"

        static let gradientCornerRadius: CGFloat = 16
        static let gradientStartPoint = CGPoint(x: 0.5, y: 0)
        static let gradientEndPoint = CGPoint(x: 0.5, y: 1)

        static let topColorAlpha: CGFloat = 0
        static let bottomColorAlpha: CGFloat = 0.7

        static let likeOnImageName = "like_button_on"
        static let likeOffImageName = "like_button_off"
    }

    // MARK: - IBOutlets

    @IBOutlet private weak var cellImage: UIImageView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var dateBackgroundView: UIView!

    static let reuseIdentifier = Constants.reuseIdentifier

    // MARK: - Private Properties

    private let dateGradientLayer = CAGradientLayer()

    // MARK: - Configuration

    func setImage(_ image: UIImage?) {
        cellImage.image = image
    }

    func setDateText(_ text: String) {
        dateLabel.text = text
    }

    func setIsLiked(_ isLiked: Bool) {
        let imageName = isLiked ? Constants.likeOnImageName : Constants.likeOffImageName
        likeButton.setImage(UIImage(named: imageName), for: .normal)
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupDateGradient()
    }

    // MARK: - Private

    private func setupDateGradient() {
        dateGradientLayer.cornerRadius = Constants.gradientCornerRadius
        dateGradientLayer.masksToBounds = true

        dateGradientLayer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]

        dateGradientLayer.colors = [
            UIColor.ypBlack.withAlphaComponent(Constants.topColorAlpha).cgColor,
            UIColor.ypBlack.withAlphaComponent(Constants.bottomColorAlpha).cgColor // alpha=1 can create artifacts and makes the cell blend with background
        ]

        dateGradientLayer.startPoint = Constants.gradientStartPoint
        dateGradientLayer.endPoint = Constants.gradientEndPoint

        dateBackgroundView.layer.insertSublayer(dateGradientLayer, at: 0)
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        dateGradientLayer.frame = dateBackgroundView.bounds
    }
}
