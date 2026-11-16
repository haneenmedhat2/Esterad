//
//  MoreCell.swift
//  Esterad
//
//  Created by Haneen on 30/10/2025.
//

import UIKit

class MoreCell: UITableViewCell {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var cellIcon: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    //MARK: - Properties -
    
    var delegate : MoreCellProtocol?
    
    //MARK: - Nib File Configurstion -
    
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
        notificationSwitch.addTarget(self, action: #selector(didChangeSwitch(_:)), for: .valueChanged)
    }
    
    func setupCell(model : MoreMenuItem ,isSwitchEnabled : Bool = true){
        cellTitle.text = model.title
        cellIcon.image = UIImage(named: model.icon)
        
        notificationSwitch.isHidden = model.isSwitchHidden
        arrowImage.isHidden = model.isArrowHidden
        notificationSwitch.isOn = isSwitchEnabled
    }
    
    //MARK: - Actions -
    
    @objc func didChangeSwitch(_ sender: UISwitch) {
        delegate?.didTapSwitch()
    }
}

//MARK: - Delegation -

protocol MoreCellProtocol {
    func didTapSwitch()
}

