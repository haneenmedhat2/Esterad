//
//  ProductCell.swift
//  Esterad
//
//  Created by Haneen on 16/11/2025.
//

import UIKit
import Kingfisher

class ProductCell: UICollectionViewCell {

    //MARK: - Outlets -
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var beforePrice: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 16
        mainView.layer.borderWidth = 1
        mainView.layer.borderColor = UIColor.textFieldBorder.cgColor
         setupPurchasedView()
    }
    
    private let isPurchasedView: UIView = {
        let view = UIView()
        view.backgroundColor = .newGreen
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let purchasedLabel: UILabel = {
        let label = UILabel()
        label.text = "purchased".localized
        label.textColor = .main
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func setupPurchasedView() {
        productImage.addSubview(isPurchasedView)
        isPurchasedView.addSubview(purchasedLabel)

        NSLayoutConstraint.activate([

            isPurchasedView.centerXAnchor.constraint(equalTo: productImage.centerXAnchor),
            isPurchasedView.centerYAnchor.constraint(equalTo: productImage.centerYAnchor),

            isPurchasedView.widthAnchor.constraint(equalTo: productImage.widthAnchor, multiplier: 1.3),
            isPurchasedView.heightAnchor.constraint(equalToConstant: 30),

            purchasedLabel.centerXAnchor.constraint(equalTo: isPurchasedView.centerXAnchor),
            purchasedLabel.centerYAnchor.constraint(equalTo: isPurchasedView.centerYAnchor)
        ])

        isPurchasedView.transform = CGAffineTransform(rotationAngle: -.pi / 5.2)
    }
    
    func setupCell(model:SubcategoryItem) {
    
        productImage.kf.setImage(with: URL(string: model.image ?? ""),placeholder: UIImage(resource: .carPlaceholder),options: [.onFailureImage(UIImage(resource: .carPlaceholder))])
        
        productName.text = model.name
        productPrice.text =  "price".localized + (model.discountPrice?.toPrice ?? "0") 
        isPurchasedView.isHidden = !(model.isPurchased ?? false)
        
        if let discountPrice = model.discountPrice, !discountPrice.trimWhiteSpace().isEmpty {
            beforePrice.isHidden = false
            let discountText = (model.price?.toPrice ?? "0")
            let fullText = "before_discount".localized + " " + discountText

             beforePrice.setStrikeThrough(text: fullText, strikePart: discountText)
        } else {
            beforePrice.isHidden = true
            productPrice.text =  "price".localized + (model.price?.toPrice ?? "0")

        }
    }
}
