//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Максим on 06.01.2026.
//
import UIKit

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateBackgroundView: UIView!
    
    static let reuseIdentifier = "ImagesListCell"
    
    private let dateGradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupDateGradient()
    }
    
    private func setupDateGradient() {
        dateBackgroundView.layer.cornerRadius = 16
        dateBackgroundView.layer.masksToBounds = true
        
        dateBackgroundView.layer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        
        dateGradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.0).cgColor,
            UIColor.black.withAlphaComponent(1.0).cgColor
        ]
        
        dateGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        dateGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        dateBackgroundView.layer.insertSublayer(dateGradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dateGradientLayer.frame = dateBackgroundView.bounds
    }
}
