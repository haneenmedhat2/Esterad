//
//  ClientRatingCell.swift
//  Esterad
//
//  Created by Haneen on 24/11/2025.
//

import UIKit
import Cosmos
import Kingfisher
class ClientRatingCell: UICollectionViewCell {

    //MARK: - Outlets -
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!

    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userAvatar.layer.cornerRadius = 17
        mainView.layer.cornerRadius = 12
        mainView.layer.borderWidth = 1
        mainView.layer.borderColor = UIColor.textFieldBorder.cgColor
    }
    
    func setupCell(with model: ReviewsModel) {
        usernameLabel.text = model.username
        ratingView.rating = Double(model.rate ?? "0") ?? 0.0
        createdAtLabel.text = model.createdAt
        userAvatar.kf.setImage(with: URL(string: model.userAvatar ?? ""), placeholder: UIImage(resource: .avatar))
        
        if let comment = model.comment, !comment.trimWhiteSpace().isEmpty {
            commentLabel.text = comment
        } else {
            commentLabel.text = "noComment".localized
        }
    }
}
