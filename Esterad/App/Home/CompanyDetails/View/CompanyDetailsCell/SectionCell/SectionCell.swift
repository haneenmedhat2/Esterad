//
//  SectionCell.swift
//  Esterad
//
//  Created by Haneen on 20/11/2025.
//

import UIKit

class SectionCell: UICollectionViewCell {

    //MARK: - Outlets -
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var sectionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 20
        mainView.layer.masksToBounds = true
    }
}

