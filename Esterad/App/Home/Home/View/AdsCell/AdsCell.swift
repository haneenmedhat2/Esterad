//
//  AdsCell.swift
//  Esterad
//
//  Created by Haneen on 12/11/2025.
//

import UIKit
import Kingfisher

class AdsCell: UICollectionViewCell {

    //MARK: - Outlets -
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var adImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 12
        mainView.layer.borderWidth = 1
        mainView.layer.borderColor = UIColor.textFieldBorder.cgColor
        mainView.layer.masksToBounds = true
    }
    
    //MARK: - Cell Setup -

    func setupCell(model: Ad){
        titleLabel.text = model.title
        contentLabel.text = model.content
        adImage.kf.setImage(with: URL(string: model.image ?? ""),placeholder: UIImage(resource: .walletBackground),
                            options: [.onFailureImage(UIImage(resource: .walletBackground ))])
    }
}
