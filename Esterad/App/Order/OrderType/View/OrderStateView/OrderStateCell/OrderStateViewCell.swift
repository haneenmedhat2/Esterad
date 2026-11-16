//
//  OrderCustomViewCell.swift
//  Cleaf
//
//  Created by Haneen on 02/06/2025.
//

import UIKit

class OrderStateViewCell: UICollectionViewCell {
    
    //MARK: - Outlets -
    
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var cellLabel: UILabel!
    
    //MARK: - Properties -
    
    //MARK: - Nib File Configuration -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        cellConfiguration()
    }
    
    //MARK: - Setup Cell -
    
    func cellConfiguration(){
        cellContentView.backgroundColor = .white
        cellContentView.layer.cornerRadius = 16
        cellContentView.layer.masksToBounds = true
        cellContentView.clipsToBounds = true
    }
    
    func setupCell(orderStatus: OrderStatus){
        cellLabel.text = orderStatus.stringValue
    }
    
    func updateCellSelection(isCellSelected : Bool ){
        if isCellSelected {
            cellContentView.backgroundColor = .main
            cellLabel.textColor = .white
        } else {
            cellContentView.backgroundColor = .white
            cellLabel.textColor = .hint
        }
    }
}
