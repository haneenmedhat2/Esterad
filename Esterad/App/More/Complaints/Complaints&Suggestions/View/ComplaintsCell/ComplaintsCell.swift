//
//  ComplaintsCell.swift
//  Esterad
//
//  Created by Haneen on 06/11/2025.
//

import UIKit

class ComplaintsCell: UITableViewCell {

    //MARK: - Outlets -
    
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var complaintsTitleLabel: UILabel!
    @IBOutlet weak var viewComplaintsButton: UIButton!
    
    //MARK: - Nib file configuration -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initilaSetup()
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }

    //MARK: - Initial Setup -

    func initilaSetup(){
        containerStackView.layer.cornerRadius = 16
        containerStackView.layer.borderWidth = 1
        containerStackView.layer.borderColor = UIColor.textFieldBorder.cgColor
        containerStackView.backgroundColor = .white

        
        viewComplaintsButton.layer.cornerRadius = 8
        viewComplaintsButton.layer.borderWidth = 1
        viewComplaintsButton.layer.borderColor = UIColor.textFieldBorder.cgColor
    }
    
    func setupCell(model : ComplaintsModel){
        idLabel.text = "\(model.id ?? 0)"
        createdAtLabel.text = model.createdAt
        stateLabel.text = model.statusText
        complaintsTitleLabel.text = model.text
        stateLabel.textColor = model.complaintsStatus.color
    }
}
