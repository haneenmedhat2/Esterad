//
//  SearchTabCell.swift
//  Waraqa
//
//  Created by Haneen on 13/09/2025.
//

import UIKit

class HomeModeTypesCell: UICollectionViewCell {

    //MARK: - Outlets -
    
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    //MARK: - Properties -
    
    //MARK: - Nib File Configuration -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellContentView.layer.cornerRadius = 16
    }
    
    //MARK: - Setup Cell -
        
    func setupCell(type: HomeModeTypes, category : Category){
        cellLabel.text = type.localizedTitle
        switch type {
        case .products:
            switch category.categoryKind {
            case .car ,.spareParts:
                iconImage.image = UIImage(resource: .car)
            case .furniture, .other:
                iconImage.image = UIImage(resource: .furniture)
            }
        case .companies:
            iconImage.image = UIImage(resource: .company)
        }
    }

    func updateCellSelection(isCellSelected : Bool ){
        if isCellSelected {
            cellContentView.backgroundColor = .main
            cellLabel.textColor = .white
        } else {
            cellContentView.backgroundColor = .white
            cellLabel.textColor = .black

        }
    }
}
