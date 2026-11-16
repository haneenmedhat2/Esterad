//
//  SocialCell.swift
//  Esterad
//
//  Created by Haneen on 09/11/2025.
//

import UIKit
import Kingfisher

class SocialCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(image: String){
        imageView.layer.cornerRadius = 20
        imageView.kf.setImage(with: URL(string: image),placeholder: UIImage(resource: .frame),
        options: [.onFailureImage(UIImage(resource: .frame ))])
    }
}
