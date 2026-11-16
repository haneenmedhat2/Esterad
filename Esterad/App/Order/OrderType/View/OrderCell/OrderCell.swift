//
//  OrderCell.swift
//  Esterad
//
//  Created by Haneen on 30/11/2025.
//

import UIKit

class OrderCell: UITableViewCell {

    //MARK: - Outlets -
    
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var viewOrderBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewOrderBtn.layer.cornerRadius = 8
        viewOrderBtn.layer.borderWidth = 1
        viewOrderBtn.layer.borderColor = UIColor.textFieldBorder.cgColor
        
        containerStackView.layer.cornerRadius = 16
        containerStackView.layer.borderWidth = 1
        containerStackView.layer.borderColor = UIColor.textFieldBorder.cgColor
        containerStackView.layer.masksToBounds = true
    }

    func setupCell(model : Orders){
        orderIdLabel.text = "\(model.id ?? 0)"
        createdAtLabel.text = model.createdAt
        categoryLabel.text = model.categoryName
    }
}
