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
        
        dateGradientLayer.cornerRadius = 16
        dateGradientLayer.masksToBounds = true
        
        dateGradientLayer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        
        dateGradientLayer.colors = [
            UIColor.ypBlack.withAlphaComponent(0).cgColor,
            UIColor.ypBlack.withAlphaComponent(0.7).cgColor
            // при 1 (как в макете) появляются артефакты, а также визуально сливается ячейка с фоном
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
