//
//  CategoryCell.swift
//  Esterad
//
//  Created by Haneen on 12/11/2025.
//

import UIKit
import Kingfisher

class CategoryCell: UICollectionViewCell {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var categoryDescription: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    
    //MARK: - Properties -
    
    let gradientLayer = CAGradientLayer()
    
    //MARK: - Nib Configuration -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupArrow()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        categoryImage.layoutIfNeeded()
        updateGradientFrame()
    }

    
    override func prepareForReuse() {
        super.prepareForReuse()
        gradientLayer.removeFromSuperlayer()
    }

    //MARK: - Setup -
    
    private func setupArrow() {
        if Language.isRTL() {
            arrowImage.image = UIImage(resource: .circledArrow)
        } else {
            arrowImage.image = UIImage(resource: .circledArrowEn)
        }
    }
    
    private func updateGradientFrame() {
        if gradientLayer.superlayer == nil {
            categoryImage.layer.insertSublayer(gradientLayer, at: 0)
        }

        gradientLayer.frame = categoryImage.bounds

        gradientLayer.colors = [
            UIColor(red: 0/255, green: 90/255, blue: 70/255, alpha: 0.85).cgColor,
            UIColor.clear.cgColor
        ]

        if Language.isRTL() {
            gradientLayer.startPoint = CGPoint(x: 1, y: 0.5)
            gradientLayer.endPoint   = CGPoint(x: 0, y: 0.5)
        } else {
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint   = CGPoint(x: 1, y: 0.5)
        }
    }

    
    //MARK: - Cell Setup -
    
    func setupCell(model : Category){
        categoryImage.kf.setImage(with: URL(string: model.image ?? ""),placeholder: UIImage(resource: .categoryBG),
                                  options: [.onFailureImage(UIImage(resource: .categoryBG ))])
        categoryName.text = model.name
        categoryDescription.text = model.desc
    }
}
