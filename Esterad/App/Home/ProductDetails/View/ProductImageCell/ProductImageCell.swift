//
//  ProductImageCell.swift
//  Esterad
//
//  Created by Haneen on 20/11/2025.
//

import UIKit
class ProductImageCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .redraw
        img.clipsToBounds = true
        img.layer.cornerRadius = 12
        return img
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.textFieldBorder.cgColor
        backgroundColor = .white
    }
    
    func setupCell(model:ProductImage){
       imageView.kf.setImage(with: URL(string: model.image ?? ""),placeholder: UIImage(resource:.furniturePlaceholder),
                                       options: [.onFailureImage(UIImage(resource: .furniturePlaceholder))])
        if model.isSelected ?? true {
            layer.borderColor = UIColor.main.cgColor
        } else {
            layer.borderColor = UIColor.textFieldBorder.cgColor
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
