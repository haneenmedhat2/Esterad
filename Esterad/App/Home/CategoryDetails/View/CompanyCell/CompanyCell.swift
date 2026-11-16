//
//  CompanyCell.swift
//  Esterad
//
//  Created by Haneen on 17/11/2025.
//

import UIKit
import Kingfisher
import Cosmos

class CompanyCell: UICollectionViewCell {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var companyImage: UIImageView!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var mainView: UIView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 12
        mainView.layer.borderWidth = 1
        mainView.layer.borderColor = UIColor.textFieldBorder.cgColor
        ratingView.settings.fillMode = .precise
    }

    func setupCell(model:SubcategoryItem, category: Category) {
        companyImage.kf.setImage(with: URL(string: model.logo ?? ""),placeholder: UIImage(named: category.companyIcon),
                                 options: [.onFailureImage(UIImage(named: category.companyIcon))])
        companyName.text = model.name
        ratingLabel.text = "(" + (model.rate ?? "0")  + ")"
        ratingView.rating = Double(model.rate ?? "0") ?? 0
        
    }
}
