//
//  ReceiverCell.swift
//  Esterad
//
//  Created by Haneen on 07/12/2025.
//

import UIKit
import Kingfisher

class ReceiverCell: UITableViewCell {

    //MARK: - Outlets -
    
    @IBOutlet weak var senderTextView: UITextView!
    @IBOutlet weak var senderImage: UIImageView!
    @IBOutlet weak var senderAvatar: UIImageView!
    @IBOutlet weak var msgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    func setupCell(model : ChatMessage){
        switch model.messageType {
        case .text:
            senderImage.isHidden = true
            senderTextView.isHidden = false
            senderTextView.text = model.content

        case .image:
            senderTextView.isHidden = true
            senderImage.isHidden = false
            senderImage.kf.setImage(with: URL(string: model.content ?? "") , placeholder: UIImage(resource: .avatar))
        }
        senderAvatar.kf.setImage(with: URL(string: model.avatar ?? "") , placeholder: UIImage(resource: .avatar))
    }
}


