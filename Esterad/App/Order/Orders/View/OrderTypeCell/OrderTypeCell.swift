//
//  OrderTypeCell.swift
//  Esterad
//
//  Created by Haneen on 30/11/2025.
//

import UIKit

class OrderTypeCell: UITableViewCell {

    //MARK: - Outlets -
    
    @IBOutlet weak var orderTypeLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var containerStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewSetup()
    }

    func viewSetup() {
        if Language.isRTL() {
            arrowImage.image = UIImage(resource: .arrowLeft01)
        } else {
            arrowImage.image = UIImage(resource: .arrowRight01)
        }
        
        containerStackView.layer.borderColor = UIColor.textFieldBorder.cgColor
        containerStackView.layer.borderWidth = 1
        containerStackView.layer.cornerRadius = 16
    }
    
    func setupCell(model : OrderType){
        orderTypeLabel.text = model.stringValue
    }
}
