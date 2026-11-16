//
//  PaymentCell.swift
//  Esterad
//
//  Created by Haneen on 27/11/2025.
//

import UIKit

class PaymentCell: UITableViewCell {

    //MARK: - Outlets -
    
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerStackView.layer.cornerRadius = 24
        containerStackView.layer.borderWidth = 1
        containerStackView.layer.borderColor = UIColor.textFieldBorder.cgColor
    }

    //MARK: - Cell Setup -

    func setupCell(model: PaymentTypes , isCellSelected : Bool){
        paymentMethodLabel.text = model.stringValue
        
        if isCellSelected {
            containerStackView.layer.borderColor = UIColor.main.cgColor
            checkImage.image = UIImage(systemName: "checkmark.circle.fill")
            checkImage.tintColor = .main
        } else {
            containerStackView.layer.borderColor = UIColor.textFieldBorder.cgColor
            checkImage.image = UIImage(systemName: "circle")
            checkImage.tintColor = UIColor.textFieldBorder
        }
    }
}
